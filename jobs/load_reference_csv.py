#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/load_reference_csv.py                             NEW FILE
#
# Loads a hand-maintained reference CSV into /lake/bronze-ref as a Delta table.
#
# Why this exists (2026-10-08): some reference data has no source database at
# all. complex_grade - the business classification of each housing complex as
# үнэтэй / дундаж / хямд - is the first case: KPIs 8, 10, 12 and 37 group by it
# and no source system holds it. It arrives as a spreadsheet from the business
# team, so there is nothing for load_bronze.py (JDBC only) to read.
#
# bronze-ref, not bronze: a complex's price grade is a property of a building,
# not of a person, so it is not vacuumed at 24h and BI may read it directly.
#
# It is deliberately NOT a general CSV importer:
#   - the schema must be declared in REFERENCES below, so an unreviewed
#     spreadsheet column cannot become a lake column by being in row 1;
#   - every value in a declared enum column is checked, and one bad value
#     fails the load rather than silently creating a new category;
#   - full overwrite only. A reference list is a statement of current truth,
#     it has no history and no watermark.
#
# Usage:
#   python3 jobs/load_reference_csv.py --reference complex_grade \
#       --csv jobs/reference/complex_grade.csv
#   python3 jobs/load_reference_csv.py --reference complex_grade --csv ... --dry-run
# =============================================================================
from __future__ import annotations

import argparse
import csv
import logging
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Final

BRONZE_REF_ROOT: Final[Path] = Path("/lake/bronze-ref")

LOG = logging.getLogger("load_reference_csv")


@dataclass(frozen=True)
class Reference:
    """One declared reference table. `columns` is the exact, ordered header the
    CSV must carry; `enums` constrains a column to a closed set; `require_one_of`
    names columns of which at least one must be non-empty on every row."""

    name: str
    columns: tuple[str, ...]
    enums: dict[str, frozenset[str]] = field(default_factory=dict)
    require_one_of: tuple[str, ...] = ()
    require_msg: str = "the row identifies nothing"
    note: str = ""


REFERENCES: Final[dict[str, Reference]] = {
    # KPIs 8, 10, 12, 37. Supplied by the HTI business team; see
    # docs/KPI_UNLOCK_REQUESTS_2026-10-06.md item 8.
    "complex_grade": Reference(
        name="complex_grade",
        columns=("townId", "buildingId", "grade", "source", "effectiveFrom"),
        enums={"grade": frozenset({"үнэтэй", "дундаж", "хямд"})},
        require_one_of=("townId", "buildingId"),
        require_msg="neither a town nor a building is named, so the grade applies to nothing",
        note="Price grade of a housing complex. No source database holds this.",
    ),
    # Алхам 2 of the KPI completion plan. The plan is explicit that a confirmed
    # enum meaning must NOT be hardcoded in KPI SQL but held here, so a meaning
    # can change without editing code. `confirmed_by` must be non-empty: an
    # unconfirmed guess must never silently drive a KPI.
    "kpi_value_map": Reference(
        name="kpi_value_map",
        columns=("source_system", "source_table", "source_column", "source_value",
                 "kpi_meaning", "confirmed_by"),
        require_one_of=("confirmed_by",),
        require_msg="confirmed_by is empty - an unconfirmed meaning must not drive a KPI",
        note="Maps a source enum value to the business meaning a KPI groups by.",
    ),
    # KPI 41 (action 2.5, 2026-10-14). Count-only: built by
    # /home/developer/dbbackup/sma_otp_counts.sh from the Otps AUTO_INCREMENT value in
    # each nightly sma dump's CREATE TABLE line. No OTP row, code or phone number is
    # ever read or copied - sma.Otps stays a never-copied credential store (CT019).
    "sma_otp_daily": Reference(
        name="sma_otp_daily",
        columns=("day", "otp_sent", "window_from", "window_to", "source"),
        require_one_of=("otp_sent",),
        require_msg="otp_sent is empty",
        note="OTP SMS created per day (difference of the Otps id counter between dumps).",
    ),
    # KPI 52 (action 5.1, 2026-10-14). Aggregate-only: built by
    # /home/developer/dbbackup/parkly_payment_counts.sh INSIDE the local pg-parkly copy.
    # parkly.Payments is classified Red; no payment row, plate or car id leaves the
    # database - only per-period totals, and any group with fewer than 5 distinct
    # cars has its numbers blanked at the source.
    "parkly_payment_daily": Reference(
        name="parkly_payment_daily",
        columns=("grain", "period", "payment_type", "success", "payments", "distinct_cars",
                 "paid_amount", "suppressed"),
        enums={"grain": frozenset({"day", "month"}), "success": frozenset({"true", "false"}),
               "suppressed": frozenset({"yes", "no"})},
        require_one_of=("period",),
        require_msg="period is empty",
        note="Parking payments per day and per month by payment type: counts and totals only.",
    ),
    # KPI 47 (action 7.1, 2026-10-14). From the central Prometheus (node-exporter `up`
    # of every server), exported daily by /home/developer/dbbackup/monitoring_export.sh.
    "monitoring_downtime_daily": Reference(
        name="monitoring_downtime_daily",
        columns=("day", "server", "up_ratio", "down_minutes", "source"),
        require_one_of=("server",),
        require_msg="server is empty",
        note="Minutes per Ulaanbaatar day a server's node exporter was not reachable.",
    ),
    # KPI 57 (action 7.2, 2026-10-14). Blackbox HTTP probes of public endpoints from the
    # central server, exported daily by monitoring_export.sh.
    "api_latency_daily": Reference(
        name="api_latency_daily",
        columns=("day", "target", "avg_ms", "p95_ms", "success_ratio", "source"),
        require_one_of=("target",),
        require_msg="target is empty",
        note="Response time of public endpoints per Ulaanbaatar day, from blackbox probes.",
    ),
}


