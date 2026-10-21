# CLAUDE.md — HTI Data Platform (esukh pilot)

Context file for Claude Code sessions on this server. Read fully before touching anything.
Last updated: 2026-09-30.

## 0. How to work in this repo (non-negotiable)

1. **Check in before writing code.** Explain the plan, get a "go", then write **one piece at a time** and stop for review before the next.
2. **Never assume** a table, column, config key, env var, method or file exists — look first; if absent, ask or create it explicitly.
3. **Every code change states its path/file, whether it is NEW / CHANGED / REMOVED, and where it sits.** Never rewrite a whole file for a small edit; show the changed block with what is added/removed.
4. **Strong typing everywhere** (PySpark schemas declared, Python type hints, no `Optional` left unchecked).
5. **Cleanup is part of the change:** when refactoring, list what becomes unused and must be deleted.
6. **Privacy rules in section 4 override convenience.** If a shortcut would put personal data somewhere it should not be, do not take it — flag it.
7. Never print row samples, run `.show()` on bronze/silver data, or paste table contents into chat. Log row counts, schemas, paths, timings only.
8. Never put secrets in files, command lines, or chat. `.env` is git-ignored and **`chmod 640` root:root** - not 600. Airflow's containers run as `uid=50000 gid=0`, and `docker compose` must read `.env` to interpolate variables; at 600 every DAG task dies with `open /platform/.env: permission denied`. "Other" still cannot read it, and Airflow already holds the Docker socket (root-equivalent on this host), so withholding `.env` from it was never a real control. `airflow/.env` stays 600 - nothing else needs to read it. `airflow/.env`, `tokenmap/.env`, `mcp/.env` and `/home/developer/parkly/.env` are read only by their own compose project and stay **600**.

## 1. What this is

Hubilai Tech (HTI) runs several apps — **esukh (иСӨХ)** (pilot), **СМА**, **Parkly**, **MyProperty** — each on its own MySQL. This platform copies their data nightly into a Delta Lake, pseudonymises it, builds analytics marts, and serves them to Power BI. It is operated as a **separate service** with its own credentials: app teams grant read-only DB access and consume marts; they never touch keys, the token store, or the transformation code.

Source documents (not in repo): Data Ger *Data Maturity Assessment* (Nov 2024) and HTI *Personal & Sensitive Data Protection Policy* (2026-09-28). The design below implements the policy's four-component analytics model.

## 2. Architecture (single node, local-filesystem Delta Lake)

```
MySQL read-only nodes ──JDBC──▶ [1] bronze (Delta, PII, TTL ≤ 24h)
                                        │ Spark tokenize job  ◀── vault key + token-map Postgres (separate)
                                        ▼
                                [2] silver (Delta, tokenised)  ── dbt-spark (staging/intermediate)
                                        ▼
                                [3] gold   (Delta, aggregates)  ── dbt-spark (marts, snapshots, tests)
                                        │ Spark JDBC export
                                        ▼
                                [4] serving Postgres  ──▶ Power BI (read-only)
Airflow orchestrates 1→4 nightly.  Open Metadata catalogs everything (last to be added).
```

Layer paths (bind mount `${LAKE_DIR}` → `/lake` in containers):

| Path | Contents | Retention |
|---|---|---|
| `/lake/bronze` | raw copy of allowlisted tables, contains PII | ≤ 24 h, nightly VACUUM + partition drop |
| `/lake/bronze-ref` | non-PII reference tables (tariffs, buildings, config) | longer, decided per table in purpose register |
| `/lake/silver` | tokenised row-level data, dbt-owned | per purpose register (starting line: 12 months, then aggregate + delete) |
| `/lake/gold` | aggregates, no person/vehicle codes, dbt-owned | long-term |
| `/lake/warehouse` | default location for managed tables | — |

Decisions already made (do not re-open without asking):
- Spark + Delta chosen over Postgres-only (team decision; Parkly gate events expected). Single node, `local[*]`, no cluster.
- **Local filesystem, not S3.** MinIO community edition is archived and its images were removed from Docker Hub/Quay in Sep 2026. If the platform ever moves to DigitalOcean, the lake goes to DO Spaces (path change + copy).
- Hive metastore in a dedicated Postgres (`metastore-db`) so thrift server and jobs share one catalog. It holds no data.
- Token map = **separate** Postgres instance (not yet created), separate credentials, key in a vault. Random UUID tokens + mapping table (policy-literal), per-system by default — cross-system linking is a data-officer decision.
- NiFi deferred until streaming sources exist. Open Metadata last. Spark/Delta upgrade path exists but is not on the critical path.

## 3. Stack & pins

| Component | Version / image | Why |
|---|---|---|
| Spark | `apache/spark:3.5.7` (runs as uid **185**) | Spark 3.5.x ↔ Delta 3.3.x |
| Delta Lake | `io.delta:delta-spark_2.12:3.3.2` | needs Spark ≥ 3.5.3 |
| Postgres JDBC | `org.postgresql:postgresql:42.7.7` | metastore + later serving export |
| MySQL JDBC | `com.mysql:mysql-connector-j:9.3.0` | source reads |
| Metastore DB | `postgres:16-alpine` | catalog only |
| lake-init | `alpine:3.20` | creates folders, chowns to 185 |
| dbt | `dbt-spark` (thrift method) → `localhost:10000` | not installed yet |

Jars are resolved by Ivy into the `ivy-cache` volume on first start and also placed on the driver boot classpath (`spark.driver.extraClassPath /tmp/ivy/jars/*`) — see gotcha G3.

## 4. Privacy rules (from the HTI policy — enforced in code, not in prompts)

**At copy-in (allowlist, not denylist):**
- Only tables/columns listed in the control table are copied. New columns from app migrations do **not** flow until approved.
- Never copied at all: names, phone numbers, emails, register numbers, free-text notes, and any correspondence tables (forum, chat, messages, comments, support-ticket text — content = sensitive under 4.1.4).
- Copied into bronze only because tokenisation/grouping needs them: plates, user IDs, addresses, exact timestamps.

**Tokenise (bronze → silver):**
- Plate / user ID → random UUID via token map; same value always gets the same token (per system).
- Never a plain hash. Keyed HMAC is the only acceptable alternative to the mapping table.
- Address / property number → location group. Exact timestamp → day + hour band. Names etc. are dropped, not hidden.
- Only the tokenise job's service account can reach the token map and the vault. dbt, BI, humans: no route.

**Gold / BI:**
- No person or vehicle codes in gold. Groups with < 10 distinct vehicles are suppressed in views (`HAVING count(distinct token) >= 10`).
- Power BI and any bot read gold / serving Postgres only, with a read-only role.

**Retention & ops:**
- Bronze is partitioned by `_load_date`; nightly job drops old partitions then `VACUUM ... RETAIN 24 HOURS` with `spark.databricks.delta.retentionDurationCheck.enabled=false` **in that job's session only** (never globally).
- `${LAKE_DIR}` must be on the encrypted disk and **excluded from this server's backup jobs** (bronze in a backup = 7-day copy = policy violation). Filesystem/volume snapshots of the lake are equally off-limits.
- Spark UI (:4040) and thrift (:10000) bound to 127.0.0.1 only. Event logging off. No data in logs.
- Dev/test use synthetic data, never the replica.
- Cross-border: if any part moves to DO Singapore, policy art. 14.1 legal check first.

## 5. Repo layout & status

```
hti-platform/
├── CLAUDE.md                     this file
├── docker-compose.yml            v2 (local lake). services: lake-init, metastore-db, spark-thrift, spark-jobs(profile)
├── .env.example                  LAKE_DIR, METASTORE_PASSWORD, THRIFT_DRIVER_MEMORY
├── .env                          real secrets, chmod 600, git-ignored
├── conf/
│   ├── spark-defaults.conf       Delta ext + catalog, Postgres metastore, ivy path, extraClassPath, sizing
│   ├── spark-entrypoint.sh       writes hive-site.xml from env, then execs the image entrypoint (N1, kills G5)
│   └── metastore-schema.sql      Hive 2.3.0 schema, seeded at volume init via docker-entrypoint-initdb.d (G8)
├── jobs/                         bind-mounted ro at /opt/jobs
│   ├── validate_control_table.py enforces the section 4 copy-in rules on control_table.csv (stdlib only)
│   ├── load_bronze.py            N3 loader; refuses to run unless the control table validates clean
│   ├── control_table.csv         DRAFT, unsigned - 170 tables, purpose_ref empty so it cannot load
│   ├── control_table_excluded.csv  the other 71 tables + why each is excluded
│   └── control_table_exceptions.csv  signed waivers for CT014/15/16/18/19 - justification + approved_by required
├── esukh_schema.sql              241 CREATE TABLEs, structure only, extracted from the 2026-09-29 backup
└── esukh_schema_analysis.md      9-domain proposal + privacy classification (input to N2)
```

Server: `esukh-db-backup`, project at `/home/developer/hti-platform`, run as root via `docker compose`.

**Status 2026-09-29:** stack up; thrift healthy on :10000; metastore auth green; SQL round-trip
(`CREATE`/`INSERT`/`SELECT`/`DROP`) passes. N1 done (G5 closed - no credential reaches a log).
Fixed this session: the password mismatch (root cause was G6 - the volume kept an old password;
resolved by `down -v` so Postgres re-inits from `.env`, not by `ALTER USER`), G8 (below), and
CREATE TABLE silently producing Hive text tables instead of Delta.

**Smoke test GREEN 2026-09-29** (first time), verified end-to-end on a fresh volume: 57-table
schema seeded at init; no deadlock; thrift up in ~30s (RestartCount=1 = the expected G3 miss);
`CREATE`/`INSERT`/`SELECT`/`DROP` clean; `_delta_log/` + `.snappy.parquet` present and
`spark.sql.sources.provider=delta` in TABLE_PARAMS; catalog and lake both empty again after DROP;
0 credentials in the log.

**METASTORE_PASSWORD ROTATED 2026-09-30.** The value that leaked twice via G5 is retired; `.env`
now holds a fresh 32-char secret (mode 600) and every `.env.bak.*` plus the staged copy was
`shred -u`'d.

**Method, and it reverses the advice G6 used to give.** `ALTER USER` was used, NOT `down -v`.
`down -v` was right while the metastore was empty, but it wipes `metastore-data`, and the catalog
now holds 24 registered tables across 5 databases - the Delta files survive a wipe, the
registrations do not. Keeping `ivy-cache` also meant no jar re-download and **no G3 first-start
failure** (`RestartCount=0`). Sequence:
```bash
{ printf "SET log_statement='none';\nALTER USER metastore PASSWORD '"; tr -d '\n' < <pwfile>; \
  printf "';\n"; } | docker exec -i hti-platform-metastore-db-1 psql -U metastore -d metastore
# then update .env from the same file (never via argv), then:
docker compose up -d --force-recreate spark-thrift
```
Verified after: new password authenticates over the platform network, old one rejected, thrift up
in ~20s healthy with `RestartCount=0`, all 24 catalog entries intact, and **0** occurrences of
`ConnectionPassword` in the logs.

