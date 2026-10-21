#!/usr/bin/env bash
# =============================================================================
# hti-platform/conf/spark-entrypoint.sh                               NEW FILE
#
# N1: removes G5. start-thriftserver.sh echoes its full launch command to the
# log, so a password passed as "--conf ...ConnectionPassword=..." is written to
# disk in plaintext on every start. Two passwords have leaked that way.
#
# This wrapper writes the password into a hive-site.xml that Hive picks up off
# the classpath (SPARK_CONF_DIR is on it), so it never appears as an argument.
# Runs for the thrift server AND for every spark-submit job, because it is the
# container entrypoint - "docker compose run spark-jobs spark-submit ..."
# replaces the command, not the entrypoint.
#
# Hands off to the image's own entrypoint, which pass-through execs "$@".
# =============================================================================
set -euo pipefail

CONF_DIR=/tmp/spark-conf

if [ -z "${METASTORE_PASSWORD:-}" ]; then
  echo "spark-entrypoint: METASTORE_PASSWORD is unset or empty - refusing to start." >&2
  echo "spark-entrypoint: check .env, then 'docker compose up -d --force-recreate'." >&2
  exit 1
fi

umask 077
mkdir -p "$CONF_DIR"

# SPARK_CONF_DIR replaces the image's conf dir wholesale rather than adding to
# it, so the bind-mounted (read-only) defaults have to be copied across.
cp /opt/spark/conf/spark-defaults.conf "$CONF_DIR/spark-defaults.conf"

# A base64 password never contains & < >, but a hand-set one might.
esc_pw=$(printf '%s' "$METASTORE_PASSWORD" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')

cat > "$CONF_DIR/hive-site.xml" <<XML_EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>${esc_pw}</value>
  </property>
</configuration>
XML_EOF
chmod 600 "$CONF_DIR/hive-site.xml"
unset esc_pw

export SPARK_CONF_DIR="$CONF_DIR"

# hive-site.xml is now the only carrier: do not let the JVM inherit the secret,
# so it cannot reach a heap dump, a crash report, or a child process env.
unset METASTORE_PASSWORD

exec /opt/entrypoint.sh "$@"
