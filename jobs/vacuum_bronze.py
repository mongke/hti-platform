#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/vacuum_bronze.py                                  NEW FILE
#
# N5: enforces the bronze retention limit from CLAUDE.md section 4 - bronze holds
# personal data for <= 24 h. Two steps, both required:
#
#   1. DELETE the rows in partitions older than the cutoff. Bronze is
#      partitioned by _load_date, so this is a whole-partition delete.
#   2. VACUUM, which is what actually removes the Parquet files. Step 1 alone
#      only rewrites the Delta log: the files stay on disk and the data is still
#      readable by time travel. A partition drop WITHOUT a vacuum looks like
#      deletion and is not one - that is the trap this job exists to close.
#
# Delta refuses a retention window under 7 days unless
# spark.databricks.delta.retentionDurationCheck.enabled=false. That is set on
# THIS SESSION ONLY and never in conf/spark-defaults.conf: set globally, a
# careless VACUUM anywhere could destroy silver or gold history.
#
# DELIBERATELY NOT DRIVEN BY THE CONTROL TABLE. load_bronze.py refuses to run
# when the control table is invalid, which protects data from being copied.
# A deletion job must behave the opposite way: if it refused on a bad control
# table, a validation error would silently stop deletion and personal data would
# accumulate. So this walks the bronze directory and cleans what is there.
#
# bronze-ref is NOT touched: it is non-PII reference data on a longer retention
# decided per table in the purpose register.
#
# Run (and how Airflow will call it in N8):
#   docker compose --profile jobs run --rm spark-jobs \
#       /opt/spark/bin/spark-submit /opt/jobs/vacuum_bronze.py
#
# Exit codes: 0 = all tables cleaned   1 = one or more failed   2 = bad input
# Logs counts, paths and timings only - never row contents (rule 7).
# =============================================================================
from __future__ import annotations

import argparse
import json
import logging
import re
import sys
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import Final, Sequence

LOG: Final[logging.Logger] = logging.getLogger("vacuum_bronze")

BRONZE_ROOT: Final[Path] = Path("/lake/bronze")
LOAD_DATE: Final[str] = "_load_date"
RETENTION_CHECK: Final[str] = "spark.databricks.delta.retentionDurationCheck.enabled"

# Hive-style partition directory: _load_date=2026-09-30
_PARTITION_DIR: Final[re.Pattern[str]] = re.compile(rf"^{LOAD_DATE}=(\d{{4}}-\d{{2}}-\d{{2}})$")


@dataclass(frozen=True)
class TablePlan:
    path: Path
    stale: tuple[date, ...]      # partitions at or before the cutoff
    fresh: tuple[date, ...]      # partitions kept
    empty: bool = False          # partitioned by _load_date but holds no partition right now

    @property
    def name(self) -> str:
        return self.path.name


@dataclass(frozen=True)
class TableResult:
    name: str
    partitions_dropped: int
    files_before: int
    files_after: int
    seconds: float
    error: str = ""

    @property
    def ok(self) -> bool:
        return not self.error


class VacuumError(RuntimeError):
    pass


def parquet_count(path: Path) -> int:
    """Data files on disk, excluding the transaction log."""
    return sum(1 for p in path.rglob("*.parquet") if "_delta_log" not in p.parts)


def _partitioned_by_metadata(table: Path) -> bool:
    """True if the newest metaData action in the Delta log partitions by _load_date.
    Reads the JSON commits newest-first (stdlib only); a checkpointed log whose JSON
    files were all expired yields False, and the caller then escalates as before."""
    for commit in sorted((table / "_delta_log").glob("*.json"), reverse=True):
        try:
            with commit.open(encoding="utf-8") as fh:
                for line in fh:
                    action = json.loads(line)
                    if "metaData" in action:
                        return LOAD_DATE in action["metaData"].get("partitionColumns", [])
        except (OSError, ValueError):
            continue
    return False


