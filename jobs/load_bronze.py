#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/load_bronze.py                                    NEW FILE
#
# N3: config-driven JDBC loader, source MySQL -> /lake/bronze (Delta).
#
# The control table is the only thing that decides what is copied. This job
# refuses to run unless jobs/control_table.csv passes validate_control_table.py
# with zero errors, and it only ever SELECTs the columns named in each row's
# columns_allowlist. There is no "load everything" path and no way to widen the
# allowlist from the command line - an allowlist that can be bypassed is not a
# control (CLAUDE.md section 4).
#
# Per row:
#   load_mode=incremental  -> SELECT ... WHERE <watermark> > high-water mark,
#                             then Delta MERGE on the primary key
#   load_mode=full         -> SELECT ... , then overwrite the table
#
# Adds _ingested_at, _load_date, _source; partitions by _load_date so N5 can
# drop whole partitions for the <=24h bronze retention.
#
# Run (and how Airflow will call it in N8):
#   docker compose --profile jobs run --rm spark-jobs \
#       /opt/spark/bin/spark-submit /opt/jobs/load_bronze.py \
#       --control-table /opt/jobs/control_table_esukh.csv --source-system esukh
#
# A real run MUST go through spark-submit: pyspark and delta.tables are only on
# sys.path there, not under plain python3 in this image (verified 2026-09-29).
# --dry-run is the exception - it validates and prints the plan without touching
# Spark or the database, so it runs anywhere python3 does, including in CI.
#
# Credentials come from the environment, never the command line (G5):
#   ESUKH_DB_URL, ESUKH_DB_USER, ESUKH_DB_PASSWORD  (<SYSTEM>_DB_*)
# The account must be read-only: SELECT on the allowlisted tables and nothing
# else. TLS is required unless --insecure-no-tls is passed, which exists only
# for a local synthetic-data test and refuses to touch a non-local host.
#
# Logs counts, schemas, paths and timings only. Never row contents (rule 7).
# =============================================================================
from __future__ import annotations

import argparse
import logging
import os
import sys
from dataclasses import dataclass
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Final, Sequence

sys.path.insert(0, str(Path(__file__).resolve().parent))

from validate_control_table import (  # noqa: E402  (path set above)
    ControlRow,
    Severity,
    parse_rows,
    validate,
)

LOG: Final[logging.Logger] = logging.getLogger("load_bronze")

# Audit columns added to every bronze table.
INGESTED_AT: Final[str] = "_ingested_at"
LOAD_DATE: Final[str] = "_load_date"
SOURCE: Final[str] = "_source"
AUDIT_COLUMNS: Final[tuple[str, ...]] = (INGESTED_AT, LOAD_DATE, SOURCE)

LAYER_PATHS: Final[dict[str, str]] = {
    "bronze": "/lake/bronze",
    "bronze-ref": "/lake/bronze-ref",
}

# High-water marks live OUTSIDE /lake/bronze, deliberately.
#
# They used to be derived from max(watermark) in the bronze table itself, which
# is wrong once N5 exists: vacuum_bronze.py deletes bronze partitions older than
# a day, so by the next run max() is NULL and every "incremental" table silently
# degrades to a full re-read of the source. 171 tables across the four systems
# are marked incremental, so that is a nightly full scan of every one of them,
# with no error to reveal it.
#
# Silver is not a safe home either: the transform may band that very timestamp
# (exact time -> day+hour), destroying the precision the watermark needs.
#
# So: a small Delta table keyed on (source_system, source_table). It holds a max
# timestamp or id per table - not personal data - so it can persist indefinitely.
WATERMARK_PATH: Final[str] = "/lake/_watermarks"


# JDBC driver per URL scheme. Both jars are pinned in conf/spark-defaults.conf.
# CHANGED 2026-09-30: the driver was hardcoded to MySQL, which worked for esukh
# and the synthetic test and failed every table of the Postgres parkly restore
# with "could not open a JDBC connection".
JDBC_DRIVERS: Final[dict[str, str]] = {
    "jdbc:mysql:": "com.mysql.cj.jdbc.Driver",
    "jdbc:postgresql:": "org.postgresql.Driver",
}


