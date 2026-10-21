#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/tokenize_silver.py                                NEW FILE
#
# N4: bronze -> silver. Replaces identifying values with tokens, bands exact
# timestamps, and drops what cannot be coarsened, per jobs/transform_rules.csv.
#
# NOT NAMED tokenize.py. That shadows Python's stdlib `tokenize` module: a
# script's own directory goes on sys.path first, and stdlib `linecache` ->
# `traceback` -> `logging` all import `tokenize`, so `import logging` explodes
# before main() is reached. CLAUDE.md's N4 spec says jobs/tokenize.py; it cannot
# be called that.
#
# WHY A RULES FILE. The control table says which columns may be COPIED; it has
# no field for what to DO with them. Inferring treatment from column names would
# be the wrong risk: filtering fails safe (an over-blocked column costs a review)
# but tokenising fails UNSAFE - misclassify propertyId as passthrough and an
# untokenised dwelling identifier reaches silver, then gold, then Power BI, and
# cannot be unpublished. So every allowlisted column must have an explicit rule
# and THIS JOB REFUSES TO RUN if any is missing.
#
# TREATMENTS
#   token        -> UUID from the token map, per source_system. Same input always
#                   yields the same token within a system; never across systems.
#   time_band    -> truncated to the hour (policy: day + hour band).
#   passthrough  -> copied unchanged. Only for values that identify nobody.
#   drop         -> omitted from silver entirely.
#
# PER-SYSTEM BY DEFAULT. The token map's key includes source_system, so the same
# plate in esukh and parkly gets different tokens and cannot be joined across
# them. Cross-system linking is a data-officer decision (section 9).
#
# MERGE, NEVER OVERWRITE. Bronze holds at most 24h of data and incremental loads
# put only the delta there, so overwriting silver would delete every row bronze
# no longer carries. Silver is the durable layer.
#
# Run:
#   docker compose --profile jobs run --rm spark-jobs \
#     /opt/spark/bin/spark-submit /opt/jobs/tokenize_silver.py --source-system esukh
#
# Credentials from the environment: TOKENMAP_DB_{URL,USER,PASSWORD}. The vault
# choice (Vault vs sops/age) is still open - section 9 - so this is the same
# interim arrangement as the metastore and must move with it.
#
# Logs counts and column names only, never values (rule 7).
# =============================================================================
from __future__ import annotations

import argparse
import csv
import logging
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Final, Sequence

LOG: Final[logging.Logger] = logging.getLogger("tokenize")

BRONZE: Final[str] = "/lake/bronze"
BRONZE_REF: Final[str] = "/lake/bronze-ref"   # non-PII tables land here since 2026-10-06
SILVER: Final[str] = "/lake/silver"

def _last_commit(path: str) -> float:
    logs = list(Path(f"{path}/_delta_log").glob("*.json"))
    return max((f.stat().st_mtime for f in logs), default=0.0)


def source_path(table: str) -> str | None:
    """Where the loader put this table: bronze (PII) or bronze-ref (non-PII).
    Silver carries both so analysts see one complete layer.

    2026-10-14: a table whose target_layer changed has a STALE copy left in the
    other layer (a "layer orphan", claude.md 5i/5j), still carrying columns the
    owner has since withdrawn. "bronze first" then read the stale copy and the
    run failed on columns with no transform rule (10 esukh tables). Now: the copy
    with the most recent commit is the live one; the other is logged, never read."""
    found = [f"{base}/{table}" for base in (BRONZE, BRONZE_REF)
             if Path(f"{base}/{table}/_delta_log").is_dir()]
    if not found:
        return None
    live = max(found, key=_last_commit)
    for stale in (p for p in found if p != live):
        LOG.warning("[%s] stale copy in %s ignored (live copy: %s) - layer orphan, clean up",
                    table, stale.rsplit("/", 1)[0], live.rsplit("/", 1)[0])
    return live
AUDIT: Final[tuple[str, ...]] = ("_ingested_at", "_load_date", "_source")
TREATMENTS: Final[frozenset[str]] = frozenset({"token", "time_band", "passthrough", "drop"})


class TokenizeError(RuntimeError):
    pass


@dataclass(frozen=True)
class Rule:
    column: str
    treatment: str
    entity: str = ""   # token namespace override; "" = use the column name


@dataclass(frozen=True)
class Outcome:
    table: str
    rows: int
    tokenised: int
    banded: int
    dropped: int
    seconds: float
    error: str = ""

    @property
    def ok(self) -> bool:
        return not self.error