**Rule of thumb:** empty catalog -> `down -v` (simplest, no secret write). Catalog with content ->
`ALTER USER` + `--force-recreate spark-thrift` (preserves registrations and the Ivy cache).

**Still open:** (a) `hive.metastore.schema.verification` is still `false`; now that the schema is
authoritative, `true` is the correct setting - N10. (b) `/home/developer/mysql/backup_script.sh.bak-20260929`
still holds the old production MySQL password in plaintext - shred it once that password is rotated
on the source host.

Smoke test (must pass before any job code). The `_delta_log/` check is the part that matters:
it failed silently before `spark.sql.legacy.createHiveTableByDefault false` was set, producing a
Hive text table while every SQL statement still returned success.
```bash
docker compose exec spark-thrift /opt/spark/bin/beeline -u jdbc:hive2://localhost:10000 \
  -e "CREATE TABLE smoke_test (id INT); INSERT INTO smoke_test VALUES (1); SELECT * FROM smoke_test;"
ls "$LAKE_DIR/warehouse/smoke_test/"            # expect parquet + _delta_log/
docker compose exec metastore-db psql -U metastore -c 'select "TBL_NAME" from "TBLS";'   # expect smoke_test
docker compose exec spark-thrift /opt/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e "DROP TABLE smoke_test;"
```

## 5a. Catalog layout (2026-09-29)

One Hive database per lake layer, each with an explicit LOCATION, so a query states which layer
it touches (`bronze.esukh_user` is visibly raw PII; `default.esukh_user` was not) and so dbt (N6)
and future per-database grants have something to attach to:

| Database | Location |
|---|---|
| `bronze` | `/lake/bronze` |
| `bronze_ref` | `/lake/bronze-ref` |
| `silver` | `/lake/silver` |
| `gold` | `/lake/gold` |
| `default` | `/lake/warehouse` (left empty; a table created with no LOCATION lands here) |

Tables are registered EXTERNAL, so `DROP TABLE` removes the catalog entry and leaves the Delta
files in the lake. **`load_bronze.py` does not register anything** - it writes by path only, so a
new table must be registered by hand (silver: `airflow/pipeline.sh register` does all of them; bronze: never, see 5e):
```sql
CREATE TABLE IF NOT EXISTS bronze_ref.esukh_<t> USING DELTA LOCATION '/lake/bronze-ref/esukh_<t>';
```

## 5b. Demo data (2026-09-29)

`jobs/control_table_demo.csv` + `control_table_demo_exceptions.csv` load 7 non-personal tables
from the LOCAL `mysql-esukh` restore into `/lake/bronze-ref` (28,999 rows), registered in the
catalog as `bronze_ref.esukh_*` (see 5a). This is a **demo allowlist, not the signed one** - `purpose_ref` is
`DEMO-2026-09-29` and the waivers say `demo-only (NOT a data-officer approval)`.

```bash
docker compose --profile jobs run --rm \
  -e ESUKH_DB_URL='jdbc:mysql://mysql-esukh:3306/esukh?sslMode=REQUIRED' \
  spark-jobs /opt/spark/bin/spark-submit --master 'local[2]' /opt/jobs/load_bronze.py \
    --control-table /opt/jobs/control_table_demo.csv \
    --exceptions /opt/jobs/control_table_demo_exceptions.csv --source-system esukh
```
`mysql-esukh` was attached to `hti-platform_platform` (172.20.0.4) so Spark can resolve it;
TLS is `sslMode=REQUIRED` because the container's certificate is self-signed, so the link is
encrypted but the server is not authenticated - acceptable container-to-container, not for a
remote source.

**Do not show `esukh_graphsummary` or `esukh_branchinvoice` row values to a customer.** They are
per-organisation financial figures keyed by `branchId`: not personal data, so they pass every
privacy check, but showing one СӨХ another's revenue is a commercial confidentiality breach.
Filter to the viewer's own `branchId`, or show schema and counts only.

**`branch.name` is NOT safe and was removed (2026-09-29).** It was first loaded under a CT015
waiver justified as "an organisation, not a natural person". That justification was wrong: branch
id 5 is a personal name (`damdinjavinbaldandorj`), and **178 of 432 branch names (41%) carry no
organisation marker** (`СӨХ`/`ХХК`/`ХК`/`ТББ`/`LLC`), with 10 being single Latin words. Some are
building names, but they cannot be separated from personal names automatically. The column was
removed from the demo allowlist, the waiver deleted, and the Delta table rebuilt without it.
Re-including it needs a data-officer triage of those 178, not a pattern change.

This also demonstrated the drift control: the reload failed with `schema drift: dropped ['name']`,
because narrowing an allowlist must be a deliberate rewrite, not something a nightly job does
quietly. Removing a column from bronze = delete the Delta table, then reload.

**Amplification risk:** `branch` joined to `esukh_graphsummary` or `esukh_branchinvoice` makes
per-organisation revenue attributable to a named СӨХ. All three pass every privacy check, but the
join is a commercial confidentiality problem. Do not show them joined to a customer.

**Found while picking these tables:** `esukh.town` stores `stateBankTransLoginName`,
`stateBankTransLoginPass`, `khanToken` and `bankAccountNumber` as plaintext columns. That is a
source-system security problem to raise with the esukh team, and `town` must never be copied.

## 5c. Other HTI systems — schema inventories (2026-09-30)

Structure extracted from the app teams' own backups; no rows, no personal data. Analyses follow
the esukh format (domains, privacy classification, credential scan).

| System | Source dump | Tables | Cols | Analysis |
|---|---|---|---|---|
| `smartpay_db` | Postgres 16 custom | 37 | 366 | `smartpay_schema_analysis.md` |
| `sma_db` | MySQL 8 | 34 | 326 | `sma_schema_analysis.md` |
| `parkly` | Postgres 14 custom | 69 | 875 | `parkly_schema_analysis.md` |
| `myproperty` | Postgres 16 custom | 96 | - | `myproperty_schema_analysis.md` |

Extraction commands (Postgres custom format needs `-f -`; a plain `>` redirect is refused):
```bash
pg_restore --schema-only --no-owner --no-acl -f - x.dump > x_schema.sql
LC_ALL=C awk 'BEGIN{b=0} /^CREATE TABLE /{b=1} b{print} b && /^\)/{b=0}' x.sql > x_schema.sql
grep -cE '^(INSERT|REPLACE|COPY)' x_schema.sql    # must be 0
```

**Credential columns found in all three — raise with the owning teams.** Whether these hold
plaintext cannot be told from DDL, and none may ever be copied to any layer:
- `smartpay`: `admin.password`, `merchant.authPassword`, `userPin.tranPin`, `card.tokenid`
- `parkly`: `system_admin.password`, `merchant.password`, `routerConfig.wifiPassword`,
  `externalSystem.apiPasswordHash`, `worker.mobileToken`
- `sma`: `Users.pin`, `Users.expoToken`
- `myproperty`: `worker.passwordHash`, `ekontorCredential.passwordEncrypted`,
  `onboardingRequest.codeHash`/`stateToken`, `workerDeviceToken.token`,
  `branchCorporate.credential`, `branchBuildingCorporate.credential`

**myproperty is the best-behaved of the five on credentials** and is worth citing to the other
teams: `passwordHash`, `passwordEncrypted` and `codeHash` all *say* the value is protected. Only
`branchCorporate.credential` is opaque. Everywhere else - esukh `loginPass`, smartpay `password`,
parkly `wifiPassword` - the name tells a reader nothing.

`smartpay` is the urgent one: a payment system holding a column named `tranPin` alongside
`admin.password`. Same class as `esukh.town` and the plaintext passwords in
`/home/developer/mysql/*.sh`, which is now a pattern across four systems, not an isolated lapse.

**Parkly matters for N4.** It carries plate/vehicle data (`car`, `carConfig`, `inOutHistory`,
`parkCarMirror`) and an `esukhInfo` table, so the same plate can exist in both esukh and Parkly -
which is exactly the cross-system token-linking decision in section 9. 94 tokenise-candidate
columns across 69 tables.

**Known false positive:** `sma.userCarPostgre` / `userCarPostgres` are flagged as correspondence
tables because "post" matches "Postgre". Substring matching fails closed by design; this is the
cost. Waive them, do not loosen the pattern.

## 5c-2. Source-team filter documents (2026-10-02)

`./docs` holds what each app team supplied. Coverage is very uneven; `docs/FILTER_STATUS_2026-10-02.md`
has the full analysis.

| System | Document | Covers | Production filter |
|---|---|---|---|
| myproperty | masking inventory `.xlsx` | 950 columns / 92 tables, each P0/P1/P2 | **built** - 92 tables, 699 cols |
| parkly | privacy `.pdf` | 55/69 tables, Red/Normal, table level only | **built** - 27 proposed, 42 excluded |
| sma | our review doc, revised | 39 copied / 8 excluded | blocked - 11 approved tables absent from our dump |
| esukh | `Data preparation` `.docx` | 19/241 (7%), stops mid-entry | no |
| smartpay | none | - | no |

**The myproperty inventory corrected our pattern filter in 221 places - ours was too permissive.**
They mask `archiveFile.filePath`/`fileUrl`, `bankStatement.raw`/`relatedAccount`,
`branch.address`/`sealUrl`, and exact `createdAt`/`updatedAt` on many tables (consistent with CT106:
an exact timestamp is a quasi-identifier). Treat an owner's column-level inventory as authoritative
over our patterns wherever one exists.

**Reading these files needed no new tooling:** `.docx`/`.xlsx` are ZIP+XML (stdlib `zipfile` +
`ElementTree`); the PDFs use hex-CID strings with subset fonts, so text needs each font's
`ToUnicode` CMap decoded - there is no `pdftotext`, `pandoc` or LibreOffice on this host.

**False positives waived 2026-10-02** - 4 for myproperty, 6 for esukh - attributed to the platform
team and labelled filter false positives, not policy exemptions. For esukh the six columns had to be
**added back to the allowlist first**: a waiver only downgrades an error on a column that is in the
list, so waiving a column we were not copying matches nothing and raises `CT102`.

**Still unresolved, data officer only:** myproperty's 12 correspondence tables (they propose keeping
metadata after stripping content columns - policy 4.1.4 excludes such tables whole) and 2 credential
stores; esukh's 10 conflicts including `branch.phone`/`email`.

## 5d. Control tables — one per source system (2026-09-30)

`jobs/control_table_<system>.csv` + `_excluded.csv` + `_exceptions.csv`. The unprefixed
`control_table.csv` was removed; `load_bronze.py --control-table` is now **required**.