def driver_for(url: str) -> str:
    for prefix, driver in JDBC_DRIVERS.items():
        if url.lower().startswith(prefix):
            return driver
    raise LoadError(
        f"no JDBC driver known for this URL scheme: {url.split('://')[0]}://... "
        f"(supported: {', '.join(sorted(JDBC_DRIVERS))})"
    )


@dataclass(frozen=True)
class SourceConnection:
    url: str
    user: str
    password: str
    driver: str

    @property
    def quote(self) -> str:
        """Identifier quote character for this dialect.

        MySQL uses backticks, Postgres uses double quotes, and the difference is
        not cosmetic: esukh's columns are case-insensitive while parkly has
        camelCase identifiers that only resolve when quoted. Hardcoding
        backticks made every parkly table fail with a syntax error.
        """
        return '"' if self.driver == "org.postgresql.Driver" else "`"

    @property
    def redacted_url(self) -> str:
        """The URL with any embedded credentials removed, safe for logs."""
        return self.url.split("?")[0]


@dataclass(frozen=True)
class LoadOutcome:
    table: str
    mode: str
    rows_read: int
    seconds: float


class LoadError(RuntimeError):
    """Raised for conditions that must stop the run rather than be logged."""


# -----------------------------------------------------------------------------
# configuration
# -----------------------------------------------------------------------------
def connection_from_env(source_system: str, *, require_tls: bool) -> SourceConnection:
    prefix = source_system.upper().replace("-", "_")
    missing = [
        name for name in (f"{prefix}_DB_URL", f"{prefix}_DB_USER", f"{prefix}_DB_PASSWORD")
        if not os.environ.get(name)
    ]
    if missing:
        raise LoadError(
            f"missing environment variables for '{source_system}': {', '.join(missing)}. "
            "Set them in the container environment; never pass them as arguments."
        )

    url = os.environ[f"{prefix}_DB_URL"]
    lowered = url.lower()
    # MySQL: sslMode=/useSSL=; Postgres: ssl=true/sslmode=
    tls_on = ("sslmode=" in lowered or "ssl-mode=required" in lowered
              or "usessl=true" in lowered or "ssl=true" in lowered)

    if require_tls and not tls_on:
        raise LoadError(
            f"{prefix}_DB_URL does not enable TLS. Append e.g. "
            "'?sslMode=VERIFY_CA&requireSSL=true', or pass --insecure-no-tls for a "
            "local synthetic-data test."
        )
    if not require_tls:
        host = lowered.split("//", 1)[-1].split("/", 1)[0]
        hostname = host.split(":", 1)[0]
        # A bare name with no dot has no TLD, so it cannot be a public DNS name -
        # it is a container on a Docker network, reachable only from this host.
        # Anything with a dot (a FQDN or an IP) is treated as remote and refused.
        # CHANGED 2026-09-30: was a hardcoded "mysql-" prefix list, written when
        # only MySQL was in scope; it refused the local pg-parkly restore.
        local = hostname in ("localhost", "127.0.0.1", "::1") or "." not in hostname
        if not local:
            raise LoadError(
                f"--insecure-no-tls refuses non-local host '{host}'. Source databases "
                "hold personal data and must be read over TLS."
            )
        LOG.warning("TLS DISABLED for local host '%s' - never use this against a remote source",
                    hostname)

    return SourceConnection(
        url=url,
        user=os.environ[f"{prefix}_DB_USER"],
        password=os.environ[f"{prefix}_DB_PASSWORD"],
        driver=driver_for(url),
    )


