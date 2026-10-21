# =============================================================================
# hti-platform/jobs/migrate_token_namespace.py                     2026-10-22
#
# Moves token columns of a silver table from their own namespace into another one,
# IN PLACE (G18 follow-up, claude.md "the token namespace is fragmented"). Example:
# esukh.propertyOwnerHistory.currentUserId / prevUserId were minted as namespaces
# "currentUserId" / "prevUserId", so the same person had a different UUID there
# than as userProperty.userId - owner changes could not be joined to owners.
#
# For each (column, old namespace -> new namespace):
#   old token -> natural value (token map, old namespace) -> token in the new
#   namespace (minted first if missing; existing tokens never change).
# Every row is kept. Verified per table: same row count, same number of non-null
# values per column, no value left unmapped; a failed check restores the previous
# version. --vacuum (after the pipeline is green) removes the old-namespace files.
# transform_rules.csv must carry the new namespace in its `entity` column, or the
# next nightly tokenise mints the old namespace again.
#
# Run:  docker compose --profile jobs run --rm spark-jobs /opt/spark/bin/spark-submit \
#         --driver-memory 2g /opt/jobs/migrate_token_namespace.py [--dry-run | --vacuum]
# Logs counts only, never values.
# =============================================================================
from __future__ import annotations

import argparse
import logging
import sys

sys.path.insert(0, "/opt/jobs")
from tokenize_silver import SILVER, build_spark, mint_tokens, read_map  # noqa: E402

LOG = logging.getLogger("migrate_ns")
# table -> system, [(column, old namespace, new namespace)]
MIGRATIONS = {
    "esukh_propertyownerhistory": ("esukh", [("currentUserId", "currentUserId", "userId"),
                                             ("prevUserId", "prevUserId", "userId")]),
}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--vacuum", action="store_true")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    spark = build_spark()
    spark.sparkContext.setLogLevel("WARN")
    from delta.tables import DeltaTable
    from pyspark.sql import functions as F

    failed = 0
    for table, (system, cols) in MIGRATIONS.items():
        path = f"{SILVER}/{table}"
        if args.vacuum:
            spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")
            spark.sql(f"VACUUM delta.`{path}` RETAIN 0 HOURS")
            LOG.info("[%s] vacuumed: old-namespace versions removed", table)
            continue
        df = spark.read.format("delta").load(path)
        n = df.count()
        nonnull = {c: df.where(F.col(c).isNotNull()).count() for c, _, _ in cols}
        LOG.info("[%s] rows=%d non-null=%s", table, n, nonnull)
        out = df
        for col, old_ns, new_ns in cols:
            old = read_map(spark, system, old_ns).select(F.col("token").alias("_old"), F.col("natural_value").alias("_nat"))
            naturals = out.join(old, out[col] == old["_old"], "inner").select(F.col("_nat").alias("v")).distinct()
            if not args.dry_run:
                mint_tokens(spark, system, new_ns, naturals)
            new = read_map(spark, system, new_ns).select(F.col("natural_value").alias("_nat2"), F.col("token").alias("_new"))
            out = (out.join(F.broadcast(old), out[col] == old["_old"], "left")
                      .join(F.broadcast(new), F.col("_nat") == F.col("_nat2"), "left")
                      .withColumn(col, F.when(F.col(col).isNull(), None).otherwise(F.col("_new")))
                      .drop("_old", "_nat", "_nat2", "_new"))
        out = out.select(*df.columns).cache()
        after = {c: out.where(F.col(c).isNotNull()).count() for c, _, _ in cols}
        ok = out.count() == n and after == nonnull
        LOG.info("[%s] mapped: non-null=%s -> %s", table, after, "OK" if ok else "UNMAPPED VALUES")
        if args.dry_run:
            continue
        if not ok:
            LOG.error("[%s] verification FAILED before write - table untouched", table)
            failed += 1
            continue
        version = DeltaTable.forPath(spark, path).history(1).select("version").first()[0]
        out.write.format("delta").mode("overwrite").option("overwriteSchema", "true").save(path)
        back = spark.read.format("delta").load(path)
        if back.count() != n or {c: back.where(F.col(c).isNotNull()).count() for c, _, _ in cols} != nonnull:
            DeltaTable.forPath(spark, path).restoreToVersion(version)
            LOG.error("[%s] post-write check FAILED - restored version %d", table, version)
            failed += 1
            continue
        LOG.info("[%s] migrated OK: rows=%d", table, n)
        out.unpersist()
    LOG.info("done: %d table(s) failed", failed)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