| System | Proposed | Excluded | Accounted | Validator (as of 2026-09-30) |
|---|---|---|---|---|
| esukh | 166 | 76 | 242 (241 tables + 1 view) | 166 × CT013, 2 × CT106 |
| smartpay | 32 | 5 | 37 | 32 × CT013 |
| sma | 29 | 5 | 34 | 29 × CT013, 6 × CT106 |
| parkly | 27 | 42 | 69 | 27 × CT013 (re-cut 2026-10-02 to the team's Normal list) |
| myproperty | 92 | 4 | 96 | 92 × CT013 (rebuilt 2026-10-02 from the owner's masking inventory) |

All four fail **only** on `CT013` (no `purpose_ref`) plus `CT106` warnings, which is deliberate:
they cannot load until the purpose register exists. No credential, identity, free-text,
correspondence, credential-store or structural errors remain. Regenerate with the generator, not
by hand - it is idempotent.

### Filter rules (`jobs/validate_control_table.py`)

All matching is **substring**, on the identifier with separators stripped, so `user_name`,
`userName` and `username` all trip `name`. It fails closed on purpose: a false positive costs one
review, a false negative copies personal data.

| Rule | Effect | Catches | Waivable |
|---|---|---|---|
| `CT001`-`CT003` | error | header / field-count / empty required field | no |
| `CT004`, `CT005` | error | invalid `target_layer` or `load_mode` | no |
| `CT006`, `CT007` | error | `incremental` without a primary key or watermark | no |
| `CT008`, `CT009` | error | empty allowlist; `*` refused so new app columns cannot flow in | no |
| `CT010` | error | duplicate column (also catches case-only collisions, fatal in Spark) | no |
| `CT011`, `CT012` | error | primary key / watermark not in its own allowlist | no |
| `CT013` | error | **no `purpose_ref`** - no lawful purpose, no copy (policy step 1) | no |
| `CT014` | error | **correspondence tables** excluded whole (policy 4.1.4) | yes |
| `CT015` | error | **identity columns**: name, surname, phone, email, register, passport, and **photographs of people** (`image`, `avatar`, `photo`, `picture`) | yes |
| `CT016` | error | **free text**: note, comment, remark, desc, message, body, content, reason, answer, title, subject | yes |
| `CT017` | error | duplicate `(source_system, source_table)` row | no |
| `CT018` | error | **secrets**: password, loginpass, pin, token, hash, apikey, bankaccount, accountnumber, accountholder, and **verification codes** (`validatecode`, `verificationcode`, `activationcode`, `confirmcode`) | yes |
| `CT019` | error | **credential-store tables** (otp, token, passwordreset, userpin, apikey, secret) excluded whole, whatever the columns are called | yes |
| `CT101` | warning | `full` load with a watermark set - it is silently ignored | n/a |
| `CT102` | warning | stale waiver matching nothing - would pre-approve a future row | n/a |
| `CT103`-`CT105` | error | exceptions file: bad header, unwaivable rule, missing justification or approver | no |
| `CT106` | warning | **needs banding before gold**: gender, birth date, latitude, longitude | n/a |

Structural rules are **not** waivable by design: a primary key missing from its own allowlist is a
bug, not a judgement call. Only the five policy rules can be signed off, and each waiver requires
a written justification and an approver name - that record is what made the `branch.name` error
falsifiable.

**Deliberate non-patterns, each checked against all four schemas first:**
- bare `tel` - would match `hotel`, `telemetry`; `phone`/`telephone` already cover it.
- bare `code` - would match `bankCode`, `serviceCode`, `vatDistrictCode`. This is why `CT019`
  matches the **table** name: `esukh.otpv2` stores its passcode in a column called `code`.
- bare `account` - would wrongly flag `accountId` foreign keys and `accountType` metadata.
- `session` in `CT019` - a parking-session table is analytics data, not a credential store.
- bare `lat`/`lng` in `CT106` - would match `related`, `translate`, `late`.
- `pin` **is** included: checked across all 1,747 columns in the four schemas and it matched only
  `smartpay.userPin.tranPin` and `sma.Users.pin` - no `shipping`/`mapping` false positives.

**Known over-detection, cleared by waiver not by loosening:** `logoImage`, `bgImage`, `stampImage`,
`qrImage`, `townImage` are organisation branding, caught by the `image` pattern alongside the real
person photos (`esukh.user.image`, `sma.avatarUrl`, `esukh.picture_data`, and parkly's
`inImageName`/`outImageName` ANPR gate captures - a photo of a vehicle and plate at a known time
and place). Also `sma.userCarPostgre`/`userCarPostgres` trip `CT014` because "post" matches
"Postgre".

**Rule history - each of these was found by running the filter against real data, not by review.**

**CT018 added 2026-09-30 - the validator had no credential rule at all.** The first esukh
draft allowed **25 secret-looking columns across 18 tables**: `user.loginPass`, `worker.loginPass`,
`systemadmin.loginPass`, `couponcreater.password`, `town.stateBankTransLoginPass`,
`apartment.stateEBillinLoginPass`, `khanToken` (branch, town), `qpayLoginPass`, `qpayToken`,
and `bankAccountNumber` across five tables. It would have copied passwords into bronze. It is
waivable only because token *metadata* (`tokenDate`, `tokenVersion`, `tokenExpired`) is not itself
a secret; waiving an actual secret is never correct.

**CT019 added 2026-09-30** after `esukh.otp` and `esukh.otpv2` were found in the allowlist with
`code` included - live one-time passcodes, one row from bronze. It excluded 9 tables across three
systems: `esukh.otp/otpv2/qpaytoken/qpaytokensb/tttoken`, `smartpay.passwordResetToken/userPin/token`,
`sma.Otps`, and dropped esukh from 170 to 166 proposed.

**CT106 added 2026-09-30** after `sma.Agents.gender`/`birthDate` and `sma.Parks.latitude`/`longitude`
passed every existing check silently. Policy section 4 never lists demographics, but a birth date
needs an age band exactly as an exact timestamp needs an hour band. A warning, not an error, because
bronze may legitimately hold them for silver to transform.

**`image` and `validateCode` added to CT015/CT018 2026-09-30**, found by reading `esukh.user`'s
surviving columns by hand after every other rule had run - a profile photo and a verification code
were still being copied. Nothing automated caught them; the lesson is that section 6 of the review
documents (the per-table column list) is the control that finds this class, not the patterns.

**`parkly.models` is excluded for a source-schema defect:** it has `workerId` **and** `WorkerId`,
both in its composite primary key. Legal in Postgres (quoted identifiers are case-sensitive),
impossible in Spark/Delta (case-insensitive by default). Needs fixing at source. Note CT010
flagged it via case-insensitive duplicate detection - right conclusion, incidental reasoning.

**Sources are restored on demand, then removed.** smartpay, sma and parkly were restored locally
on 2026-09-30, loaded, and their containers plus anonymous volumes deleted (`docker rm -fv`) -
three copies of other systems' production data should not sit on an unfirewalled host. `esukh`
(`mysql-esukh`) and `myproperty` (`pg-myproperty`) are currently up. Re-loading any of the others
means restoring its dump again.

**Postgres read-only users need more than `GRANT SELECT`** - on PG <= 14 the `public` schema grants
`CREATE` to `PUBLIC`, so the first `parkly_reader` could create tables. Every reader here now gets
`REVOKE CREATE ON SCHEMA public FROM PUBLIC` and `REVOKE ALL ON DATABASE <db> FROM PUBLIC`,
verified by attempting `CREATE TABLE` and `select from pg_shadow` as that user.

## 5e. Phase-1 production loads (2026-10-02 → 2026-10-04)

**Bronze is no longer empty, and it holds real personal data under a provisional purpose.** On
2026-10-02 the pattern was set: a `control_table_<sys>_phase1.csv` = the full control table (or a
subset) with `purpose_ref = PENDING-REVIEW-2026-10` and waivers stamped *PROVISIONAL / NOT a
data-officer approval*. That marker exists so the loader runs; it is not a purpose register entry,
and section 9 still owes one. Treat everything in bronze/silver as loaded on that basis.

| System | Phase-1 basis | Tables | Source on this host |
|---|---|---|---|
| esukh | 4 lookup tables until 10-06; now the 166 tables of the returned review document (5f) | 166 | `mysql-esukh` (nightly restore) |
| myproperty | owner's column-level masking inventory minus 14 tables under review | 78 | `pg-myproperty` |
| parkly | the 27 tables the parkly team classified **Normal** (table level only - columns still pattern-derived) | 27 | `pg-parkly` (nightly restore, PG16) |
| smartpay | team document `docs/smartpay_models_columns_safe.md` since 10-06 (was our pattern filter) | 31 | `pg-smartpay` (restored 10-04) |
| sma | the 20 tables in BOTH the team's revised list AND our 2026-09-30 dump; 11 they approved are absent from that dump and 8 of ours they did not name are held back | 20 | `mysql-sma` (restored 10-04) |

Readers are `SELECT`-only (Postgres ones also need `REVOKE CREATE ON SCHEMA public FROM PUBLIC` -
on PG ≤14 `public` is world-creatable). Local restores use `--insecure-no-tls`: the official images
ship without TLS and the traffic never leaves the Docker network.

**Retention breach, 10-02 → 10-04, fixed 10-04.** The DAG called `vacuum_bronze.py` with no
`--retain-hours`, so the default 24 h applied: the partition just dropped was ~2 h old, Delta kept
its files, and the job correctly reported `bronze retention NOT fully enforced` every night. Now
`--retain-hours 0`: vacuum is the last serialised step, nothing in the catalog points at bronze,
and policy gives humans/BI no route to it, so the concurrent-reader objection does not apply. The
data officer still owes the formal figure; 0 is the conservative direction (deletes sooner).

**2026-10-04 first loads of parkly / smartpay / sma.** smartpay 31 of 32 tables, sma 18 of 20 -
the missing ones (`settle`, `AgentCommissions`, `DirectOfferApproves`) have **0 rows at source**
and the loader writes nothing for an empty frame, so no Delta directory exists. That is by design
(`load_bronze.py` "no new rows"), not a failure; the count in `airflow/pipeline.sh lake` will be
lower than the control table whenever a source table is empty. `smartpay.card` failed its first
tokenisation (G11) and was re-run after the rule fix. parkly's first load died while the host
was out of memory (G12); the retry loaded 27/27 (26 materialised, `groupDiscount` empty). End
state 15:30: bronze = silver = esukh 4 / myproperty 69 / parkly 26 / smartpay 31 / sma 18, all
148 silver tables registered, 0 stale bronze partitions.

**Catalog visibility.** `silver` tables are registered (`airflow/pipeline.sh register`, idempotent)
so DBeaver / thrift / dbt see them. **`bronze` is never registered**: policy section 4 gives
humans, BI and dbt no route to raw personal data and thrift has no authentication, so an empty
`bronze` database in DBeaver is the correct state. `bronze_ref` was registered by hand on 09-29.

## 5f. 2026-10-06: nightly source sync, layer routing, catalog, KPI MCP

**Sources are now refreshed from the production backup server every day.** Remote
`khangal@202.131.1.30:~/dbbackup` (Asia/Ulaanbaatar; esukh dumps 01:00 UB, parkly 23:00 UB,
up to ~30 days kept there) is read-only to us: `/home/developer/dbbackup/pull_backups.sh`
copies the newest finished `backup-*.zip` (esukh) and `backupParkly-*.zip` (parkly) by name,
verifies the zip, keeps **only the current one** locally (700 dirs), never touches the remote.
`restore_parkly.sh` restores into `parkly_new` and swaps database names; `restore_esukh.sh`
imports into `esukh_new` and moves every table with one atomic `RENAME TABLE` (242 tables,
1 view re-created, no triggers - the script refuses if triggers appear). Both leave the live
database untouched on any failure. `nightly_sources.sh` (root cron **04:10 UTC = 12:10 UB**,
flock, logs in `dbbackup/logs/`) runs pull -> restore -> `pipeline.sh trigger`; the DAG has
**`schedule=None`** since today so bronze is always loaded from the fresh copy. SSH key
`/root/.ssh/id_ed25519` (ssh-copy-id done 10-06). `pg-parkly` is now a compose project
(`/home/developer/parkly`, **postgres:16** - the remote switched to pg_dump 16, G13) with a
named volume and `restart: unless-stopped`; `mysql-esukh` already was (`/home/developer/mysql`).
The esukh import (13.5 GB of SQL, `balance` alone ~16M rows) takes hours at ~80k rows/min.

**Allowlists widened from team documents.** `make_phase1.py --columns-doc` reads a source
team's safe-columns document, intersects with our dump, and writes a waiver citing the
document for every validator hit it keeps (`--exclude` removes columns the document should
not have kept, `--include` adds lookup labels). esukh: `docs/esukh-data-copy-review.docx`
(the returned copy of our 09-30 proposal, pre-dating the photo/credential rules) -> **166
tables / 1,390 columns**; `user.image`, `worker.image`, `roomimage.image`, `cost.costimage`,
`coupon.image`, `electricpayed.image`, `user.validateCode` excluded by hand. smartpay:
`docs/smartpay_models_columns_safe.md` -> 31 tables / 266 columns, 17 doc waivers
(reference-table `name`/`description`, `faq`, `aiFunctionCall`). All waivers say PROVISIONAL.

**Layer routing is real now.** A phase-1 table whose columns need no token and no drop
holds no personal data -> `target_layer = bronze-ref` (not vacuumed, longer retention);
anything with a person/vehicle/room token or a dropped column -> `bronze`. Result: esukh
85/81, myproperty 35/43, parkly 20/7, smartpay 13/18, sma 4/16 (bronze-ref/bronze).
`tokenize_silver.py` reads both layers, so silver stays the one complete layer. Treatment
change in the same step: `buildingId/blockId/floorId` are passthrough (shared by many
households, needed to group KPIs by complex); `roomId/contractRoomId` stay tokens.
The lake was rebuilt from scratch (bronze, silver, watermarks deleted; demo bronze-ref twins
of phase-1 tables deleted, 7 demo-only tables kept) and reloaded by a manual DAG run.

**End state 2026-10-06 21:00 UTC** (after the rebuild run, three reload chains and the esukh
tokenise rerun at 2 GB): bronze 144 / bronze-ref 145 (incl. 7 demo-only + 2 demo twins) /
silver 282 tables registered; silver = esukh 139, myproperty 69, parkly 26, smartpay 30,
sma 18; 0 half-written directories; sources esukh and parkly = today's remote backups.

**Catalog: all three layers registered, including bronze.** Operator decision 10-06 after
seeing an empty `bronze` in DBeaver. Rationale accepted: thrift binds to 127.0.0.1 only, so
anyone who can reach it already has a shell on this host and could read `/lake/bronze`
directly. Policy §4 still says humans/BI/dbt get no route to bronze - **revisit before thrift
is ever exposed beyond loopback or given external users.** `pipeline.sh register` now
registers bronze, bronze_ref and silver and drops entries whose directory is gone.

**KPI MCP server** (`mcp/`, containers `hti-mcp-kpi` + `hti-caddy`): 58 KPIs from the PDF
mapped to SQL over **silver + bronze_ref only** (7 available, 22 partial, 29 unavailable with
the table that would unlock each); `run_sql` is SELECT-only, layer-checked, 200-row cap.
`bronze` is deliberately not exposed to an LLM client. **Public at
`https://datamgt.esukh.mn/mcp`** (operator request 10-06): Caddy on **0.0.0.0:80/443** - the
first and only HTI service reachable from the internet; rule "all ports loopback-only"
now has exactly this exception - terminates TLS (Let's Encrypt, auto) and proxies to
mcp-kpi. Auth is OAuth 2.1 implemented in `mcp/auth.py` (dynamic client registration,
PKCE, one operator login `MCP_LOGIN_USER/PASSWORD` on `/login`, SQLite token store in the
`mcp_oauth` volume, 1 h access / 30 d refresh, 5 failures -> 15 min IP lock). The static
`MCP_TOKEN` still works on the loopback tunnel path. Attack surface = Caddy + this Python
app + whatever the Spark SQL guard misses; the guard is regex-based, so treat `run_sql`
as the thing to harden at N10. See `mcp/README.md`.

**Token map = the dictionary.** `hti-token-db` (`tokenmap/`), table
`token_map(source_system, entity_type, natural_value, token)`; `entity_type` is the column
name, so the same person's `userId` maps to the same UUID across one system's tables. Look-ups
go through `tokenmap/.env` credentials (`tokenadmin`); the job role can only SELECT/INSERT.
Reading it re-identifies people - data-officer territory, log who asks and why.

## 5g. 2026-10-08: esukh team's column document, person-key tokenisation, Алхам 1

**The esukh team returned a real column-level document** — `docs/Data preparation For Esukh.docx`,
172 tables (was 19), each with `Allowed to pass:` / `Хасах / далдлах:` (remove or mask) /
`Холбоос / тэмдэглэл:` (links and notes). It is now the authority for the esukh filter, exactly
as MyProperty's masking inventory is for theirs. **The document says so itself and we keep that
caveat:** *"Allowed to pass нь аналитикт дамжуулах санал бөгөөд эцсийн зөвшөөрөл биш"* — a
proposal, not a final approval. Every row stays `PENDING-REVIEW-2026-10`.

`jobs/esukh_doc_to_columnsdoc.py` converts the .docx into the canonical columns-doc text
(`docs/esukh_columns_doc_2026-10-08.txt`) that `make_phase1.py --columns-doc` already consumed for
smartpay; only the **unconditional** part of each list is taken, because 13 entries end in a
condition the team has not discharged ("after the approved service/state fields are separated
out") and a condition is not an approval. `Бүх багана` ("all columns", `advertize`,
`advertizeBranch`) is **refused** — a wildcard is exactly what §4 forbids, so those two tables
keep their pattern-derived lists.

    esukh phase 1:  166 tables / 1,390 columns  ->  110 tables / 822 columns
    0 errors, 33 warnings, 32 waived

The team's lists are *narrower* than our pattern filter nearly everywhere (`user`: 15 columns ->
5 — they drop `image` and `validateCode` themselves, which we had removed by hand on 10-06). 29
columns are newly permitted; 28 are lookup labels (`town.townName`, `reference.name`,
`action.name`, `branch.name`…) and get CT015 waivers citing the document.

**Three waivers were written by hand because the auto-generated justification was wrong:**
- `propertycaraccess.registeredWorkerId` — CT015 matched `register`; this is not a national
  register number, it is the worker who registered the access. It **is** a person reference and
  is tokenised, not passed through. The generic "not a person identifier" text would have misled
  the data officer into signing the opposite of what happens.
- `adminaccount.tokenVersion` — CT018 matched `token`; a JWT invalidation counter, not a secret.
- `barrier.barrierName` — marked **UNVERIFIED**: the team's own document asks whether
  `barrierName` holds personal information and has not answered. Waived to keep the load running,
  flagged for them.

**`counter` is refused** (`control_table_esukh_phase1_excluded.csv`): the team allow only
`jsondata`, an opaque JSON blob, and omit the primary key, so CT011 fires and the content is
unknown. Fail closed until they say what it holds.

**51 doc tables are skipped because they are in `control_table_esukh_excluded.csv` as
correspondence tables** (policy 4.1.4): `post*`, `message`, `forum*`, `news*`, `complain*`,
`help*`, `massmail`, `internalad*`, `poll_*`. The team now proposes columns for them. This is the
same conflict as MyProperty's 12 correspondence tables and is a **data-officer decision, not
ours** — nothing was auto-included.

### G18 — a person table's own primary key was passed through

Found while doing Алхам 1. `treat()` said *own primary key -> passthrough, "surrogate row key of
this table, not a person identifier"*. For `esukh.user`, `esukh.worker`, `myproperty.owner`,
`myproperty.tenant`, `sma.Users`, `sma.Cars` that is false: **every row of those tables IS a
person or a vehicle**, so the PK identifies one. Consequences, both real:

1. The source system's live user id reached the lake in the clear, and because such a table may
   have no *other* token column, the 10-06 layer router sent it to **`bronze-ref`** — never
   vacuumed, visible to BI. `silver.esukh_user` still has `id: integer`, ~241k rows.
2. **The KPI joins silently fail.** `entity_type` is the column name (`tokenize_silver.py`
   line ~210), so `Users.id` would mint a *second*, different token for someone who already has
   one as `UserCars.userId`. Counting users is fine; joining them is not.

Fix: `Rule` gains an optional **`entity`** alias (7th column of `transform_rules.csv`, empty =
use the column name, so nothing existing changed). `PERSON_ROW_PK` in `make_phase1.py` maps those
six tables to the namespace their own foreign keys already use — verified against the live token
map: esukh `userId` 115,543 tokens, sma `userId` 43,934, sma `carId` 38,222. Same namespace +
same natural value = **same token**, so `Users.id` now joins `UserCars.userId` and **no existing
token was re-minted**. All six tables moved `bronze-ref -> bronze`.

**The token namespace is fragmented and this fix does not solve that** — see §9. 58 entity types
for 943,115 tokens, and in esukh one person is minted separately as `userId` (115,543),
`currentUserId` (26,296), `createdUserId`, `approvedWorkerId`, `regWorkerId`, `oldWorkerId`,
`rateWorkerId`, `raterWorkerId`, `khanWalletUserId`… Each is a different UUID for the same human,
so no cross-table person analysis works today. Unifying them re-mints tokens and forces a silver
rebuild, so it is a decision, not a patch.

### Tightening a filter does not clean what is already in silver

Silver is the durable layer and is never vacuumed, so the narrower esukh list governs **future
loads only**. Measured against the new allowlist, `silver` (139 esukh tables) holds:

| | count |
|---|---|
| tables no longer on the allowlist at all | 31 |
| tables carrying source columns the team now excludes | 70 |
| those columns, total | 195 |
| of which credential / network / financial identifiers | 36 |

The 36 include `barrier.code`/`ip`/`sn`, `billinglog.ip`, `log.ip`, `adminbranchentry.requestIp`,
`branch.certificate`, `property.financeCode`/`stateCode`/`erchimCode`, `electricpayed.merchantCode`,
`balance.qpayObjectId`, and `formula` on 8 tables. **Nothing was deleted** — dropping 31 silver
tables and rebuilding 70 is destructive and needs sign-off (§9).

### Алхам 1 of the KPI completion plan

Of the 8 allowlist items (`docs/KPI_UNLOCK_REQUESTS_2026-10-06.md`):

| # | Item | Done |
|---|---|---|
| 1 | `sma.Users` → `id, lastLogged, createdAt, updatedAt` | yes (`gender`, `birthDate`, `menuOrder`, `deviceId` left out — not needed for KPI 1/2/4 and `gender`/`birthDate` need CT106 banding) |
| 2 | `sma.Cars` → `+ markName, modelName`, **`plateNumber` removed** | yes (2 CT015 waivers: a car's make and model are not a person's name) |
| 5 | `sma.AuctionSubscriptionBills` | already loaded |
| 6 | `myproperty.room.createdAt` | yes |
| 3 | sma subscription product (`priceInfo`) | **impossible** — no such table in any dump; `priceInfoId` points outside the database |
| 4 | `sma.IotSubscriptions` payment status | **impossible** — no status column exists |
| 7 | parkly entry log | **refused** — the table is `inOutHistory` (not `access`, which does not exist; the 10-06 note was wrong) and the **parkly team classified it RED** in their own privacy PDF. An owner's explicit RED is not ours to override. |
| 8 | `bronze_ref.complex_grade` | loader built, data missing |

`jobs/load_reference_csv.py` (new) loads a hand-maintained reference CSV into `bronze-ref` as
Delta. Deliberately **not** a general CSV importer: the schema is declared in `REFERENCES`, so a
spreadsheet column cannot become a lake column by being in row 1; `grade` is a closed enum
(`үнэтэй`/`дундаж`/`хямд`) and one bad value fails the whole load rather than inventing a
category; at least one of `townId`/`buildingId` must be set; overwrite only, since a reference
list is current truth with no history. Template: `jobs/reference/complex_grade_TEMPLATE.csv`.

    sma phase 1:  20 -> 22 tables, 180 columns
    all five control tables: 0 errors

## 5h. 2026-10-08: Алхам 2 — enum values read from the lake, not asked for

The plan's Алхам 2 was "take the value lists to the owning teams". Those lists are already in
`silver`, so they were queried first (`docs/ALKHAM2_ENUM_CONFIRMATION_2026-10-08.md`). Three
outcomes, and only one of them is a question for a team.

**Solved.** `myproperty.room.type` is self-describing: `PARK` 90 = garage, `STORAGE` 19 =
warehouse, `APARTMENT` 50 = dwelling, the rest commercial. KPI 9/11 need one confirmation, not a
meeting.

**But myproperty is the wrong source for KPI 7/9/11.** 2,100 rooms, only 50 `APARTMENT` — it is
commercial property management. `esukh.property` holds **202,335** rows (`propertyType` 1 =
152,344, 2 = 44,873, 3 = 5,118). The residential KPIs belong on esukh. Open question in §9.

**`esukh.reference` was loaded without its labels.** `silver.esukh_reference` had no `name` or
`shortname` column, so no coded esukh column could be resolved. Those two columns are lookup
labels, not personal data; the team's 10-08 document permits them and they are now loaded (§5i).
**Corrected 2026-10-09:** this does NOT resolve "every coded column", as first written here.
`branch.serviceType` resolves properly (124 = СӨХ, 98 = lift maintenance, 125 = security, 567 =
cleaning — a real KPI dimension). But `property.propertyType` is **not** a `reference` foreign
key: its values 1/2/3 collide with `reference`'s top-level category ids and a naive join returns
confident nonsense ("Санал, гомдол, дуудлагын төрөл" for 152,344 dwellings). `barrier.subType` is
mixed — 574 resolves to `ZLAN`, 1 and 2 collide. **Which columns genuinely reference `reference`
must be taken from the esukh team's "Холбоос / тэмдэглэл" notes, never assumed**; the rest are
app-level enums for `kpi_value_map`. A wrong label that looks right is worse than a bare code.

**Three KPIs are blocked by a missing source field, not by our filter** — worth being precise,
because "the filter blocks it" would be the wrong diagnosis:
- KPI 16/18 (paid in the app): `myproperty.payment.method` is `BANK_TRANSFER`/`QPAY`/`CREDIT`/… —
  the *instrument*, never the *channel*. `QPAY` can be paid from any bank app. No app value exists.
- KPI 15 (invoice created by the user): `invoice.payerType` is `TENANT`/`OWNER` — who **pays**,
  not who **created**. A creator id we could tokenise; the field has to exist first.
- KPI 40 (bundled payment): `smartpay.transaction.type` is NULL on 87,466 of 87,600 rows;
  `userFeeType` is `PERCENT`/`FIXED` (how a fee is computed, not whether it was bundled).
- KPI 35/36: `productPaymentType` has only `PURCHASE` 197 / `PAYMENT` 93 — ask smartpay which is
  which, and whether 290 invoices is really the whole history or our dump is partial.

### G19 — tokenising a business category is silent data loss, not a privacy win

`treat()` tokenises any column whose name carries a person word. Eight columns matched on an
incidental word while holding a category, a config value or a **counter**, so the value became a
UUID and the KPI that grouped by it could no longer be computed. The clearest: the token map's
natural values for `smartpay.merchant.userFeeType` were literally `FIXED` and `0` — a
`varchar(10) DEFAULT 'PERCENT'` fee type turned into two UUIDs. Also
`parkly.camera_health_log.processedPlates`, an `integer DEFAULT 0`.

Found by joining the live token map against the rules and looking at every entity type with <60
distinct values: a person reference with 5 distinct values is a small team, a *category* with 5
distinct values is a category. `"...Type"`/`"...Types"` is the giveaway — a type is a category OF
a thing, never the thing.

Fixed with `NOT_A_PERSON` in `make_phase1.py` (8 entries, each checked against the declared type
and the distinct values); token rules 185 -> 177. The fail-safe direction stays `token`.
**The UUIDs already in silver are only recovered by a reload.**

`bronze_ref.kpi_value_map` (new, in `load_reference_csv.py`) holds the confirmed meanings —
`(source_system, source_table, source_column, source_value) -> kpi_meaning, confirmed_by` — so
KPI SQL joins to it instead of hardcoding a value, exactly as the plan requires. `confirmed_by`
must be non-empty or the load is refused: an unconfirmed guess must never drive a KPI.

## 5i. 2026-10-09: the reload — what worked, and why silver cannot just be rebuilt

**Bronze is done and is the real win.**
- `bronze.esukh_reference` now carries `name` and `shortname` (521 rows), so every coded esukh
  column can finally be resolved — the §5h blocker for KPI 7–12 and 37.
- `user`, `worker`, `branch` rebuilt under the 10-08 allowlist, which **removed 31 columns the
  esukh team withdrew** — `certificate`, `stampImage`, `logoImage`, `address`, `gender`,
  `otpDate`, `vatId`, `khanWalletUserId`, `mqttCarUrl`, `externalId` and more. Tightening the
  filter actually deleted data for the first time, rather than only governing future loads.
- `sma.Users` 95,342 rows and `sma.Cars` 42,568 rows — first load ever, KPI 1/2/4/26.
- `myproperty.room` + `createdAt` (2,100 rows).

Two loader capabilities were needed and are now permanent, both guarded:
- **`--reset-watermark`** (requires `--tables`). Adding a column to an `incremental` table without
  it populates the column only for rows that changed since the last run, leaving the table holding
  two different shapes of truth. Refused without `--tables` because a blanket reset would re-read
  `esukh.monthlypayment` (~16.5M rows).
- **`--allow-narrowing`**. The schema-drift guard refused `user`, `worker` and `branch` outright,
  which was backwards: it left bronze holding exactly the columns the owner had just withdrawn.
  Narrowing is now permitted, but only when the drift is `dropped` and never `retyped`, only when
  the table is read in FULL (otherwise an overwrite loses rows the source no longer returns), and
  never silently — it logs every column it stops holding.

### G21 — MERGE silently drops a new column, so silver never widens

`tokenize_silver.py` merged with `whenMatchedUpdateAll().whenNotMatchedInsertAll()` and no
`autoMerge`. A column bronze has gained is then **silently discarded**: no error, no warning, the
run reports success and silver stays the old width. That is exactly how
`esukh.reference.name`/`.shortname` stayed missing — bronze had them after the reload, tokenise
said "tokenised 1/1", and silver was still 12 columns wide. Worse than a loud failure, because
every signal said it had worked.

Fixed by setting `spark.databricks.delta.schema.autoMerge.enabled=true` on the tokenise session.
It only ever ADDS a column, and the columns reaching it are exactly the allowlisted ones
`load_bronze` copied, so it cannot widen past the allowlist. The re-run wrote 521 rows where the
previous one wrote 0, and the labels appeared.

### G20 — silver is the system of record; bronze is a 24-hour staging area

The plan was to drop the 12 affected silver tables and let them rebuild. **Measured live row
counts (tracking `remove` actions, not just `add`) say that would destroy history:**

| table | bronze | silver |
|---|---|---|
| `parkly_camera_health_log` | 1,352 | **196,257** |
| `myproperty_tenant` | **0** | 1,423 |
| `smartpay_merchant` | **0** | 13 |
| `parkly_camera` | 167 | 213 |

Bronze holds at most 24 hours (N5 vacuum, `--retain-hours 0`); silver accumulates by MERGE. For
`parkly_camera_health_log` a rebuild would have cut 196,257 rows to 1,352 — a 99.3% loss. Proven
rather than assumed: tokenising `smartpay.merchant` reported "tokenised 1/1, **0 rows**" and left
`_tokenised_at` at 10-07, because bronze had been vacuumed to empty.

Corollary: **Delta log `stats` are not live rows.** `minValues`/`maxValues` persist after a delete,
so `bronze/myproperty_owner.ownershipType` still reported `FULL` on a table whose rows were gone.
Any row count must subtract `remove` actions.

**So the fix for silver is an in-place migration, not a rebuild**, and the token map makes it
lossless in both directions:
- the 8 wrongly-tokenised business columns (G19): UUID -> original value by joining
  `token_map` on `(source_system, entity_type, token)` — the values are still there
  (`userFeeType` -> `FIXED` / `0`);
- the 6 person-table primary keys (G18): raw id -> token by the forward join, minting any missing.

Every silver row is preserved. Not built yet — it rewrites silver in place, so it needs sign-off.

**Also found: 7 layer orphans** — `esukh_branch`, `esukh_reference`, `sma_iotsubscriptions`,
`sma_notifyons`, `sma_subscriptionbills`, `smartpay_merchantpermission`, `smartpay_pos` exist in
*both* `bronze` and `bronze-ref` after earlier layer-routing changes. Checked: none holds a
withdrawn column, so this is stale duplication rather than a leak. A `bronze -> bronze-ref` move
self-cleans (the vacuum deletes the bronze copy); the reverse would leave a permanent stale copy
in `bronze-ref`, which is not vacuumed. Worth a guard in the loader.

## 5j. 2026-10-09 (later): narrowing applied to bronze, and how to count drift

19 incremental esukh tables rebuilt under the 10-08 allowlist, 3,074,593 rows re-read, **36
withdrawn columns removed from bronze** — among them `statebankstatement.acntNo` (a bank account
number), `qpayhistory.qpayData`/`callbackUrl`/`qpayId`, `vat.requestData`/`qrJson`,
`billinglog.ip`, `adminbranchentry.requestIp`, `burtelog.data`/`response`,
`negdihistory.checkid`/`tranid`/`settleId`, `mainconfighistory.prevFormula`/`newFormula`,
`electricpayed.merchantCode`/`ccode`, `module.logo`, `probill.code`.

**Remaining: 39 tables / 96 columns, all `full` mode** (`monthlypayment` 18M, `balance` 5.1M,
`propertyconfig` 1.3M …). No incremental table drifts any more.

### Counting drift: measure the TARGET layer, not "bronze first"

Earlier figures in §5i-era notes (67 tables / 176 columns) were **overcounts**: the script looked
in `bronze` and fell back to `bronze-ref`, while the loader writes to whichever layer the control
table names (`target_path(row)`). Where a table had a stale copy in the other layer, the stale
copy was measured instead of the live one. `esukh_taskassignment` is the worked example — its
`bronze` copy has 11 columns and **0 rows** (vacuumed long ago) and still lists `userId`, while
the live `bronze-ref` copy has 10 columns, 33 rows and is clean. The loader would never have
failed on it. Any drift or row count must be taken from `target_layer`.

### 8 tables exist in both layers; only 2 are real duplication

`esukh_branch` (bronze 440 / bronze-ref 432) and `esukh_reference` (521 / 521) hold rows in both.
The other six — `esukh_taskassignment`, `sma_iotsubscriptions`, `sma_notifyons`,
`sma_subscriptionbills`, `smartpay_merchantpermission`, `smartpay_pos` — have 0 rows in `bronze`
and are harmless empties the vacuum left behind. None holds a withdrawn column, so this is stale
data in a BI-visible layer rather than a leak: `bronze_ref.esukh_branch` serves a 432-row,
26-column version of a table whose live copy has 440 rows and 49 columns. The loader should
delete the other layer's copy when a table's `target_layer` changes.

### KPI server: 4 KPIs moved partial -> available

`mcp/kpis.py`: KPI 1 (95,342 users), 2 (29,099 active, 30.52%), 4 (real `createdAt`) and 26
(42,586 cars, 11.6 yrs average, 144 makes) now read the real `sma.Users`/`sma.Cars`. Available
count 7 -> 11. KPI 2's ratio is only coherent because of the G18 token-namespace fix, and KPI 26's
join only works for the same reason. KPI 1 also returns `newest_registration` — **2025-12-08** —
so the stale sma dump shows up inside the KPI's own answer instead of being invisible.

`mcp/Dockerfile` **COPY**s `kpis.py` into the image, so editing it and restarting changes nothing:
`docker compose up -d --build mcp-kpi` is required. A restart silently served the old definitions.

## 6. Runbook

```bash
cd /home/developer/hti-platform
docker compose up -d                       # picks up .env changes (restart does NOT)
docker compose logs -f spark-thrift        # wait for "HiveThriftServer2 started"
docker compose restart spark-thrift        # re-reads conf/spark-defaults.conf (bind mount), not .env
docker compose up -d --force-recreate spark-thrift   # after .env change
docker compose down                        # keeps volumes
docker compose down -v                     # ALSO wipes metastore-data + ivy-cache (fresh install path)
# ad-hoc job (and how Airflow will call it). NOTE: no password on the command line
# since N1 - conf/spark-entrypoint.sh writes hive-site.xml inside the container (G5).
docker compose --profile jobs run --rm spark-jobs \
  /opt/spark/bin/spark-submit /opt/jobs/<job>.py --control-table /opt/jobs/control_table_<sys>.csv \
  --source-system <sys>
docker compose --profile jobs run --rm spark-jobs \
  /opt/spark/bin/spark-submit /opt/jobs/vacuum_bronze.py        # nightly retention (N5)
```

## 7. Gotchas log (all hit for real — do not repeat)

- **G1 MinIO gone.** `minio/minio` and `minio/mc` deleted from Docker Hub 2026-09-11; Quay gated ~09-24. Do not reintroduce MinIO. Alternatives if S3 API is ever needed locally: SeaweedFS (mature) — not RustFS (alpha).
- **G2 Bind-mounted file missing → Docker creates a directory.** `conf/spark-defaults.conf` must exist before first `up`. Fix: `down`, `rm -rf conf/spark-defaults.conf`, place file, `up -d`.
- **G3 `--packages` jars invisible to the Hive metastore.** DriverManager only sees the boot classpath → `No suitable driver found for jdbc:postgresql`. Fixed with `spark.driver.extraClassPath /tmp/ivy/jars/*`. Side effect: on a fresh box the first start fails once (nothing downloaded yet) and the restart policy makes the second succeed. Hardening option: have `lake-init` `wget` the 4 jars from Maven Central into a volume and drop `spark.jars.packages`.
- **G4 Named volumes are root-owned; Spark runs as uid 185.** `ivy-cache` needed a chown → done in `lake-init` (`chown -R 185:185 /lake /ivy`). Any new volume mounted into Spark containers needs the same.
- **G5 Password on the command line is echoed to logs. FIXED (N1, 2026-09-29).** `start-thriftserver.sh` prints the full launch command including `ConnectionPassword=`. Two passwords leaked this way; the second produced a 121 MB log across 15 crash-loop restarts. Fixed by `conf/spark-entrypoint.sh`, which writes the password into `hive-site.xml` (mode 600) inside the container, exports `SPARK_CONF_DIR=/tmp/spark-conf`, and unsets the variable before exec so the JVM never inherits it. Verify with `docker logs hti-spark-thrift | grep -c ConnectionPassword` -> must be 0. Residual: the password is still in the container env (`docker inspect`); closing that needs a Docker secret, folded into the N4 vault decision.
- **G6 Postgres password only applies at volume init; `restart` does not re-read `.env`.** Mismatch → `password authentication failed for user "metastore"`. **The test previously given here was wrong and gives a false pass:** `psql -h 127.0.0.1` from *inside* the container matches initdb's default `host all all 127.0.0.1/32 trust` line and succeeds whatever the password is. `metastore-db` publishes no port, so the only valid test is from another container on the platform network:
```bash
export PGPASSWORD="$(awk -F= '/^METASTORE_PASSWORD=/{print $2}' .env)"
docker run --rm --network hti-platform_platform -e PGPASSWORD postgres:16-alpine \
  psql -h metastore-db -U metastore -d metastore -tAc 'select current_user'
```
Note `-e PGPASSWORD` with no value, so the secret passes through the environment rather than appearing in `docker run`'s argv. **Fixing a mismatch - which method depends on whether the catalog holds anything:**
- **Empty catalog → `docker compose down -v`.** Postgres re-initialises from `POSTGRES_PASSWORD`, so `.env` and Spark cannot drift apart; no secret is written anywhere.
- **Catalog with content → `ALTER USER` + `.env` + `up -d --force-recreate spark-thrift`.** `down -v` wipes `metastore-data`, and every `CREATE TABLE ... USING DELTA LOCATION` registration goes with it (the Delta files survive; the registrations do not). Keeping `ivy-cache` also avoids the jar re-download and the G3 first-start failure. Used on 2026-09-30 with 24 tables registered; `RestartCount=0`.

`down` *without* `-v` keeps the volume and changes nothing; that is what makes this look unfixable.
- **G8 DataNucleus `autoCreateAll` deadlocks against the first `CREATE TABLE`.** Symptom: beeline hangs forever on a fresh metastore. No error, no timeout, nothing in the Spark log after `Creating directory ... /lake/warehouse/<table>`, and the Spark UI shows no job. Cause: DataNucleus builds the metastore schema *lazily*, so a second `ObjectStore` was still adding foreign keys while the first `CREATE TABLE` transaction held `TBLS`. The FK `ALTER TABLE` waits on that transaction; the transaction sits `idle in transaction` waiting on the client; the client waits on the FK. Postgres never breaks it - the holder waits on the *client*, not a lock, so the deadlock detector never fires. Diagnose with:
  ```sql
  select pid, pg_blocking_pids(pid), state, left(query,60) from pg_stat_activity
   where datname='metastore' and cardinality(pg_blocking_pids(pid))>0;
  ```
  Unwedge with `pg_terminate_backend(<the idle-in-transaction pid>)`. Fixed permanently by seeding `conf/metastore-schema.sql` at volume init and setting `autoCreateAll false`. **Do not seed from a `pg_dump` of a running metastore** - lazy creation means the dump only contains what has been exercised (ours had 34 of 57 tables, missing `FUNCS` and `NOTIFICATION_LOG`), so `autoCreateAll false` would then fail at some arbitrary later point instead. The committed file is assembled from the Hive 2.3.9 release scripts with checksums in its header, and is pinned to the Spark version - regenerate it if the Spark pin moves.
- **G9 `docker compose` run from inside a container needs identical host paths.** Airflow drives jobs through the platform's compose file. Compose resolves relative bind mounts (`./conf/spark-entrypoint.sh`) against the project directory *as the calling container sees it*, but the Docker daemon resolves those source paths **on the host**. Mount the project at `/platform` inside Airflow and the daemon looks for `/platform/conf/spark-entrypoint.sh` on the host, finds nothing, and creates an empty **directory** - the job then dies with `"/opt/spark-entrypoint.sh": is a directory`, which is G2 arriving by a new route. Fix: mount the project at the same absolute path it has on the host (`..:/home/developer/hti-platform:ro`) and set `PLATFORM_DIR` to match. Symptom: a stray top-level directory appears on the host containing your config *filenames* as empty directories.
- **G7 `$` in a password breaks compose interpolation.** Use `$$` in `.env` or generate with `openssl rand -base64 24` (never produces `$`).

- **G10 Delta `VACUUM` lists files with 10,000 Spark tasks by default.** `spark.sql.sources.parallelPartitionDiscovery.parallelism` defaults to 10,000; on a two-file bronze table that is 10,000 near-empty tasks at ~30 ms, so `vacuum_bronze.py` took ~2 min **per table** (~2 h for 69 tables, ~5 h for five systems) and would have overrun the night. Set to 8 in `conf/spark-defaults.conf` on 2026-10-04. Measured after the fix: 69 tables in 12 min (~10 s/table, stages of 50 tasks instead of 10,000). Two follow-ups in the same job: an empty *partitioned* table (every partition already dropped) was reported as "not partitioned - retention NOT enforced" because the check counted directories; it now reads `partitionColumns` from the Delta log. And VACUUM leaves empty `_load_date=` directories behind, which the next run re-deleted and re-vacuumed for nothing; they are now skipped and removed.
- **G11 Spark refuses to write pre-1582 timestamps (`WRITE_ANCIENT_DATETIME`).** `smartpay.card.expdate` is a *string* ("12/27"); the phase-1 generator banded every column ending in `date`, `cast("timestamp")` produced year-0012 values, and the Parquet writer aborted the whole table. Two fixes: `make_phase1.py` now bands only columns whose **declared type** is temporal (a string "date" is passthrough/drop), and card data (`*pan`, `maskedpan`, `expdate`, `expiry`, `cvv`) is dropped outright. Safety net: `spark.sql.parquet.*RebaseModeInWrite/Read = CORRECTED` in spark-defaults, because MySQL `0000-00-00` arrives as 0001-01-01 and must not kill a load.
- **G12 Five parallel Spark jobs do not fit in 7.9 GB.** Each `spark-jobs` container is ~1.2 GB, thrift another 1.2 GB, Airflow ~1.5 GB, the restored source databases ~1.3 GB. On 2026-10-04 a load ran beside a vacuum and the first parkly load died silently with 345 MB free. DAG now has `max_active_tasks=2`. Still hit 287 MB free on 10-06 with two first-time full loads beside the esukh import; the Airflow **webserver** (1 GB, UI only) can be stopped for the duration without affecting the run - the scheduler drives tasks - and so can thrift (1.2 GB at start, **2 GB after registering ~240 tables and serving KPI queries**; `docker compose restart spark-thrift` shrinks it back in a minute). 113 MB free was reached on 10-06 with thrift at 2 GB + one load + the esukh import. **This host needs more RAM (16 GB) before a sixth system or any dbt run - N10.** When killing a job container, identify it by `docker logs <c> | grep 'Submitted application:'` - `docker ps` order is not the start order, and I killed the wrong one once.

- **G13 `pg_restore: unsupported version (1.15) in file header`.** The remote parkly dump is now written by pg_dump 16 (archive format 1.15); a PG14 `pg_restore` cannot read it even though the source server is PG14. `pg-parkly` runs `postgres:16-alpine` since 2026-10-06. Also hit: `DROP DATABASE cannot run inside a transaction block` - only the two `ALTER DATABASE ... RENAME` go in one transaction.

- **G14 First full loads of five systems found two loader defects (2026-10-06).** (a) A JDBC read is ONE partition unless told otherwise, and MySQL Connector/J buffers the whole result set client-side: `esukh.balance` (~16M rows) killed the driver with `Java heap space`. `read_source` now splits on the numeric primary key (MIN/MAX bounds query, ~400k rows per partition, max 24) and appends `useCursorFetch=true` to MySQL URLs. (b) `/lake/_watermarks` is one Delta table written by every concurrent load; a MERGE there collided with the other load's commit (`ConcurrentAppendException`) and the loader reported it as a failure of the *data* table (parkly `camera_health_log`, sma `AdminLogins`) whose rows were already written. The merge is now retried with jitter (7 attempts). Both only show up when many tables write watermarks at once, i.e. on first loads - nightly incremental runs had hidden them.

- **G15 One Spark session tokenising 166 tables runs out of execution memory at the default 1 GB driver heap.** The esukh tokenise died at table ~100 (`SparkOutOfMemoryError: UNABLE_TO_ACQUIRE_MEMORY`) and, because the JVM went away, the Python side printed no summary - the 39 tables after it alphabetically were silently never written. Fixes: `--driver-memory 2g` on every spark-submit (`pipeline.sh`, DAG `_compose`), `spark.catalog.clearCache()` after each table in `tokenize_silver.py`, DAG `max_active_tasks=1` (two 2 GB drivers do not fit beside thrift, Airflow and the databases). Lesson: a per-table FAILED list is not enough - compare the silver directory count with bronze+bronze-ref after every tokenise (`pipeline.sh lake`).
- **G16 `GROUP_CONCAT` truncates at 1,024 characters by default.** `restore_esukh.sh` built its 482-move `RENAME TABLE` with it and got a syntax error from the truncated tail; the statement is now assembled in bash. `--swap-only` reruns just the swap after a successful import.
- **G17 One table directory with an empty `_delta_log` aborts the whole catalog registration.** A write cut short by the memory crunch left `silver/esukh_qpayhistory/_delta_log/` without a commit; `CREATE TABLE ... USING DELTA LOCATION` on it raised `DELTA_CREATE_EXTERNAL_TABLE_WITHOUT_TXN_LOG` and beeline stopped at the first error, so everything after it in the batch (all of parkly's silver) stayed unregistered while the script reported nothing. `pipeline.sh register` now skips log-less directories and runs beeline with `--force=true`.

- **G18 a person table's own primary key is not a surrogate key.** `make_phase1.treat()` passed any `col == primary_key` straight through as a "surrogate row key". True for `balance.id`, false for `user.id`/`worker.id`/`owner.id`/`tenant.id`/`Users.id`/`Cars.id`, where the row *is* the person or the car - so the source system's live user id reached the lake, and a table with no other token column was routed to `bronze-ref` (never vacuumed, BI-visible). Second, subtler half: `entity_type` is the column name, so tokenising such a PK would mint a *different* token than the FKs pointing at it and every cross-table person join would silently return nothing. Fixed with an `entity` alias column in `transform_rules.csv` + `PERSON_ROW_PK` (§5g). Tokenising a person table's PK is only safe once the namespace is decided.

## 8. Next pieces, in order (each one = a check-in)

- ~~**N1** `hive-site.xml` generated in-container from env (removes G5).~~ **DONE 2026-09-29** - `conf/spark-entrypoint.sh`, wired as the container `entrypoint` (not `command`) so `docker compose run --rm spark-jobs spark-submit ...` inherits it too.
- **N2** `jobs/control_table.csv` — the allowlist: `source_system, source_table, target_layer (bronze|bronze-ref), load_mode (incremental|full), primary_key, watermark_column, columns_allowlist, purpose_ref`. HTI's data officer signs this; nothing loads that is not in it. **Validator done 2026-09-29** (`jobs/validate_control_table.py`); the CSV itself still needs the data officer.
  **Inventory done 2026-09-29** - and it does not match Data Ger: **241 tables, not 152** (+59%), and **112 declared FKs, not 368**, so most relationships are application-level and FK lineage will be incomplete. Only 61 of 241 tables are touched by a declared FK. See `esukh_schema_analysis.md` for the 9-domain proposal and the classification: 64 correspondence tables (excluded whole, policy 4.1.4), ~183 identity columns, ~126 free-text columns, ~141 tokenise candidates.
  A naive allowlist of all 241 tables scores **371 errors** against the validator. Triaging those into `control_table_exceptions.csv`, each with a justification and a name, *is* the data-officer review.
  **Draft generated 2026-09-29, regenerated 2026-09-30 as rules were added** - now 166 proposed / 76 excluded / 242 accounted for, every table in exactly one of `control_table.csv` or `control_table_excluded.csv`. It fails with 166 `CT013` **on purpose**: `purpose_ref` is empty, so it cannot load until purposes are assigned. Every row is `bronze`; a heuristic that promoted 60 tables to `bronze-ref` was reverted as unsafe (a table can hold personal data via FK with no personal-looking column name, and `bronze-ref` retains longer than 24h). Promotion is a per-table data-officer decision - candidates in `esukh_schema_analysis.md` section 7.1.
  **Verified against the live database 2026-09-29** (via `readuser` on the local `mysql-esukh` restore): 241 BASE TABLEs, matching the extracted schema exactly - no gaps, no extras - plus 1 VIEW (`towncorporate_state`) that the CREATE TABLE extractor skipped. The view is listed in `control_table_excluded.csv`: a view is derived, so a table-level allowlist does not describe which underlying columns it exposes. 242 objects now accounted for.
  Outstanding for the data officer: assign `purpose_ref` per row; waive the ~13 over-filtered lookup tables (`category`, `profession`, `position` - their only real column is a non-personal `name`); confirm the 9 domains; decide `bronze-ref` promotions.
- **N3** `jobs/load_bronze.py` — **WRITTEN 2026-09-29; run against real restores of all four systems 2026-09-30** under temporary review purpose refs (production loading still blocked on N2 signing).
  **Four bugs surfaced only once a non-MySQL source was used, all fixed:** (a) the JDBC driver was hardcoded to MySQL - now derived from the URL scheme; (b) `--insecure-no-tls` only recognised `mysql-*` hostnames - now any dotless (container) hostname, still refusing anything with a dot; (c) identifier quoting used backticks - now dialect-aware, which matters because parkly's camelCase columns only resolve when double-quoted; (d) table paths are lowercased, so `PaymentOptions` and `paymentoptions` would collide.
  **Postgres read-only users need more than `GRANT SELECT`:** on PG <= 14 the `public` schema grants `CREATE` to `PUBLIC`, so the first `parkly_reader` could create tables. Needs `REVOKE CREATE ON SCHEMA public FROM PUBLIC` and `REVOKE ALL ON DATABASE <db> FROM PUBLIC`. Applies to the real smartpay and parkly users too. Config-driven Spark JDBC loader: incremental `MERGE` on PK, `overwrite` for the rest; adds `_ingested_at`, `_load_date`, `_source`; partitions by `_load_date`; `mergeSchema` on; **stops the run** on dropped/retyped columns (new columns pass, since the allowlist already gates them).
  Controls verified by test: refuses any control table with validation errors (so the current unsigned draft is refused); `--tables` can only narrow the control table, never add to it; only allowlisted columns appear in the SELECT, never `*`; credentials come from `<SYSTEM>_DB_{URL,USER,PASSWORD}` env vars, never argv; TLS required, and `--insecure-no-tls` refuses any non-local host. One table failing does not abort the others, but the run still exits non-zero.
  Run it with `spark-submit` - `pyspark`/`delta.tables` are not on plain `python3`'s path in this image. `--dry-run` needs neither Spark nor a database.
  **End-to-end verified 2026-09-29 against synthetic data** (throwaway MySQL on the platform network, no replica involved - policy section 4). Proven, not assumed:
  - allowlist filtering: source had a `customer_name` column left out of `columns_allowlist`; it is absent from the resulting Delta schema.
  - first load: 3 rows, Delta table created, partitioned `_load_date=2026-09-29`, audit columns present.
  - incremental MERGE: 1 updated + 1 inserted row read (only the 2 past the high-water mark); Delta v1 shows `numRecords=4`, `id` 1..4, updated value present - no duplicates.
  - schema drift: `amount` retyped decimal->varchar at source stopped the run (`retyped {'amount': ('decimal(10,2)', 'string')}`), Delta stayed at v1 so bronze was not corrupted.
  - exit codes: a failed table exits **1** through `spark-submit` and `docker compose run` (N8 alerting depends on this).
  **Watermark store fixed 2026-09-30 - `/lake/_watermarks`.** The high-water mark used to be
  `max(watermark)` read from the bronze table itself, which breaks the moment N5 exists: vacuum
  deletes bronze partitions older than a day, so by the next run `max()` is NULL and **every one of
  the 171 incremental tables silently degrades to a full re-read of the source**, with no error.
  Silver is not a safe home either - the transform may band that very timestamp, destroying the
  precision the watermark needs. It is now a small Delta table keyed on
  `(source_system, source_table)` holding a max value per table (not personal data), written
  **only after a successful write** so a crash cannot advance it past rows that never landed.
  Verified on the myproperty load: `watermark recorded: updatedAt = 2026-09-23 03:56:14.408000`.
  Neither N3 nor N5 was wrong alone - the interaction only appears once both exist.

  **Known gap:** because the loader SELECTs explicitly named columns, a column *dropped at the source* fails as a JDBC "unknown column" error, not via `check_schema_drift`. That check covers retyped columns and columns removed from the allowlist. Both stop the run; the messages differ.
  **Credentials wiring (2026-09-29):** `docker-compose.yml` passes `ESUKH_DB_{URL,USER,PASSWORD}` into both Spark services. URL and user are not secrets and default in compose (`readuser`, host 43.231.113.13); the password has no default and lives only in `.env` (chmod 600). Adding another source system is three more lines in `x-spark-common`. Defaults use `:-` not `:?` deliberately: a missing source password must not stop `spark-thrift` from starting, and `load_bronze.py` refuses clearly on its own.
  **TLS caveat - the first real connection will fail until this is handled.** The default URL sets `sslMode=VERIFY_CA`, which needs the source server's CA certificate in the JVM truststore; without it Connector/J aborts the handshake. Either install the CA (mount it and point `javax.net.ssl.trustStore` at it) or set `ESUKH_DB_URL` in `.env` with `sslMode=REQUIRED` as a stopgap - REQUIRED encrypts but does **not** authenticate the server, so it does not protect against an interception attack on a link carrying personal data. `VERIFY_CA` is the default on purpose: the safe option should be the one you get for free.
- ~~**N4**~~ **DONE 2026-10-02 (recorded 2026-10-04).** `tokenmap/` = separate compose project `hti-tokenmap`, container `hti-token-db` (Postgres 16, no published port, on `hti-platform_platform`), schema seeded at volume init from `tokenmap/schema.sql`: `token_map(source_system, entity_type, natural_value, token uuid)` with the unique key **including `source_system`**, so the same plate in esukh and parkly gets different tokens - cross-system linking (section 9) would be a deliberate schema change, not a flag. Role `tokenise_job` has SELECT+INSERT only: a token must never change or every silver row silently re-points to a different person. **Vault choice still open** - credentials are `TOKENMAP_DB_*` in `.env`, same as the metastore (flagged, not solved).
  `jobs/tokenize_silver.py` (NOT `tokenize.py` - that shadows the stdlib module and breaks `import logging` before `main()`). Driven by **`jobs/transform_rules.csv`**, one row per allowlisted column with a treatment `token | time_band | passthrough | drop`; the job **refuses to run if any allowlisted column has no rule**, because tokenising fails unsafe (a mis-classified `propertyId` reaches gold and cannot be unpublished) whereas filtering fails safe. Silver is written by MERGE, never overwrite - bronze holds only each night's delta once N5 runs, so silver is the accumulating layer. Regenerate rules with `jobs/make_phase1.py` (2026-10-04; the 10-02 generator was lost in a scratchpad). 1,396 rules across five systems, all `approved_by` = PROVISIONAL.
- ~~**N5** `jobs/vacuum_bronze.py`~~ **DONE 2026-09-30.** Partition drop + VACUUM with the retention check disabled **in that session only**; verifies deletion; fails loudly.
  Verified on a 4-partition fixture: dropped 3 partitions, files 4 -> 1, only today's partition left on disk, exit 0.
  **Deliberately NOT driven by the control table.** `load_bronze.py` refuses to run on an invalid allowlist, which protects data from being copied; a deletion job must behave the opposite way, or a validation error silently stops deletion and personal data accumulates. It walks `/lake/bronze` instead. `bronze-ref` is untouched.
  **It verifies rather than trusts:** after vacuuming it re-counts Parquet files in the dropped partitions and fails if any remain - a VACUUM that reports success while files persist is the failure that matters, because you would believe deletion happened.
  **Retention arithmetic, and it does not give a 24h ceiling with the documented defaults.** A partition is dropped up to `(keep_days+1)*24` hours after it is written, and `VACUUM ... RETAIN <n> HOURS` then leaves the files `n` hours longer - so `RETAIN 24 HOURS` means worst case ~48h on disk, not 24. The job prints this as a warning rather than implying a guarantee. `--retain-hours 0` deletes immediately but can break a concurrent reader mid-query. **The intended figure needs a data-officer decision** (open item).
  Tables with no `_load_date` partitioning are reported as errors, not skipped: their retention cannot be enforced at all.
- **N6** dbt project (`dbt-spark`, thrift): `sources` = silver; `staging` views; `marts` Delta tables (`file_format: delta`, `incremental_strategy: merge`); snapshots for SCD2; tests; suppression views. Naming standard from Data Ger: `esukh_parking_fact_...`, `esukh_..._dim_...`.
- **N7** serving Postgres + gold → Postgres JDBC export job; Power BI read-only role.
- ~~**N8**~~ **DONE 2026-09-30, extended 10-02 and 10-04.** `airflow/` = separate compose project `hti-airflow` (own Postgres, webserver on **127.0.0.1:8080** only, admin creds in `airflow/.env`). Jobs run via `docker compose --profile jobs run` against the platform's own compose file (mounted at its **host path** - G9), so mounts/entrypoint/credentials are defined once. Airflow holds the Docker socket = root-equivalent on this host; accepted for a single-operator single node, documented in the compose file, revisit at N10.
  DAG `hti_nightly`, 02:00 daily, `catchup=False`, `max_active_runs=1`:
  `validate_control_tables` (stdlib validator run in-process, `retries=0`, ~1s) → `load_bronze_<sys>` ×5 → `tokenize_silver_<sys>` ×5 (each depends only on its own load) → `dbt_build` (**fails by design** - N6 not built) → `export_serving` (N7, same) → **two leaves**: `vacuum_bronze` (`ALL_DONE`, `--retain-hours 0`, `retries=0`) and `pipeline_ok` (`ALL_SUCCESS`). `max_active_tasks=2` (G12). **`schedule=None` since 10-06** - triggered by `dbbackup/nightly_sources.sh` after the restores (5f). Manual driving: `airflow/pipeline.sh` (trigger / status / logs / load / tokenize / vacuum / register / lake). Both hang off `export_serving`: chaining `pipeline_ok` after `vacuum` looked equivalent and was not - `ALL_SUCCESS` only inspects direct upstreams, so the run stayed green after a failed load. Three bugs found only by running it: `start_date` in the future (every run "succeeded" in 40 ms with zero tasks), `.env` at 600 unreadable by uid 50000 (now 640, rule 8), and G9.
  **Every nightly run is red until N6 exists** (`dbt_build` fails on purpose). Loads, tokenisation and vacuum do run.
- **N9** Open Metadata: MySQL, Delta (metastore mode), dbt artifacts, Airflow, Power BI connectors.
- **N10** Hardening: deterministic jar download (G3), per-bucket/folder permissions, pgAudit on token map, re-identification (k-anonymity) test script, deletion-cycle verification report.

## 9. Open decisions (need HTI / data officer, not Claude)

- Hosting stays local (this server) vs DO Singapore → policy 14.1 legal check.
- BI tool: Power BI (Data Ger recommendation, licence) vs Metabase.
- Whether an LLM analytics bot is wanted (reads gold only, semantic layer, full query log).
- Cross-system token linking (same plate in esukh and Parkly) — off until decided.
- Retention line for silver event detail (starting proposal: 12 months, then aggregate + delete).
- Purpose register entries per report (policy step 1) — prerequisite for N2.
- **Token namespace unification** (§5g/G18). 58 entity types for 943k tokens; one esukh person is
  a different UUID in every column that points at them. Unifying re-mints tokens and forces a
  silver rebuild. Until decided, only *within-column* person analysis is valid.
- **Silver cleanup after the 10-08 esukh tightening** (§5g): drop 31 now-unallowlisted silver
  tables and rebuild 70 that carry 195 now-excluded columns (36 of them credentials/IPs/codes).
  Destructive — needs the data officer's word, and bronze must be re-pulled for anything rebuilt.
- **esukh correspondence tables** (51): the team's 10-08 document proposes columns for tables
  policy 4.1.4 excludes whole. Same question as MyProperty's 12. Nothing auto-included.
- **esukh `counter.jsondata`** — what does the JSON hold, and may `id` be copied?
- **esukh `barrier.barrierName`** — the team's own open question: does it contain personal data?
- **parkly `inOutHistory`** is RED. KPI 24/25 need it. Only parkly can re-classify it.
- **Which system is the residential estate for KPI 7/9/11** — `esukh.property` (202,335 rows) or
  `myproperty.room` (2,100 rooms, 50 of them dwellings)? §5h. Almost certainly esukh.
- **Silver in-place migration** (§5i/G20) — approve or decline. The bronze half of the reload is
  done; silver still holds 8 columns of UUIDs that should be business values and 6 raw person
  primary keys. A rebuild would destroy history (bronze is vacuumed), so the fix is a token-map
  join that rewrites those columns in place. Lossless, but it rewrites silver.
- **8 tables in both layers, 2 with rows in both** (§5j). `bronze_ref.esukh_branch` serves a stale
  26-column version. Loader should delete the old copy on a `target_layer` change.
- **39 full-mode esukh tables still hold 96 withdrawn columns** (§5j) and will fail the nightly
  drift guard until reloaded with `--allow-narrowing`. Decide whether that flag belongs in the DAG
  permanently, so an owner narrowing their list applies instead of breaking the run.
- **Missing source fields, not filter problems**: payment channel (KPI 16/18), invoice creator
  (KPI 15), bundled-payment marker (KPI 40). Each needs an app change by the owning team.
