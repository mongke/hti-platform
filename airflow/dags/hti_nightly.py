"""N8 - nightly HTI pipeline: load -> tokenize -> dbt -> export -> vacuum.

Two things about this DAG are deliberate and should not be "tidied up".

1. THE UNBUILT STEPS FAIL, THEY DO NOT PASS.
   N4 (tokenize), N6 (dbt) and N7 (export) do not exist yet. Each is present as a
   task that raises. A DAG that went green while skipping tokenisation would be
   worse than no DAG at all: it would report success while personal data sat
   untokenised in bronze, and the first person to see the green run would
   reasonably conclude the pipeline was working.

2. VACUUM RUNS EVEN WHEN THE LOAD FAILS (TriggerRule.ALL_DONE), BUT IT IS NOT
   THE ONLY LEAF. Airflow derives a run's state from its leaf tasks. With vacuum
   chained last under ALL_DONE it became the sole leaf, so its success marked the
   whole run GREEN while the load had failed and nothing was copied - the exact
   silent-green failure this DAG exists to prevent. `pipeline_ok` is therefore a
   second leaf under ALL_SUCCESS: it turns the run red if anything upstream
   failed, while vacuum still always runs. Do not remove it.
   Retention is a legal obligation, not a step in a happy path. If the load
   breaks at 02:00, yesterday's personal data must still be deleted at 04:00.
   Tying the vacuum to upstream success would mean a broken loader silently
   suspends deletion - exactly the failure that turns an outage into a breach.

Loads are driven through the platform's own compose file rather than a
DockerOperator, so mounts, entrypoint and credentials stay defined once in
../docker-compose.yml.

Nothing here can actually load until the data officer assigns purpose_ref:
load_bronze.py refuses a control table with validation errors, so today every
load task fails fast with CT013. That is the intended state, not a bug.
"""
from __future__ import annotations

import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.exceptions import AirflowFailException
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.trigger_rule import TriggerRule

PLATFORM_DIR = os.environ.get("PLATFORM_DIR", "/platform")

# Gold (N6 dbt marts, N7 serving export) is PARKED since 2026-10-14: silver is the
# deliverable for now (the MCP server reads silver). With False the two placeholder
# tasks are not in the graph at all, and the run is green when every load and
# tokenise succeeded (silver) and bronze retention was enforced (vacuum).
# Set True once N6/N7 exist; their placeholders fail on purpose until then.
GOLD_ENABLED: bool = False

# Every system is restored nightly by /home/developer/dbbackup/nightly_sources.sh
# (2026-10-14): esukh, parkly, myproperty, smartpay. sma is in the chain but its pull
# fails until the SMA host authorises our SSH key, so it loads the last restored copy.
# smartpay's source (pg16 on 103.168.56.193) is frozen at 2025-12-08 - nightly, but no
# new rows until the team points us at the live database.
SOURCE_SYSTEMS: tuple[str, ...] = ("esukh", "myproperty", "parkly", "smartpay", "sma")

# Which allowlist each system loads from. PHASE 1: a small subset carrying no
# personal data, with a provisional purpose_ref, so bronze can be proven
# end-to-end (partitioning, the watermark store, and the 24h vacuum actually
# deleting it) before any significant personal data is loaded.
#
# control_table_esukh.csv - the full 166-table allowlist - is deliberately NOT
# used here: it is the file the data officer is reviewing, every row still has an
# empty purpose_ref, and it includes monthlypayment (16.5M rows of household
# financial history). Point this at it only once it is signed AND N4 exists, or
# bronze fills with personal data that has nowhere to go and is deleted 24h later.
CONTROL_TABLE: dict[str, str] = {
    "esukh": "control_table_esukh_phase1",
    # myproperty phase 1 = the owner's own column-level masking inventory
    # (docs/MyProperty_Data_Masking_Inventory_2026-10-02.xlsx) minus the 14
    # tables still under data-officer review: 12 correspondence tables where
    # they propose keeping metadata after stripping content columns, and 2
    # credential stores. 78 tables, 621 columns.
    "myproperty": "control_table_myproperty_phase1",
    # Added 2026-10-04. parkly = the 27 tables the parkly team classified Normal
    # (table level only - columns are still pattern-derived). smartpay = our
    # pattern filter, no team document exists. sma = the 20 tables in BOTH the
    # sma team's revised list and our 2026-09-30 dump (11 they approved are
    # absent from that dump; they get a fresh one). All PENDING-REVIEW.
    "parkly": "control_table_parkly_phase1",
    "smartpay": "control_table_smartpay_phase1",
    "sma": "control_table_sma_phase1",
}

