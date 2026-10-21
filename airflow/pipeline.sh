#!/usr/bin/env bash
# =============================================================================
# hti-platform/airflow/pipeline.sh                                    NEW FILE
#
# One entry point for driving the nightly pipeline by hand. Everything here is
# what the Airflow DAG does on its own at 02:00; this is for running it now,
# running one piece, or seeing what happened.
#
# Usage:  airflow/pipeline.sh <command> [args]
#
#   trigger                 start a full hti_nightly run now (validate -> load x5
#                           -> tokenize x5 -> dbt (fails: N6 unbuilt) -> vacuum)
#   status [N]              last N runs (default 3) with per-task states
#   logs <task> [run_id]    tail the log of a task, latest run unless given
#   pause | unpause         stop / resume the 02:00 schedule
#   validate                run the validator on every phase-1 control table
#   load <system>           load one system's phase-1 tables into bronze, now
#   tokenize <system>       tokenise one system bronze -> silver, now
#   vacuum                  enforce bronze retention now (--retain-hours 0)
#   lake                    table counts per layer and system
#   register                register every Delta table under /lake/bronze, /lake/bronze-ref
#                           and /lake/silver in the catalog (bronze, bronze_ref, silver) and
#                           drop entries whose directory is gone. See the note in the code
#                           about bronze and loopback-only thrift.
#
# Systems: esukh myproperty parkly smartpay sma
# Run from anywhere; paths are absolute. Needs docker access (root or docker group).
# =============================================================================
set -euo pipefail

PLATFORM=/home/developer/hti-platform
AF="docker compose -f $PLATFORM/airflow/docker-compose.yml"
DAG=hti_nightly
SYSTEMS="esukh myproperty parkly smartpay sma"
LOCAL_INSECURE="myproperty parkly smartpay sma"     # local restores, no TLS on the Docker network

usage() { sed -n '/^# Usage:/,/^# ====/p' "$0" | sed 's/^# \{0,1\}//' | sed '$d'; }
need_system() {
  case " $SYSTEMS " in *" ${1:-} "*) ;; *) echo "error: system must be one of: $SYSTEMS" >&2; exit 2;; esac
}
spark_job() {   # spark_job <job.py> [args...]
  docker compose -f "$PLATFORM/docker-compose.yml" --profile jobs run --rm spark-jobs \
    /opt/spark/bin/spark-submit --master 'local[2]' --driver-memory 2g "/opt/jobs/$@" 2>&1 \
    | grep -E 'loaded [0-9]+/|tokenised [0-9]+/|FAILED:|refus|no transform|done:|NOT fully|dropped [0-9]+ partition|Caused by:|WRITE_ANCIENT|OutOfMemory|heap space' \
    | grep -vE 'INFO (Delta|Snapshot|Optimistic|FileScan)|^\s*at ' || true
  # (the summary line, every per-table FAILED line and the root-cause lines; nothing else)
}
sql() { $AF exec -T airflow-db psql -U airflow -d airflow -tAc "$1"; }

