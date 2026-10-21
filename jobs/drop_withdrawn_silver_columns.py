# =============================================================================
# hti-platform/jobs/drop_withdrawn_silver_columns.py          2026-10-14, extended 10-16
#
# Silver keeps a column after the owner withdraws it (claude.md: "Tightening a
# filter does not clean what is already in silver"). On 2026-10-16, 68 silver tables
# held 189 withdrawn columns - raw payment payloads (esukh_vat.requestData/qrJson,
# esukh_qpayhistory.qpayData), bank account numbers, car plates, IP addresses - and
# the nightly MERGE ran out of heap reading them (esukh_wrongmail 10-14, esukh_vat 10-15).
#
# For every silver table that belongs to a phase-1 control table, the withdrawn
# columns are computed AT RUN TIME:
#     silver schema - columns_allowlist - platform columns
# and the table is rewritten without them. Every row is kept (Parquet column pruning:
# the dropped columns are never read). Verified per table (row count, columns gone);
# a failed check restores the previous version. Then VACUUM RETAIN 0 removes the
# files that held the withdrawn data, unless --no-vacuum.
#
# One table at a time, in one Spark session. Nothing else may write the lake meanwhile.
# Run:  docker compose --profile jobs run --rm spark-jobs /opt/spark/bin/spark-submit \
#         --driver-memory 2g /opt/jobs/drop_withdrawn_silver_columns.py [--dry-run] [--tables t ...]
# Logs counts and column NAMES only, never values.
# =============================================================================
from __future__ import annotations

import argparse
import csv
import glob
import logging
import sys

sys.path.insert(0, "/opt/jobs")
from tokenize_silver import SILVER, build_spark  # noqa: E402

LOG = logging.getLogger("drop_withdrawn")
PLATFORM_COLUMNS = {"_ingested_at", "_load_date", "_source", "_tokenised_at"}


def allowlists() -> dict[str, set[str]]:
    out: dict[str, set[str]] = {}
    for f in glob.glob("/opt/jobs/control_table_*_phase1.csv"):
        with open(f, encoding="utf-8") as fh:
            for r in csv.DictReader(fh):
                out[f"{r['source_system']}_{r['source_table']}".lower()] = set(r["columns_allowlist"].split("|"))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--no-vacuum", action="store_true")
    ap.add_argument("--tables", nargs="*", default=[])
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    spark = build_spark()
    spark.sparkContext.setLogLevel("WARN")
    spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")
    from delta.tables import DeltaTable

    allow = allowlists()
    tables = args.tables or sorted(t for t in allow if DeltaTable.isDeltaTable(spark, f"{SILVER}/{t}"))
    done = failed = 0
    for table in tables:
        path = f"{SILVER}/{table}"
        if table not in allow or not DeltaTable.isDeltaTable(spark, path):
            LOG.info("[%s] not a phase-1 silver table - skipped", table)
            continue
        df = spark.read.format("delta").load(path)
        drop = [c for c in df.columns if c not in allow[table] and c not in PLATFORM_COLUMNS]
        if not drop:
            continue
        keep = [c for c in df.columns if c not in drop]
        n = df.select(keep[0]).count()
        LOG.info("[%s] rows=%d dropping=%s", table, n, drop)
        if args.dry_run:
            continue
        version = DeltaTable.forPath(spark, path).history(1).select("version").first()[0]
        (df.select(*keep).write.format("delta").mode("overwrite")
           .option("overwriteSchema", "true").save(path))
        back = spark.read.format("delta").load(path)
        ok = back.select(keep[0]).count() == n and not (set(back.columns) & set(drop))
        if not ok:
            DeltaTable.forPath(spark, path).restoreToVersion(version)
            LOG.error("[%s] verification FAILED - restored version %d", table, version)
            failed += 1
            continue
        if not args.no_vacuum:
            spark.sql(f"VACUUM delta.`{path}` RETAIN 0 HOURS")
        LOG.info("[%s] OK: rows=%d, %d column(s) removed%s", table, n, len(drop),
                 "" if args.no_vacuum else ", old files vacuumed")
        done += 1
    LOG.info("done: %d table(s) cleaned, %d failed", done, failed)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
