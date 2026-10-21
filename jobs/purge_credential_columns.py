# =============================================================================
# hti-platform/jobs/purge_credential_columns.py                  ONE-OFF, 2026-10-14
#
# Removes credential columns (device/router passwords, API signatures) from the
# lake tables that held them in plaintext. Dropping the column is NOT enough with
# Delta: every commit in _delta_log keeps min/max STATISTICS per column, so the
# values stay readable in the log, and old data files stay readable by time
# travel. So each table is rebuilt as a NEW Delta table with a fresh log:
#   1. read the current version, select every column except the credentials
#   2. write it to /lake/_purge_tmp/<layer>/<table>, verify row count + schema
#   3. delete the original directory (data files AND _delta_log)
#   4. write the verified copy back to the original path, verify again
#   5. delete the temp copy
# Same rows, same partitioning; history before today is gone ON PURPOSE.
# Approved by the platform owner 2026-10-14.
#
# Run (nothing else may write these tables meanwhile):
#   docker compose --profile jobs run --rm spark-jobs \
#     /opt/spark/bin/spark-submit /opt/jobs/purge_credential_columns.py [--dry-run]
#
# Logs counts and column NAMES only, never values.
# =============================================================================
from __future__ import annotations

import argparse
import logging
import shutil
import sys

LOG = logging.getLogger("purge_credentials")

CREDENTIALS = {"pass", "addSignature", "deleteSignature", "selectSignature",
               "getRecordSignature", "routerPass", "anydeskPass"}
TABLES = ["bronze/esukh_camera", "bronze/parkly_camera", "bronze/parkly_routerconfig",
          "silver/esukh_camera", "silver/parkly_camera", "silver/parkly_routerconfig"]
LAKE = "/lake"
TMP = f"{LAKE}/_purge_tmp"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    from pyspark.sql import SparkSession
    from delta.tables import DeltaTable
    spark = SparkSession.builder.appName("purge_credentials").getOrCreate()
    spark.sparkContext.setLogLevel("WARN")   # Delta INFO lines can print column stats

    failed = 0
    for rel in TABLES:
        path, tmp = f"{LAKE}/{rel}", f"{TMP}/{rel}"
        if not DeltaTable.isDeltaTable(spark, path):
            LOG.info("[%s] not a Delta table - skipped", rel)
            continue
        df = spark.read.format("delta").load(path)
        drop = sorted(set(df.columns) & CREDENTIALS)
        parts = DeltaTable.forPath(spark, path).detail().collect()[0]["partitionColumns"]
        n = df.count()
        LOG.info("[%s] rows=%d partitions=%s dropping=%s", rel, n, parts, drop)
        if not drop or args.dry_run:
            continue

        def write(frame, dest):
            w = frame.write.format("delta").mode("overwrite")
            if parts:
                w = w.partitionBy(*parts)
            w.save(dest)

        def verify(dest) -> bool:
            back = spark.read.format("delta").load(dest)
            left = sorted(set(back.columns) & CREDENTIALS)
            ok = back.count() == n and not left
            LOG.info("[%s] verify %s: rows=%d credential_cols=%s -> %s",
                     rel, dest, back.count(), left, "OK" if ok else "FAILED")
            return ok

        shutil.rmtree(tmp, ignore_errors=True)
        write(df.drop(*drop), tmp)
        if not verify(tmp):
            LOG.error("[%s] temp copy failed verification - original left untouched", rel)
            failed += 1
            continue
        shutil.rmtree(path)                      # data files + _delta_log: credentials gone
        write(spark.read.format("delta").load(tmp), path)
        if not verify(path):
            LOG.error("[%s] rebuilt table failed verification - verified copy kept at %s", rel, tmp)
            failed += 1
            continue
        shutil.rmtree(tmp)
        LOG.info("[%s] rebuilt without %s", rel, drop)
    if not failed:
        shutil.rmtree(TMP, ignore_errors=True)
    LOG.info("done: %d table(s) failed", failed)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
