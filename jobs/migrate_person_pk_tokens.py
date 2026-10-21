# =============================================================================
# hti-platform/jobs/migrate_person_pk_tokens.py                  ONE-OFF, 2026-10-14
#
# G18/G20 in-place silver migration, approved by the platform owner 2026-10-14.
# Four silver person tables still hold the source system's RAW primary key in `id`
# (integer), while transform_rules.csv now tokenises it. Every nightly tokenise then
# fails (CAST_INVALID_INPUT: a UUID into an int column). A rebuild would destroy
# history (bronze holds 24 h, silver is the system of record), so instead `id` is
# rewritten IN PLACE to the token in the namespace the foreign keys already use:
#
#   esukh.user -> userId    esukh.worker -> workerId
#   myproperty.owner -> ownerId    myproperty.tenant -> tenantId
#
# Same namespace + same natural value = same token, so after this `owner.id` joins
# `rentalagreement.ownerId` etc. Every row is kept; any id without a token is minted
# first (mint_tokens, ON CONFLICT DO NOTHING - existing tokens never change).
#
# Checks: before/after row counts equal, distinct ids equal, no null id, id is a
# string. The previous version stays readable by Delta time travel until
#   --vacuum   (run after the pipeline succeeded) removes the raw-id files for good.
#
# Run:  docker compose --profile jobs run --rm spark-jobs /opt/spark/bin/spark-submit \
#         --driver-memory 2g /opt/jobs/migrate_person_pk_tokens.py [--dry-run | --vacuum]
# Logs counts only, never values.
# =============================================================================
from __future__ import annotations

import argparse
import logging
import sys

sys.path.insert(0, "/opt/jobs")
from tokenize_silver import SILVER, build_spark, mint_tokens, read_map  # noqa: E402

LOG = logging.getLogger("migrate_pk")
TABLES = [("esukh", "user", "userId"), ("esukh", "worker", "workerId"),
          ("myproperty", "owner", "ownerId"), ("myproperty", "tenant", "tenantId")]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--vacuum", action="store_true", help="after success: drop the raw-id versions")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    spark = build_spark()
    spark.sparkContext.setLogLevel("WARN")
    from delta.tables import DeltaTable
    from pyspark.sql import functions as F

    failed = 0
    for system, table, entity in TABLES:
        name = f"{system}_{table}"
        path = f"{SILVER}/{name}"
        if args.vacuum:
            spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")
            spark.sql(f"VACUUM delta.`{path}` RETAIN 0 HOURS")
            LOG.info("[%s] vacuumed: raw-id versions removed", name)
            continue
        df = spark.read.format("delta").load(path)
        id_type = dict(df.dtypes)["id"]
        n, nd = df.count(), df.select("id").distinct().count()
        LOG.info("[%s] rows=%d distinct_id=%d id_type=%s namespace=%s", name, n, nd, id_type, entity)
        if id_type == "string":
            LOG.info("[%s] already tokenised - skipped", name)
            continue
        if args.dry_run:
            continue
        ids = df.select(F.col("id").cast("string").alias("v")).where("v IS NOT NULL").distinct()
        mint_tokens(spark, system, entity, ids)
        m = read_map(spark, system, entity)
        out = (df.withColumn("_v", F.col("id").cast("string"))
                 .join(F.broadcast(m) if nd < 2_000_000 else m, F.col("_v") == F.col("natural_value"), "left")
                 .withColumn("id", F.col("token").cast("string"))
                 .drop("_v", "natural_value", "token")
                 .select(*df.columns))
        out = out.cache()
        unmapped = out.where("id IS NULL").count()
        if out.count() != n or unmapped or out.select("id").distinct().count() != nd:
            LOG.error("[%s] verification FAILED before write (unmapped=%d) - table untouched", name, unmapped)
            failed += 1
            continue
        out.write.format("delta").mode("overwrite").option("overwriteSchema", "true").save(path)
        back = spark.read.format("delta").load(path)
        ok = (back.count() == n and dict(back.dtypes)["id"] == "string"
              and back.where("id IS NULL").count() == 0 and back.select("id").distinct().count() == nd)
        LOG.info("[%s] migrated: rows=%d id_type=%s -> %s", name, back.count(), dict(back.dtypes)["id"],
                 "OK" if ok else "FAILED")
        if not ok:
            DeltaTable.forPath(spark, path).restoreToVersion(
                DeltaTable.forPath(spark, path).history().selectExpr("max(version) - 1").first()[0])
            LOG.error("[%s] restored to previous version", name)
            failed += 1
        out.unpersist()
    LOG.info("done: %d table(s) failed", failed)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