case "${1:-}" in
  trigger)
    $AF exec -T airflow-scheduler airflow dags trigger "$DAG" | grep -vE 'deprecat|warn' | tail -2
    echo "run queued - follow with: $0 status" ;;
  status)
    n=${2:-3}
    echo "== last $n runs =="
    sql "select rpad(run_id,45)||' '||rpad(state,9)||' '||coalesce(to_char(start_date,'MM-DD HH24:MI'),'(queued)') from dag_run where dag_id='$DAG' order by start_date desc nulls last limit $n"
    echo "== tasks, latest run =="
    sql "select rpad(task_id,26)||' '||rpad(coalesce(state,'(pending)'),16)||' try '||try_number from task_instance where run_id=(select run_id from dag_run where dag_id='$DAG' and start_date is not null order by start_date desc limit 1) order by task_id" ;;
  logs)
    task=${2:?usage: logs <task> [run_id]}
    run=${3:-$(sql "select run_id from dag_run where dag_id='$DAG' and start_date is not null order by start_date desc limit 1" | tr -d ' ')}
    f=$(ls -t "$PLATFORM/airflow/logs/dag_id=$DAG/run_id=$run/task_id=$task/"*.log 2>/dev/null | head -1)
    [ -n "$f" ] || { echo "no log for task=$task run=$run" >&2; exit 1; }
    echo "== $f =="; grep -vE 'INFO (Delta|Snapshot|Optimistic|FileScan|ShuffleBlock|Executor|TaskSetManager)' "$f" | tail -40 ;;
  pause)   $AF exec -T airflow-scheduler airflow dags pause   "$DAG" | tail -1 ;;
  unpause) $AF exec -T airflow-scheduler airflow dags unpause "$DAG" | tail -1 ;;
  validate)
    for s in $SYSTEMS; do printf '%-11s ' "$s"
      python3 "$PLATFORM/jobs/validate_control_table.py" "$PLATFORM/jobs/control_table_${s}_phase1.csv" \
        --exceptions "$PLATFORM/jobs/control_table_${s}_phase1_exceptions.csv" 2>&1 \
        | grep -oE '[0-9]+ error\(s\), [0-9]+ warning\(s\).*|REJECTED' | head -1; done ;;
  load)
    need_system "${2:-}"; s=$2; extra=""
    case " $LOCAL_INSECURE " in *" $s "*) extra="--insecure-no-tls";; esac
    spark_job load_bronze.py --control-table "/opt/jobs/control_table_${s}_phase1.csv" \
      --exceptions "/opt/jobs/control_table_${s}_phase1_exceptions.csv" --source-system "$s" $extra ;;
  tokenize)
    need_system "${2:-}"
    spark_job tokenize_silver.py --source-system "$2" --rules /opt/jobs/transform_rules.csv ;;
  vacuum)  spark_job vacuum_bronze.py --retain-hours 0 ;;
  lake)
    for L in bronze bronze-ref silver; do for s in $SYSTEMS; do
      printf '  %-10s %-11s %3s tables\n' "$L" "$s" "$(find /srv/hti-lake/$L -maxdepth 1 -mindepth 1 -type d -name "${s}_*" 2>/dev/null | wc -l)"; done; done ;;
  register)
    # Registers every Delta table under /lake/{bronze,bronze-ref,silver} in the catalog
    # (databases bronze, bronze_ref, silver) so DBeaver / thrift / dbt see them.
    # bronze is included since 2026-10-06 at the operator's request: thrift binds to
    # 127.0.0.1 only, so anyone who can reach it already has a shell on this host and
    # could read /lake/bronze directly - registration adds no access. Revisit before
    # thrift is ever exposed beyond loopback or given external users (policy §4).
    sql_parts=""; n=0
    for L in bronze bronze-ref silver; do db=${L//-/_}
      for d in /srv/hti-lake/$L/*/; do t=$(basename "$d")
        # a _delta_log with no commit yet (write in progress or failed) is not a table; one such
        # entry aborted the whole batch on 2026-10-06 (DELTA_CREATE_EXTERNAL_TABLE_WITHOUT_TXN_LOG)
        ls "$d/_delta_log/"*.json >/dev/null 2>&1 || continue
        sql_parts="$sql_parts CREATE TABLE IF NOT EXISTS $db.\`$t\` USING DELTA LOCATION '/lake/$L/$t';"; n=$((n+1)); done; done
    [ "$n" -gt 0 ] || { echo "no Delta tables on disk"; exit 0; }
    # --force=true: keep going past a failing statement instead of silently skipping the rest
    docker compose -f "$PLATFORM/docker-compose.yml" exec -T spark-thrift /opt/spark/bin/beeline -u jdbc:hive2://localhost:10000 \
      --force=true -e "$sql_parts" 2>&1 | grep -E '^Error' | cut -c1-160 | sed 's/^/  /' || true   # grep=1 on "no errors" + pipefail would kill the script
    echo "registered/confirmed $n table(s) across bronze, bronze_ref, silver"
    # Drop catalog entries whose Delta directory is gone (table moved between layers or deleted).
    docker exec hti-platform-metastore-db-1 psql -U metastore -d metastore -tAc \
      "select d.\"NAME\"||'.'||t.\"TBL_NAME\" from \"TBLS\" t join \"DBS\" d on d.\"DB_ID\"=t.\"DB_ID\" where d.\"NAME\" in ('bronze','bronze_ref','silver')" \
      | while IFS=. read -r db t; do [ -n "$t" ] || continue; L=${db//_/-}; [ -d "/srv/hti-lake/$L/$t/_delta_log" ] || echo "DROP TABLE IF EXISTS $db.\`$t\`;"; done > /tmp/.hti_stale_tables.sql
    if [ -s /tmp/.hti_stale_tables.sql ]; then
      docker compose -f "$PLATFORM/docker-compose.yml" exec -T spark-thrift /opt/spark/bin/beeline -u jdbc:hive2://localhost:10000 \
        -e "$(cat /tmp/.hti_stale_tables.sql)" >/dev/null 2>&1 && echo "dropped $(wc -l < /tmp/.hti_stale_tables.sql) stale catalog entr(y/ies)"; fi
    rm -f /tmp/.hti_stale_tables.sql
    docker exec hti-platform-metastore-db-1 psql -U metastore -d metastore -tAc \
      "select d.\"NAME\"||': '||count(*) from \"TBLS\" t join \"DBS\" d on d.\"DB_ID\"=t.\"DB_ID\" group by d.\"NAME\" order by 1" | sed 's/^/  catalog /' ;;
  -h|--help|help|"") usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
