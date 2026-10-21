# Plaintext credentials in silver, and MCP guard gaps — 2026-10-14

## What was found

Seven credential columns were being copied into the lake unchanged and were readable
through the public MCP endpoint (`https://datamgt.esukh.mn/mcp`):

| Table (silver and bronze) | Columns | Non-null values in silver |
| --- | --- | --- |
| `parkly_camera` | `pass`, `addSignature`, `deleteSignature`, `selectSignature`, `getRecordSignature` | pass 200, signatures 5 |
| `esukh_camera` | same five | pass 37, signatures 3 |
| `parkly_routerconfig` | `routerPass`, `anydeskPass` | routerPass 4, anydeskPass 0 |

None of the values were tokens; all were plaintext. MCP server logs (10 days back)
show no query against these tables. Values were also visible in Delta `_delta_log`
column statistics and in `hti-spark-thrift` container logs.

**Cause.** `jobs/make_phase1.py` classified any column it did not recognise as
"Organisation/config identifier - passthrough". It had no credential rule. The control
table validator matched `password`/`passwd` but not a bare `pass` or `signature`.
`esukh_camera` is not in the current esukh phase-1 control table; it is left over from
an earlier load through `control_table_esukh.csv`.

## Separate finding: MCP SQL guard could reach raw bronze

`guard_sql` checked only table names directly after `FROM`/`JOIN`. A comma join
(`FROM silver.x, bronze.y`) reached raw personal data, `delta.\`/lake/...\`` or
`parquet.\`/path\`` read any file Spark could see, and `reflect()`/`java_method()` could
call Java. `list_tables` was also capped at 200 rows, hiding every system after esukh.

## Done on 2026-10-14

1. **MCP server** (`mcp/server.py`, deployed): the three tables are refused in `run_sql`,
   `describe_table` and hidden from `list_tables`; any qualifier for a database outside
   `silver`/`bronze_ref` or a file-format reader, any back-quoted path, and
   `reflect`/`java_method`/`read_files`/`input_file_*` are refused anywhere in the
   statement. Tested: 10 attack queries refused; normal queries and all KPI SQL pass.
2. **Control tables**: the seven columns removed from `columns_allowlist` in
   `control_table_parkly_phase1.csv`, `control_table_parkly.csv`, `control_table_esukh.csv`.
3. **transform_rules.csv**: the seven rows set to `drop`.
4. **make_phase1.py**: a `CREDENTIAL` pattern now drops passwords, secrets, signatures,
   keys, hashes, OTP/PIN columns before any other rule.
5. **validate_control_table.py**: CT018 now also flags `signature` and names ending in `pass`.
   Re-run on the original files it reports all 12 entries.

6. **Filter record**: the seven columns are listed with their reason in
   `jobs/control_table_{parkly,esukh}_excluded_columns.csv` and in the 2026-10-14 update of
   `docs/FILTER_STATUS_2026-10-02.md`. `make_phase1.py` now filters credential columns out of
   the allowlist (after `--include`), so they do not reach raw bronze either.

7. **Lake purged** (10:05-10:08 UTC, approved by the platform owner): `jobs/purge_credential_columns.py`
   rebuilt `bronze/` and `silver/` `{esukh_camera, parkly_camera, parkly_routerconfig}` as new Delta
   tables without the seven columns (fresh `_delta_log`, history before the purge dropped). Same rows
   (silver 483 / 214 / 4, bronze parkly_camera 169). Verified: no file under `/srv/hti-lake` records
   any of the columns; Thrift schemas clean.
8. **Saved session output** holding some values deleted by the platform owner.

Backups of every edited file: `*.bak-20261014` next to it.

## Still open — needs a decision

- **Rotate the credentials.** 237 camera passwords, their API signatures and 4 router
  passwords were in a store reachable from the internet. Owners: parkly and esukh teams.
- **Spark Thrift logs** in the `hti-spark-thrift` container contain some of the values
  (Delta stats at INFO level). They go when the container is recreated; lowering the
  Delta log level would stop it recurring.
- **Data-officer confirmation** of the `drop` treatment (rows marked
  "2026-10-14 security fix - pending data-officer confirmation").
