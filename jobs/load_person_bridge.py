#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/load_person_bridge.py                     NEW FILE 2026-10-14
#
# Loads the shared-person bridges built by /home/developer/dbbackup/person_link.sh:
#   <dir>/sma_user_person.csv   -> /lake/silver/sma_user_person   (userId, personId)
#   <dir>/esukh_user_person.csv -> /lake/silver/esukh_user_person (userId, personId)
# Both columns are tokens: userId in the system's own 'userId' namespace (joins
# silver.sma_users.id / esukh userId columns), personId in the shared ('shared',
# 'person') namespace. No phone, hash or natural value is in either file.
# Full overwrite: the bridge is recomputed from the source each night.
# =============================================================================
from __future__ import annotations
import argparse
import logging
import sys
from pathlib import Path

LOG = logging.getLogger("load_person_bridge")
UUID = r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True, type=Path)
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(levelname)-7s %(message)s")
    from pyspark.sql import SparkSession, functions as F
    spark = SparkSession.builder.appName("load_person_bridge").enableHiveSupport().getOrCreate()
    spark.sparkContext.setLogLevel("WARN")
    try:
        for system in ("sma", "esukh"):
            src = args.dir / f"{system}_user_person.csv"
            if not src.is_file():
                LOG.info("%s: no bridge file - skipped", system); continue
            df = spark.read.option("header", True).csv(str(src))
            if df.columns != ["userId", "personId"]:
                raise SystemExit(f"error: {src.name} columns {df.columns}")
            bad = df.filter(~F.col("userId").rlike(UUID) | ~F.col("personId").rlike(UUID)).count()
            if bad:
                raise SystemExit(f"error: {src.name}: {bad} row(s) are not token pairs - nothing loaded")
            target = f"/lake/silver/{system}_user_person"
            df.dropDuplicates(["userId"]).write.format("delta").mode("overwrite") \
                .option("overwriteSchema", "true").save(target)
            spark.sql(f"CREATE TABLE IF NOT EXISTS silver.{system}_user_person USING delta LOCATION '{target}'")
            LOG.info("wrote %d row(s) to %s", spark.read.format("delta").load(target).count(), target)
    finally:
        spark.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