# Systems whose source is a LOCAL restore on this host's Docker network, where
# TLS is not available: the official postgres image ships with SSL disabled, so
# ssl=true simply fails to connect. These get --insecure-no-tls.
#
# This cannot leak plaintext to a real source. load_bronze.py's own guard accepts
# the flag only for a hostname with no dot - a container name on a Docker network
# - and refuses anything with a dot (a FQDN or an IP), so pointing one of these at
# a production host makes the job fail rather than silently drop encryption.
# Remove the system from this set the moment its source becomes a real server.
LOCAL_INSECURE_SOURCES: frozenset[str] = frozenset({"myproperty", "parkly", "smartpay", "sma"})

DEFAULT_ARGS = {
    "owner": "hti-platform",
    # Retries are for TRANSIENT failures - a source briefly unreachable, a blip.
    # They were 1 x 10 minutes, which meant a deterministic control-table refusal
    # sat idle for ten minutes and then failed identically, burning two Spark
    # container starts to reach the same answer. Short delay, and the preflight
    # below (retries=0) catches the deterministic case in about a second.
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
    "depends_on_past": False,
    "email_on_failure": False,          # wire to the real alert channel at N8 sign-off
}


def _compose(job: str, *args: str, driver_memory: str = "2g") -> str:
    """A spark-submit through the platform's compose project."""
    quoted = " ".join(f"'{a}'" for a in args)
    return (
        f"cd {PLATFORM_DIR} && "
        f"docker compose --profile jobs run --rm spark-jobs "
        f"/opt/spark/bin/spark-submit --driver-memory {driver_memory} /opt/jobs/{job} {quoted}"
    )


def _not_built(piece: str, what: str):
    def _raise(**_):
        raise AirflowFailException(
            f"{piece} is not built: {what}. This task fails on purpose - a green run "
            f"here would mean the pipeline reported success while skipping it."
        )
    return _raise