def discover(root: Path, cutoff: date) -> tuple[TablePlan, ...]:
    """Every Delta table under bronze, with its partitions split by the cutoff."""
    if not root.is_dir():
        raise VacuumError(f"{root} does not exist or is not a directory")
    plans: list[TablePlan] = []
    for child in sorted(p for p in root.iterdir() if p.is_dir()):
        if not (child / "_delta_log").is_dir():
            LOG.warning("[%s] not a Delta table (no _delta_log) - skipping", child.name)
            continue
        stale: list[date] = []
        fresh: list[date] = []
        partitioned = False
        for sub in sorted(p for p in child.iterdir() if p.is_dir()):
            m = _PARTITION_DIR.match(sub.name)
            if not m:
                continue
            partitioned = True
            if not any(f.is_file() for f in sub.rglob("*")):
                # VACUUM removes files, not directories. An empty partition directory
                # is a leftover of an earlier run, not retained data: re-running
                # DELETE + VACUUM on it every night costs ~15 s per table for nothing.
                sub.rmdir() if not any(sub.iterdir()) else None
                continue
            value = date.fromisoformat(m.group(1))
            (stale if value <= cutoff else fresh).append(value)
        if partitioned and not stale and not fresh:
            # Fixed 2026-10-16: every partition directory was an empty leftover of an
            # earlier VACUUM (removed just above). The table is partitioned and holds
            # nothing - the same "empty" case as below. Before this, it fell through to
            # the final append with no dates and was reported as UNPARTITIONED, a false
            # retention breach that vanished on the next run once the dirs were gone
            # (parkly_park/workerpark 10-14, 5 sma tables 10-16).
            LOG.info("[%s] empty - only leftover empty partition directories", child.name)
            plans.append(TablePlan(child, (), (), empty=True))
            continue
        if not partitioned and _partitioned_by_metadata(child):
            # Every partition was already dropped and vacuumed (a lookup table whose
            # incremental loads keep finding "no new rows"). Nothing on disk to bound,
            # nothing to escalate. Found 2026-10-04 on esukh_module + 3 myproperty.
            LOG.info("[%s] empty - partitioned by %s but no partition on disk", child.name, LOAD_DATE)
            plans.append(TablePlan(child, (), (), empty=True))
            continue
        if not partitioned:
            # Not partitioned by _load_date: this job cannot bound its retention,
            # and silently skipping it would hide undeleted personal data.
            LOG.error("[%s] has no %s partitions - retention CANNOT be enforced "
                      "on this table; it must be reloaded by a partitioning writer",
                      child.name, LOAD_DATE)
            plans.append(TablePlan(child, (), ()))
            continue
        plans.append(TablePlan(child, tuple(stale), tuple(fresh)))
    return tuple(plans)


def build_spark(retain_hours: int):
    from pyspark.sql import SparkSession

    spark = SparkSession.builder.appName("vacuum_bronze").enableHiveSupport().getOrCreate()
    # Session-scoped only. Asserted rather than assumed: if this ever appears in
    # spark-defaults.conf, every job inherits the ability to destroy history.
    spark.conf.set(RETENTION_CHECK, "false")
    LOG.info("%s=false (this session only), retain=%dh", RETENTION_CHECK, retain_hours)
    return spark