def load_rules(path: Path, source_system: str) -> dict[str, list[Rule]]:
    if not path.is_file():
        raise TokenizeError(f"missing {path} - every allowlisted column needs a treatment")
    out: dict[str, list[Rule]] = {}
    bad: list[str] = []
    with path.open(newline="", encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            if (row.get("source_system") or "").strip().lower() != source_system.lower():
                continue
            t = (row.get("treatment") or "").strip()
            if t not in TREATMENTS:
                bad.append(f"{row.get('source_table')}.{row.get('column')} -> '{t}'")
                continue
            out.setdefault(row["source_table"], []).append(
                Rule(row["column"].strip(), t, (row.get("entity") or "").strip()))
    if bad:
        raise TokenizeError(f"unknown treatment(s), must be one of {sorted(TREATMENTS)}: {bad[:5]}")
    if not out:
        raise TokenizeError(f"no transform rules for source_system '{source_system}'")
    return out


def tokenmap_conn(spark):
    """A JDBC connection via the JVM - no python driver is installed in this image."""
    missing = [v for v in ("TOKENMAP_DB_URL", "TOKENMAP_DB_USER", "TOKENMAP_DB_PASSWORD")
               if not os.environ.get(v)]
    if missing:
        raise TokenizeError(f"missing environment variables: {', '.join(missing)}")
    props = spark._jvm.java.util.Properties()
    props.setProperty("user", os.environ["TOKENMAP_DB_USER"])
    props.setProperty("password", os.environ["TOKENMAP_DB_PASSWORD"])
    return spark._jvm.java.sql.DriverManager.getConnection(os.environ["TOKENMAP_DB_URL"], props)


def mint_tokens(spark, source_system: str, entity_type: str, values_df) -> None:
    """Bulk-insert any unseen natural values, so every one has a token.

    Staging table then INSERT .. ON CONFLICT DO NOTHING, which is why the job
    needs no UPDATE on token_map: a token, once minted, never changes.
    """
    url = os.environ["TOKENMAP_DB_URL"]
    (values_df.selectExpr(f"'{source_system}' as source_system",
                          f"'{entity_type}' as entity_type",
                          "cast(v as string) as natural_value")
        .write.format("jdbc").option("url", url)
        .option("dbtable", "token_stage")
        .option("user", os.environ["TOKENMAP_DB_USER"])
        .option("password", os.environ["TOKENMAP_DB_PASSWORD"])
        .option("driver", "org.postgresql.Driver")
        .mode("append").save())
    conn = tokenmap_conn(spark)
    try:
        st = conn.createStatement()
        st.execute(
            "INSERT INTO token_map (source_system, entity_type, natural_value) "
            "SELECT DISTINCT source_system, entity_type, natural_value FROM token_stage "
            "ON CONFLICT (source_system, entity_type, natural_value) DO NOTHING")
        st.execute("DELETE FROM token_stage")
        st.close()
    finally:
        conn.close()


def read_map(spark, source_system: str, entity_type: str):
    url = os.environ["TOKENMAP_DB_URL"]
    q = (f"(SELECT natural_value, token FROM token_map "
         f"WHERE source_system = '{source_system}' AND entity_type = '{entity_type}') AS m")
    return (spark.read.format("jdbc").option("url", url).option("dbtable", q)
            .option("user", os.environ["TOKENMAP_DB_USER"])
            .option("password", os.environ["TOKENMAP_DB_PASSWORD"])
            .option("driver", "org.postgresql.Driver").load())


def transform(spark, source_system: str, table: str, rules: list[Rule]) -> Outcome:
    from delta.tables import DeltaTable
    from pyspark.sql import functions as F

    started = datetime.now(timezone.utc)
    bronze_path = source_path(table)
    if bronze_path is None or not DeltaTable.isDeltaTable(spark, bronze_path):
        return Outcome(table, 0, 0, 0, 0, 0.0, error="not a Delta table in bronze or bronze-ref")

    df = spark.read.format("delta").load(bronze_path)
    present = set(df.columns)
    by_treatment: dict[str, list[str]] = {}
    for r in rules:
        if r.column in present:
            by_treatment.setdefault(r.treatment, []).append(r.column)

    # Refuse on any allowlisted column with no rule - see the header.
    ruled = {r.column for r in rules} | set(AUDIT)
    unruled = sorted(present - ruled)
    if unruled:
        return Outcome(table, 0, 0, 0, 0,
                       (datetime.now(timezone.utc) - started).total_seconds(),
                       error=f"columns present in bronze with no transform rule: {unruled[:6]}")

    out = df
    for col in by_treatment.get("drop", []):
        out = out.drop(col)
    for col in by_treatment.get("time_band", []):
        out = out.withColumn(col, F.date_trunc("hour", F.col(col)))
    # entity_type defaults to the column name, which scopes tokens per field. A
    # rule may override it with an `entity` alias, and must whenever two columns
    # denote the SAME thing: sma.Users.id and sma.UserCars.userId are both "that
    # user", so both carry entity=userId and get the identical token. Without the
    # alias a person table's own primary key would mint a second, unjoinable
    # token for someone who already has one (2026-10-08).
    entity_of = {r.column: (r.entity or r.column) for r in rules}
    for col in by_treatment.get("token", []):
        entity = entity_of.get(col, col)
        distinct = out.select(F.col(col).cast("string").alias("v")).where("v is not null").distinct()
        if distinct.head(1):
            mint_tokens(spark, source_system, entity, distinct)
            m = read_map(spark, source_system, entity).withColumnRenamed("token", f"__tok_{col}")
            out = (out.join(m, out[col].cast("string") == m["natural_value"], "left")
                      .drop("natural_value").drop(col)
                      .withColumnRenamed(f"__tok_{col}", col))
        else:
            out = out.withColumn(col, F.lit(None).cast("string"))

    out = out.withColumn("_tokenised_at", F.lit(datetime.now(timezone.utc)))
    rows = out.count()

    silver_path = f"{SILVER}/{table}"
    key = "id" if "id" in out.columns else None
    if key and DeltaTable.isDeltaTable(spark, silver_path):
        (DeltaTable.forPath(spark, silver_path).alias("t")
            .merge(out.alias("s"), f"t.`{key}` = s.`{key}`")
            .whenMatchedUpdateAll().whenNotMatchedInsertAll().execute())
    else:
        # First write only. Never overwrite an existing silver table: bronze holds
        # at most 24h, so an overwrite would delete everything bronze has dropped.
        (out.write.format("delta").mode("append" if key else "overwrite")
            .option("mergeSchema", "true").save(silver_path))

    return Outcome(table, rows, len(by_treatment.get("token", [])),
                   len(by_treatment.get("time_band", [])), len(by_treatment.get("drop", [])),
                   (datetime.now(timezone.utc) - started).total_seconds())


def build_spark():
    from pyspark.sql import SparkSession

    # autoMerge (2026-10-09): without it, MERGE's updateAll/insertAll SILENTLY
    # DROPS a column that bronze has gained - no error, no warning, the column
    # simply never appears in silver. That is how esukh.reference.name and
    # .shortname went missing: bronze had them after the reload, every tokenise
    # run reported success, and silver stayed 12 columns wide, leaving every
    # coded esukh column (propertyType, subType, serviceType...) unresolvable.
    # It only ever ADDS a column, so it cannot widen past the allowlist: the
    # columns reaching it are exactly the allowlisted ones load_bronze copied.
    return (SparkSession.builder.appName("tokenize")
            .config("spark.databricks.delta.schema.autoMerge.enabled", "true")
            .enableHiveSupport().getOrCreate())


def main(argv: Sequence[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Tokenise bronze into silver (N4).")
    ap.add_argument("--source-system", required=True)
    ap.add_argument("--rules", type=Path, default=Path("/opt/jobs/transform_rules.csv"))
    ap.add_argument("--tables", nargs="*", default=[])
    ap.add_argument("--dry-run", action="store_true", help="print the plan; no Spark, no writes")
    args = ap.parse_args(argv)
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)-7s %(message)s")

    try:
        rules = load_rules(args.rules, args.source_system)
    except TokenizeError as exc:
        LOG.error("%s", exc)
        return 2

    prefix = f"{args.source_system.lower()}_"
    wanted = {t.lower() for t in args.tables}
    plan = {f"{prefix}{t.lower()}": rs for t, rs in rules.items()
            if not wanted or t.lower() in wanted}
    LOG.info("%d table(s) with rules for '%s'", len(plan), args.source_system)
    if args.dry_run:
        for t, rs in sorted(plan.items()):
            counts: dict[str, int] = {}
            for r in rs:
                counts[r.treatment] = counts.get(r.treatment, 0) + 1
            LOG.info("  %-42s %s", t, counts)
        return 0

    spark = build_spark()
    results: list[Outcome] = []
    try:
        for table, rs in sorted(plan.items()):
            if source_path(table) is None:
                continue            # not loaded in this run
            try:
                results.append(transform(spark, args.source_system, table, rs))
            except Exception as exc:                      # noqa: BLE001
                LOG.error("[%s] FAILED: %s", table, str(exc).splitlines()[0][:200])
                results.append(Outcome(table, 0, 0, 0, 0, 0.0, error=str(exc)[:200]))
            finally:
                # One Spark session tokenises up to 166 tables; Delta snapshot and
                # block caches accumulate across them and on 2026-10-06 the esukh run
                # died mid-way with SparkOutOfMemoryError (UNABLE_TO_ACQUIRE_MEMORY),
                # silently skipping every table after it. Drop caches between tables.
                try:
                    spark.catalog.clearCache()
                except Exception:                         # noqa: BLE001
                    pass
    finally:
        spark.stop()

    good = [r for r in results if r.ok]
    bad = [r for r in results if not r.ok]
    LOG.info("tokenised %d/%d table(s), %d row(s) into silver",
             len(good), len(results), sum(r.rows for r in good))
    for r in sorted(good, key=lambda x: -x.rows)[:10]:
        LOG.info("  %-42s %8d rows  tokens=%-3d banded=%-3d", r.table, r.rows, r.tokenised, r.banded)
    for r in bad:
        LOG.error("  %-42s FAILED: %s", r.table, r.error)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