def load_plan(control_table: Path, exceptions: Path, source_system: str,
              only: Sequence[str]) -> tuple[ControlRow, ...]:
    """Validate the control table, then return the rows this run will load.

    Refuses on ANY error. The control table is the privacy control; a job that
    loads from an invalid one defeats it.
    """
    violations = validate(control_table, exceptions)
    errors = [v for v in violations if v.severity is Severity.ERROR]
    if errors:
        for violation in errors[:20]:
            LOG.error("control table: %s", violation.render())
        if len(errors) > 20:
            LOG.error("control table: ... and %d more", len(errors) - 20)
        raise LoadError(
            f"{control_table} has {len(errors)} validation error(s) - refusing to load. "
            "Fix them (and have the data officer sign the file) before running."
        )
    for violation in (v for v in violations if v.severity is Severity.WARNING):
        LOG.warning("control table: %s", violation.render())

    rows, _ = parse_rows(control_table)
    selected = [r for r in rows if r.source_system.lower() == source_system.lower()]
    if only:
        wanted = {name.lower() for name in only}
        selected = [r for r in selected if r.source_table.lower() in wanted]
        unknown = wanted - {r.source_table.lower() for r in selected}
        if unknown:
            raise LoadError(
                f"--tables named {sorted(unknown)}, which are not in the control table "
                "for this source system. Nothing outside the control table can be loaded."
            )
    if not selected:
        raise LoadError(f"no control table rows for source_system '{source_system}'")
    return tuple(selected)


# -----------------------------------------------------------------------------
# spark
# -----------------------------------------------------------------------------
def build_spark(app_name: str):
    """Create the SparkSession. Imported lazily so --dry-run needs no pyspark."""
    from pyspark.sql import SparkSession

    # Engine-level settings (Delta extension, metastore, sizing) come from
    # conf/spark-defaults.conf; nothing here should duplicate them.
    return SparkSession.builder.appName(app_name).enableHiveSupport().getOrCreate()


def target_path(row: ControlRow) -> str:
    base = LAYER_PATHS[row.target_layer]
    return f"{base}/{row.source_system.lower()}_{row.source_table.lower()}"


def high_water_mark(spark, row: ControlRow) -> str | None:
    """Last watermark recorded for this table, or None if it has never loaded.

    Read from the durable store, never from bronze - see WATERMARK_PATH.
    """
    from delta.tables import DeltaTable

    if not DeltaTable.isDeltaTable(spark, WATERMARK_PATH):
        return None
    found = (
        spark.read.format("delta").load(WATERMARK_PATH)
        .where(f"source_system = '{row.source_system}' AND source_table = '{row.source_table}'")
        .select("watermark_value").collect()
    )
    if not found or found[0]["watermark_value"] is None:
        return None
    return str(found[0]["watermark_value"])


def forget_watermarks(spark, source_system: str, tables: Sequence[str]) -> None:
    """Delete the stored watermark for these tables so the next read is a full one.

    Only the named tables: see the --reset-watermark guard in main(). Deleting the
    row (rather than writing a null) keeps high_water_mark()'s "never loaded"
    branch as the single definition of "read everything".
    """
    from delta.tables import DeltaTable

    if not DeltaTable.isDeltaTable(spark, WATERMARK_PATH):
        LOG.info("no watermark store yet - nothing to reset")
        return
    quoted = ", ".join("'" + t.replace("'", "''") + "'" for t in tables)
    predicate = f"source_system = '{source_system}' AND source_table IN ({quoted})"
    before = (spark.read.format("delta").load(WATERMARK_PATH).where(predicate).count())
    DeltaTable.forPath(spark, WATERMARK_PATH).delete(predicate)
    LOG.warning("reset watermark for %d of %d named table(s) - they will be read in FULL",
                before, len(tables))