def clean_table(spark, plan: TablePlan, cutoff: date, retain_hours: int,
                dry_run: bool) -> TableResult:
    started = datetime.now(timezone.utc)
    before = parquet_count(plan.path)
    if not plan.stale:
        LOG.info("[%s] nothing older than %s (%d partition(s) kept, %d file(s))",
                 plan.name, cutoff.isoformat(), len(plan.fresh), before)
        return TableResult(plan.name, 0, before, before,
                           (datetime.now(timezone.utc) - started).total_seconds())
    if dry_run:
        LOG.info("[%s] WOULD drop %d partition(s) <= %s and vacuum (%d file(s) now)",
                 plan.name, len(plan.stale), cutoff.isoformat(), before)
        return TableResult(plan.name, len(plan.stale), before, before,
                           (datetime.now(timezone.utc) - started).total_seconds())

    location = f"delta.`{plan.path.as_posix()}`"
    try:
        # Whole-partition delete: Delta turns this into a metadata operation.
        spark.sql(f"DELETE FROM {location} WHERE {LOAD_DATE} <= DATE '{cutoff.isoformat()}'")
        # This is the step that removes files from disk.
        spark.sql(f"VACUUM {location} RETAIN {retain_hours} HOURS")
    except Exception as exc:                                    # noqa: BLE001
        return TableResult(plan.name, 0, before, parquet_count(plan.path),
                           (datetime.now(timezone.utc) - started).total_seconds(),
                           error=str(exc).splitlines()[0][:200])

    after = parquet_count(plan.path)
    leftover = [p.name for p in plan.path.iterdir()
                if p.is_dir() and _PARTITION_DIR.match(p.name)
                and date.fromisoformat(_PARTITION_DIR.match(p.name).group(1)) <= cutoff
                and parquet_count(p) > 0]
    if leftover:
        # Verify, do not trust. A VACUUM that reports success while files remain
        # is the failure mode that matters: we would believe personal data was
        # deleted when it was not.
        return TableResult(plan.name, len(plan.stale), before, after,
                           (datetime.now(timezone.utc) - started).total_seconds(),
                           error=f"files still present in stale partitions: {leftover[:5]}")
    LOG.info("[%s] dropped %d partition(s), files %d -> %d",
             plan.name, len(plan.stale), before, after)
    return TableResult(plan.name, len(plan.stale), before, after,
                       (datetime.now(timezone.utc) - started).total_seconds())


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Enforce the bronze <=24h retention limit (CLAUDE.md section 4).")
    parser.add_argument("--bronze-root", type=Path, default=BRONZE_ROOT)
    parser.add_argument("--keep-days", type=int, default=0,
                        help="partitions strictly newer than today-keep_days are kept "
                             "(0 = keep only today)")
    parser.add_argument("--retain-hours", type=int, default=24,
                        help="VACUUM retention window; see the note this prints about "
                             "worst-case age on disk")
    parser.add_argument("--dry-run", action="store_true",
                        help="report what would be deleted; no Spark, no writes")
    args = parser.parse_args(argv)

    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)-7s %(message)s")
    if args.keep_days < 0 or args.retain_hours < 0:
        LOG.error("--keep-days and --retain-hours must not be negative")
        return 2

    cutoff = datetime.now(timezone.utc).date() - timedelta(days=args.keep_days + 1)
    LOG.info("bronze=%s  cutoff=%s (partitions on or before this are deleted)",
             args.bronze_root, cutoff.isoformat())

    # State the arithmetic rather than implying a <=24h guarantee. A partition is
    # dropped up to keep_days+1 days after it was written, and VACUUM then leaves
    # the files for retain_hours more, so worst-case age on disk is the sum.
    worst_case = (args.keep_days + 1) * 24 + args.retain_hours
    if worst_case > 24:
        LOG.warning("worst-case age on disk is ~%dh ((keep_days+1)*24 + retain_hours), "
                    "which exceeds the 24h limit in section 4. To tighten it, lower "
                    "--retain-hours (0 deletes immediately but can break a concurrent "
                    "reader mid-query). Confirm the intended figure with the data officer.",
                    worst_case)

    try:
        plans = discover(args.bronze_root, cutoff)
    except VacuumError as exc:
        LOG.error("%s", exc)
        return 2

    if not plans:
        LOG.info("no Delta tables under %s - nothing to do", args.bronze_root)
        return 0

    unbounded = [p.name for p in plans if not p.stale and not p.fresh and not p.empty]
    spark = None if args.dry_run else build_spark(args.retain_hours)
    results: list[TableResult] = []
    try:
        for plan in plans:
            if plan.name in unbounded or plan.empty:
                continue
            results.append(clean_table(spark, plan, cutoff, args.retain_hours, args.dry_run))
    finally:
        if spark is not None:
            spark.stop()

    dropped = sum(r.partitions_dropped for r in results)
    removed = sum(max(r.files_before - r.files_after, 0) for r in results)
    failed = [r for r in results if not r.ok]
    LOG.info("%s: %d table(s), %d partition(s) dropped, %d file(s) removed",
             "DRY RUN" if args.dry_run else "done", len(results), dropped, removed)
    for r in failed:
        LOG.error("[%s] FAILED: %s", r.name, r.error)
    if unbounded:
        LOG.error("%d table(s) have no %s partitioning, so their retention is NOT "
                  "enforced: %s", len(unbounded), LOAD_DATE, unbounded)
    if failed or unbounded:
        LOG.error("bronze retention NOT fully enforced - this is a policy breach, "
                  "not a warning. Escalate rather than retrying blindly.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