with DAG(
    dag_id="hti_nightly",
    description="Load allowlisted source tables to bronze, tokenise, build marts, export, vacuum",
    default_args=DEFAULT_ARGS,
    # No cron schedule since 2026-10-06: /home/developer/dbbackup/nightly_sources.sh
    # (root cron 04:10 UTC) pulls the remote backups, restores them into the local
    # source databases and then triggers this DAG, so bronze is always loaded from
    # the freshly restored copy. Trigger by hand: airflow/pipeline.sh trigger.
    schedule=None,
    # Must be in the PAST. A future start_date makes every run - including a
    # manual trigger - produce ZERO task instances and finish "success" in
    # milliseconds: a green run that executed nothing, which is the exact
    # failure this DAG is written to prevent. Caught 2026-09-30 when the first
    # trigger "succeeded" in 40ms with an empty task_instance table.
    start_date=datetime(2026, 9, 1),
    catchup=False,                        # never backfill: bronze holds PII for 24h only
    max_active_runs=1,                    # two concurrent loads would race the same tables
    # LocalExecutor runs independent tasks in parallel. With five source systems
    # that is five Spark containers (~1.2 GB each) starting together on a 7.9 GB
    # host - the parkly load on 2026-10-04 died silently that way while a vacuum
    # was still running. Two at a time fits alongside thrift + the databases.
    # 2026-10-06 evening: driver heap raised to 2 GB (G15) so two parallel jobs would be
    # ~5 GB RSS on an 8 GB host - run ONE task at a time until the host has 16 GB.
    max_active_tasks=1,
    tags=["hti", "bronze", "pii"],
) as dag:

    # Preflight. validate_control_table.py is stdlib-only and jobs/ is already
    # mounted here, so this runs IN the Airflow container in about a second - no
    # Spark, no image pull. It fails the run immediately on an unsigned or
    # invalid control table instead of discovering it minutes later inside a
    # Spark job, and retrying it would be pointless: the answer cannot change
    # between attempts.
    validate = BashOperator(
        task_id="validate_control_tables",
        retries=0,
        bash_command=" && ".join(
            f"python3 {PLATFORM_DIR}/jobs/validate_control_table.py "
            f"{PLATFORM_DIR}/jobs/{CONTROL_TABLE[s]}.csv "
            f"--exceptions {PLATFORM_DIR}/jobs/{CONTROL_TABLE[s]}_exceptions.csv"
            for s in SOURCE_SYSTEMS
        ),
    )

    load_tasks = []
    for system in SOURCE_SYSTEMS:
        load_tasks.append(BashOperator(
            task_id=f"load_bronze_{system}",
            bash_command=_compose(
                "load_bronze.py",
                "--control-table", f"/opt/jobs/{CONTROL_TABLE[system]}.csv",
                "--exceptions", f"/opt/jobs/{CONTROL_TABLE[system]}_exceptions.csv",
                "--source-system", system,
                # 2026-10-14: an owner NARROWING their allowlist applies instead of turning
                # the run red. load_bronze.py still refuses a retyped column and any overwrite
                # of a table that was not read in full (check_schema_drift).
                "--allow-narrowing",
                *(("--insecure-no-tls",) if system in LOCAL_INSECURE_SOURCES else ()),
            ),
        ))

    # N4, built 2026-10-02 as jobs/tokenize_silver.py - NOT tokenize.py, which
    # shadows Python's stdlib tokenize module and breaks `import logging`.
    # One task per system, each depending only on its own load: a broken esukh
    # load must not stop myproperty being tokenised, because anything left in
    # bronze untokenised is deleted by the vacuum within 24h.
    tokenize_tasks = []
    for system in SOURCE_SYSTEMS:
        tokenize_tasks.append(BashOperator(
            task_id=f"tokenize_silver_{system}",
            bash_command=_compose(
                "tokenize_silver.py",
                "--source-system", system,
                "--rules", "/opt/jobs/transform_rules.csv",
                # 3g since 2026-10-16: the silver MERGE ran out of 2g heap on large esukh
                # tables (esukh_vat). One task runs at a time; 3g + Thrift 3g still fits
                # the 7.8 GB host without leaning on swap.
                driver_memory="3g",
            ),
        ))

    if GOLD_ENABLED:
        dbt_build = PythonOperator(
            task_id="dbt_build",
            python_callable=_not_built("N6", "no dbt project - staging views, marts, snapshots and tests"),
        )
        export_serving = PythonOperator(
            task_id="export_serving",
            python_callable=_not_built("N7", "no serving Postgres and no gold export job"),
        )

    # Added 2026-10-16. Silver keeps a column after the owner withdraws it: the
    # loader narrows bronze (--allow-narrowing) but MERGE never drops a silver column.
    # On 10-16 that had piled up to 189 withdrawn columns in 68 esukh tables (raw
    # payment payloads, bank accounts, plates, IPs) and the MERGE ran out of heap.
    # This step removes, per silver table, every column that is no longer on its
    # allowlist (all rows kept, verified, old files vacuumed). A no-op when nothing
    # was withdrawn. ALL_DONE: removing withdrawn data is an obligation, like
    # retention, so it runs even if a tokenise step failed.
    drop_withdrawn = BashOperator(
        task_id="drop_withdrawn_silver_columns",
        bash_command=_compose("drop_withdrawn_silver_columns.py"),
        trigger_rule=TriggerRule.ALL_DONE,
        retries=0,
    )

    # ALL_DONE: retention is an obligation, not a reward for a successful load.
    # --retain-hours 0: delete the files the moment the partition is dropped.
    # With the default (24h) every nightly run failed verification - the files
    # from the partition just dropped were only ~2h old, Delta kept them, and the
    # job rightly reported "retention NOT fully enforced" (every night 10-02 to
    # 10-04). The usual objection to 0 is a concurrent reader mid-query; here
    # vacuum is the last serialised step, nothing in the catalog points at
    # bronze, and policy gives humans/BI no route to it anyway. retries=0: a
    # retention failure is deterministic and must be escalated, not retried.
    vacuum = BashOperator(
        task_id="vacuum_bronze",
        bash_command=_compose("vacuum_bronze.py", "--retain-hours", "0"),
        trigger_rule=TriggerRule.ALL_DONE,
        retries=0,
    )

    # Second leaf, ALL_SUCCESS. Exists solely so the DAG run turns red when any
    # step failed. Without it, vacuum's success (which is correct and must not
    # be made conditional) would report the whole run green after a failed load.
    # It must NOT be chained after vacuum - see the wiring note at the bottom.
    def _pipeline_ok(**_):
        return "all steps succeeded"

    pipeline_ok = PythonOperator(
        task_id="pipeline_ok",
        python_callable=_pipeline_ok,
        trigger_rule=TriggerRule.ALL_SUCCESS,
    )

    # Wiring. vacuum (ALL_DONE) waits for EVERY load/tokenise pair directly: VACUUM
    # RETAIN 0 beside an in-flight write can delete its not-yet-committed files, and
    # ALL_DONE only waits for direct upstreams (2026-10-06).
    # pipeline_ok (ALL_SUCCESS) is the verdict. ALL_SUCCESS only inspects DIRECT
    # upstreams (verified 2026-09-30), so it lists every tokenise task AND vacuum:
    # green = silver complete for every system + bronze retention enforced.
    for load_task, tok_task in zip(load_tasks, tokenize_tasks):
        validate >> load_task >> tok_task
        tok_task >> drop_withdrawn
        tok_task >> vacuum
        tok_task >> pipeline_ok
    drop_withdrawn >> vacuum          # serialised: never two lake writers at once
    drop_withdrawn >> pipeline_ok     # green also requires silver free of withdrawn columns
    vacuum >> pipeline_ok
    if GOLD_ENABLED:
        for tok_task in tokenize_tasks:
            tok_task >> dbt_build
        dbt_build >> export_serving
        export_serving >> vacuum
        export_serving >> pipeline_ok