def record_high_water_mark(spark, row: ControlRow, frame) -> str | None:
    """Store the largest watermark value in the batch just read.

    Taken from the incoming batch rather than from bronze, so it survives the
    N5 vacuum. Returns the value stored, or None if the batch had none.
    """
    from delta.tables import DeltaTable
    from pyspark.sql import functions as F, Row
    from pyspark.sql.types import StringType, StructField, StructType, TimestampType

    if row.watermark_column not in frame.columns:
        return None
    peak = frame.agg(F.max(F.col(row.watermark_column)).alias("hwm")).collect()
    if not peak or peak[0]["hwm"] is None:
        return None
    value = str(peak[0]["hwm"])

    schema = StructType([
        StructField("source_system", StringType(), False),
        StructField("source_table", StringType(), False),
        StructField("watermark_column", StringType(), False),
        StructField("watermark_value", StringType(), False),
        StructField("updated_at", TimestampType(), False),
    ])
    latest = spark.createDataFrame([Row(
        source_system=row.source_system, source_table=row.source_table,
        watermark_column=row.watermark_column, watermark_value=value,
        updated_at=datetime.now(timezone.utc))], schema=schema)

    # /lake/_watermarks is ONE Delta table shared by every system's load. With two
    # loads running (Airflow max_active_tasks=2) a MERGE here can collide with the
    # other load's commit -> ConcurrentAppendException, which on 2026-10-06 was
    # reported as a failure of the data table (parkly camera_health_log) although
    # its data had been written. Retry with jitter; the merge is idempotent.
    import random, time as _time
    for attempt in range(1, 8):
        try:
            if DeltaTable.isDeltaTable(spark, WATERMARK_PATH):
                (DeltaTable.forPath(spark, WATERMARK_PATH).alias("t")
                 .merge(latest.alias("s"),
                        "t.source_system = s.source_system AND t.source_table = s.source_table")
                 .whenMatchedUpdateAll().whenNotMatchedInsertAll().execute())
            else:
                latest.write.format("delta").mode("overwrite").save(WATERMARK_PATH)
            break
        except Exception as exc:  # noqa: BLE001
            if "Concurrent" not in type(exc).__name__ + str(exc) or attempt == 7:
                raise
            pause = random.uniform(0.5, 2.0) * attempt
            LOG.info("[%s] watermark store busy (attempt %d) - retrying in %.1fs", row.source_table, attempt, pause)
            _time.sleep(pause)
    LOG.info("[%s] watermark recorded: %s = %s", row.source_table, row.watermark_column, value)
    return value