def read_rows(csv_path: Path, ref: Reference) -> list[dict[str, str]]:
    with csv_path.open(encoding="utf-8-sig", newline="") as fh:
        reader = csv.DictReader(fh)
        header = tuple(reader.fieldnames or ())
        if header != ref.columns:
            raise SystemExit(
                f"error: {csv_path.name} header is {header}\n"
                f"       {ref.name} requires exactly {ref.columns}\n"
                f"       A column that is not declared in REFERENCES cannot be loaded. "
                f"If the business team added one, it needs review first."
            )
        rows = [{k: (v or "").strip() for k, v in r.items()} for r in reader]

    problems: list[str] = []
    for n, row in enumerate(rows, start=2):          # line 1 is the header
        for col, allowed in ref.enums.items():
            if row[col] not in allowed:
                problems.append(
                    f"  line {n}: {col}={row[col]!r} is not one of {sorted(allowed)}"
                )
        if ref.require_one_of and not any(row[c] for c in ref.require_one_of):
            problems.append(f"  line {n}: {ref.require_msg}")
    if problems:
        raise SystemExit(
            f"error: {len(problems)} bad row(s) in {csv_path.name}:\n"
            + "\n".join(problems[:25])
            + ("\n  ..." if len(problems) > 25 else "")
            + "\n       Nothing was loaded. These are business decisions, not import "
            "errors to work around."
        )
    if not rows:
        raise SystemExit(f"error: {csv_path.name} has a valid header but no rows")
    return rows


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", required=True, choices=sorted(REFERENCES))
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--bronze-ref-root", type=Path, default=BRONZE_REF_ROOT)
    parser.add_argument("--dry-run", action="store_true",
                        help="validate the CSV and print what would be written")
    args = parser.parse_args(argv)

    logging.basicConfig(level=logging.INFO, format="%(levelname)-7s %(message)s")
    ref = REFERENCES[args.reference]
    if not args.csv.is_file():
        raise SystemExit(f"error: {args.csv} not found")

    rows = read_rows(args.csv, ref)
    target = args.bronze_ref_root / ref.name
    LOG.info("%s: %d row(s) validated, %d column(s)", ref.name, len(rows), len(ref.columns))

    if args.dry_run:
        LOG.info("dry run - would overwrite %s", target)
        for row in rows[:5]:
            LOG.info("  %s", row)
        return 0

    from pyspark.sql import SparkSession

    spark = SparkSession.builder.appName(f"load_reference_{ref.name}").enableHiveSupport().getOrCreate()
    try:
        frame = spark.createDataFrame(rows, schema=", ".join(f"{c} string" for c in ref.columns))
        # Overwrite: a reference list is current truth, not an event stream.
        frame.write.format("delta").mode("overwrite") \
            .option("overwriteSchema", "true").save(str(target))
        LOG.info("wrote %d row(s) to %s", frame.count(), target)
    finally:
        spark.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