def read_source(spark, connection: SourceConnection, row: ControlRow,
                since: str | None, fetch_size: int):
    """Read exactly the allowlisted columns. Never SELECT *."""
    q = connection.quote
    columns = ", ".join(f"{q}{name}{q}" for name in row.columns_allowlist)
    predicate = ""
    if since is not None and row.watermark_column:
        # Parameterised via a literal here because Spark's JDBC source takes a
        # subquery, not a prepared statement. The value came from our own Delta
        # table, not from user input.
        predicate = f" WHERE {q}{row.watermark_column}{q} > '{since}'"
    query = f"(SELECT {columns} FROM {q}{row.source_table}{q}{predicate}) AS src"

    LOG.info("[%s] reading %s columns%s", row.source_table, len(row.columns_allowlist),
             f" since {since}" if since else " (full)")
    reader = (
        spark.read.format("jdbc")
        .option("url", streaming_url(connection.url))
        .option("user", connection.user)
        .option("password", connection.password)
        .option("driver", connection.driver)
        .option("dbtable", query)
        .option("fetchsize", str(fetch_size))
    )
    # Big tables (esukh.balance: ~16M rows) must not arrive as ONE JDBC partition:
    # on 2026-10-06 that was a single task holding the whole result set and the
    # driver died with "Java heap space". Split on the numeric primary key.
    bounds = pk_bounds(spark, connection, row, predicate) if row.primary_key in row.columns_allowlist else None
    if bounds:
        lo, hi = bounds
        parts = max(1, min(MAX_JDBC_PARTITIONS, (hi - lo + 1) // ROWS_PER_PARTITION + 1))
        if parts > 1:
            LOG.info("[%s] %d JDBC partitions on %s [%d..%d]", row.source_table, parts, row.primary_key, lo, hi)
            reader = (reader.option("partitionColumn", row.primary_key)
                            .option("lowerBound", str(lo)).option("upperBound", str(hi))
                            .option("numPartitions", str(parts)))
    return reader.load()


ROWS_PER_PARTITION: Final[int] = 400_000     # ~ what one task can hold comfortably at 1 GB driver heap
MAX_JDBC_PARTITIONS: Final[int] = 24


def streaming_url(url: str) -> str:
    """MySQL Connector/J buffers the entire result set client-side unless cursor
    fetch is on; fetchsize alone does nothing. Postgres streams once autocommit is
    off, which Spark already does."""
    if url.startswith("jdbc:mysql:") and "useCursorFetch" not in url:
        return url + ("&" if "?" in url else "?") + "useCursorFetch=true"
    return url


def pk_bounds(spark, connection: SourceConnection, row: ControlRow, predicate: str) -> tuple[int, int] | None:
    """MIN/MAX of the primary key for the rows about to be read; None if the key is
    not integer-like or the table is empty (then a single partition is fine)."""
    q = connection.quote
    sql = f"(SELECT MIN({q}{row.primary_key}{q}) AS lo, MAX({q}{row.primary_key}{q}) AS hi FROM {q}{row.source_table}{q}{predicate}) AS b"
    try:
        r = (spark.read.format("jdbc").option("url", connection.url).option("user", connection.user)
             .option("password", connection.password).option("driver", connection.driver)
             .option("dbtable", sql).load().collect())
        if not r or r[0]["lo"] is None:
            return None
        lo, hi = int(r[0]["lo"]), int(r[0]["hi"])
        return (lo, hi) if hi > lo else None
    except Exception as exc:  # noqa: BLE001 - non-numeric key, permissions, etc.
        LOG.info("[%s] no partition bounds (%s) - single partition", row.source_table, str(exc).splitlines()[0][:80])
        return None


def check_schema_drift(spark, row: ControlRow, path: str, incoming,
                       allow_narrowing: bool = False, full_reread: bool = False) -> bool:
    """Alert on columns that disappeared or changed type. Returns True if the
    table must be REBUILT (its schema narrowed and that was explicitly allowed).

    New columns are allowed through (mergeSchema); they are already constrained
    by the allowlist, so they can only appear if the data officer added them.
    A dropped or retyped column silently breaks downstream marts, so it stops
    the run instead.

    `allow_narrowing` is the one legitimate exception, added 2026-10-09. When an
    owner NARROWS their allowlist - as the esukh team did on 10-08, taking `user`
    from 15 columns to 5 - refusing the load is backwards: it leaves bronze
    holding the very columns they just withdrew. The right answer is to rebuild
    the table without them. Guarded three ways:
      * only `dropped`, never `retyped` - a type change is a source-side surprise
        and still stops the run;
      * only when the table is being read in FULL (`full` mode, or `incremental`
        with --reset-watermark), because an overwrite of a partially-read table
        would lose rows bronze holds and the source no longer returns;
      * never silently - it logs every column it is about to stop holding.
    """
    from delta.tables import DeltaTable

    if not DeltaTable.isDeltaTable(spark, path):
        return False
    existing = spark.read.format("delta").load(path)
    old = {f.name: f.dataType.simpleString() for f in existing.schema.fields
           if f.name not in AUDIT_COLUMNS}
    new = {f.name: f.dataType.simpleString() for f in incoming.schema.fields
           if f.name not in AUDIT_COLUMNS}

    dropped = sorted(set(old) - set(new))
    retyped = sorted(name for name in set(old) & set(new) if old[name] != new[name])
    added = sorted(set(new) - set(old))

    if added:
        LOG.info("[%s] new columns: %s", row.source_table, added)

    if dropped and not retyped and allow_narrowing:
        if not full_reread:
            raise LoadError(
                f"[{row.source_table}] allowlist narrowed by {len(dropped)} column(s) but this "
                f"run is not a full re-read, so an overwrite would lose rows. Re-run with "
                f"--reset-watermark for this table.")
        LOG.warning("[%s] allowlist NARROWED - rebuilding without %s",
                    row.source_table, dropped)
        return True

    if dropped or retyped:
        detail = []
        if dropped:
            detail.append(f"dropped {dropped}")
        if retyped:
            detail.append("retyped " + str({n: (old[n], new[n]) for n in retyped}))
        hint = (" - re-run with --allow-narrowing --reset-watermark if the owner withdrew them"
                if dropped and not retyped else "")
        raise LoadError(f"[{row.source_table}] schema drift: {'; '.join(detail)}{hint}")

    return False


def add_audit_columns(frame, row: ControlRow, load_date: date):
    from pyspark.sql import functions as F
    from pyspark.sql.types import DateType, StringType, TimestampType

    return (
        frame
        .withColumn(INGESTED_AT, F.lit(datetime.now(timezone.utc)).cast(TimestampType()))
        .withColumn(LOAD_DATE, F.lit(load_date.isoformat()).cast(DateType()))
        .withColumn(SOURCE, F.lit(row.source_system).cast(StringType()))
    )


def write_bronze(spark, row: ControlRow, path: str, frame, incremental: bool) -> None:
    from delta.tables import DeltaTable

    if incremental and DeltaTable.isDeltaTable(spark, path):
        target = DeltaTable.forPath(spark, path)
        updates = {name: f"source.`{name}`" for name in frame.columns}
        (
            target.alias("target")
            # Backticks here are Spark SQL, not the source dialect - correct for both.
            .merge(frame.alias("source"),
                   f"target.`{row.primary_key}` = source.`{row.primary_key}`")
            .whenMatchedUpdate(set=updates)
            .whenNotMatchedInsertAll()
            .execute()
        )
        LOG.info("[%s] merged on %s", row.source_table, row.primary_key)
        return

    mode = "append" if incremental else "overwrite"
    (
        frame.write.format("delta")
        .mode(mode)
        .partitionBy(LOAD_DATE)
        .option("mergeSchema", "true")
        .option("overwriteSchema", "true" if mode == "overwrite" else "false")
        .save(path)
    )
    LOG.info("[%s] wrote %s -> %s", row.source_table, mode, path)


def load_table(spark, connection: SourceConnection, row: ControlRow,
               load_date: date, fetch_size: int,
               allow_narrowing: bool = False, watermark_was_reset: bool = False) -> LoadOutcome:
    started = datetime.now(timezone.utc)
    path = target_path(row)
    incremental = row.load_mode == "incremental"

    since = high_water_mark(spark, row) if incremental else None
    if incremental and since is None:
        LOG.info("[%s] no high-water mark yet - first load is full", row.source_table)

    source = read_source(spark, connection, row, since, fetch_size)
    full_reread = (not incremental) or since is None
    rebuild = check_schema_drift(spark, row, path, source,
                                 allow_narrowing=allow_narrowing, full_reread=full_reread)

    frame = add_audit_columns(source, row, load_date).cache()
    rows_read = frame.count()          # a count, never a sample (rule 7)

    if rows_read == 0:
        LOG.info("[%s] no new rows", row.source_table)
        frame.unpersist()
        return LoadOutcome(row.source_table, row.load_mode, 0,
                           (datetime.now(timezone.utc) - started).total_seconds())

    # A rebuild must overwrite: neither append nor merge can remove a column from
    # a Delta table. Passing incremental=False takes write_bronze's overwrite
    # branch, which already sets overwriteSchema.
    write_bronze(spark, row, path, frame,
                 incremental and since is not None and not rebuild)
    # Only after a successful write: a crash must not advance the watermark past
    # rows that never landed, which would skip them permanently.
    if incremental:
        record_high_water_mark(spark, row, frame)
    frame.unpersist()
    return LoadOutcome(row.source_table, row.load_mode, rows_read,
                       (datetime.now(timezone.utc) - started).total_seconds())


# -----------------------------------------------------------------------------
# entry point
# -----------------------------------------------------------------------------
def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Load allowlisted source tables into bronze.")
    parser.add_argument("--control-table", type=Path, required=True,
                        help="e.g. /opt/jobs/control_table_esukh.csv - one per source system")
    parser.add_argument("--exceptions", type=Path, default=None)
    parser.add_argument("--source-system", required=True)
    parser.add_argument("--tables", nargs="*", default=[],
                        help="subset of control table rows; cannot add anything to them")
    parser.add_argument("--load-date", type=date.fromisoformat, default=None,
                        help="partition date (default: today, UTC)")
    parser.add_argument("--fetch-size", type=int, default=10_000)
    parser.add_argument("--dry-run", action="store_true",
                        help="validate and print the plan; no database, no Spark")
    parser.add_argument("--insecure-no-tls", action="store_true",
                        help="local synthetic-data testing only")
    parser.add_argument("--reset-watermark", action="store_true",
                        help="forget the stored watermark for the named --tables so this run "
                             "re-reads them in full. Needed whenever a COLUMN is added to an "
                             "incremental table: without it the new column is only populated "
                             "for rows that changed since the last run, and the table ends up "
                             "holding two different shapes of truth. Requires --tables.")
    parser.add_argument("--allow-narrowing", action="store_true",
                        help="permit an allowlist that DROPS columns bronze already holds, by "
                             "rebuilding the table without them. Use when an owner withdrew "
                             "columns. Refuses a retyped column, and refuses unless the table "
                             "is read in full (see check_schema_drift).")
    args = parser.parse_args(argv)

    # Deliberately refused without --tables: a blanket reset would re-read every
    # table in the system, and esukh.monthlypayment alone is ~16.5M rows.
    if args.reset_watermark and not args.tables:
        parser.error("--reset-watermark requires --tables: name the tables to re-read in full")

    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)-7s %(message)s")
    exceptions = (args.exceptions if args.exceptions is not None
                  else args.control_table.with_name("control_table_exceptions.csv"))
    load_date: date = args.load_date or datetime.now(timezone.utc).date()

    try:
        plan = load_plan(args.control_table, exceptions, args.source_system, args.tables)
    except LoadError as exc:
        LOG.error("%s", exc)
        return 1

    LOG.info("%d table(s) to load, _load_date=%s", len(plan), load_date.isoformat())
    for row in plan:
        LOG.info("  %-34s %-11s %-11s cols=%-3d pk=%-14s wm=%s",
                 row.source_table, row.target_layer, row.load_mode,
                 len(row.columns_allowlist), row.primary_key or "-",
                 row.watermark_column or "-")
    if args.dry_run:
        LOG.info("dry run - nothing read, nothing written")
        return 0

    try:
        connection = connection_from_env(args.source_system,
                                         require_tls=not args.insecure_no_tls)
    except LoadError as exc:
        LOG.error("%s", exc)
        return 1

    LOG.info("connecting to %s as %s", connection.redacted_url, connection.user)
    spark = build_spark(f"load_bronze:{args.source_system}")
    if args.reset_watermark:
        forget_watermarks(spark, args.source_system, [r.source_table for r in plan])
    outcomes: list[LoadOutcome] = []
    failures: list[str] = []
    try:
        for row in plan:
            try:
                outcomes.append(load_table(spark, connection, row, load_date, args.fetch_size,
                                           allow_narrowing=args.allow_narrowing,
                                           watermark_was_reset=args.reset_watermark))
            except Exception as exc:                     # noqa: BLE001 - one bad table
                # must not abort the remaining tables; the run still fails.
                LOG.error("[%s] FAILED: %s", row.source_table, exc)
                failures.append(row.source_table)
    finally:
        spark.stop()

    total = sum(o.rows_read for o in outcomes)
    LOG.info("loaded %d/%d table(s), %d row(s) total", len(outcomes), len(plan), total)
    for outcome in sorted(outcomes, key=lambda o: -o.seconds)[:10]:
        LOG.info("  %-34s %-11s %8d rows  %6.1fs",
                 outcome.table, outcome.mode, outcome.rows_read, outcome.seconds)
    if failures:
        LOG.error("%d table(s) failed: %s", len(failures), ", ".join(failures))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
