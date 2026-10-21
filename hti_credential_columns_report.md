# Credential and identity-number columns across HTI application databases

**Reported by:** HTI data platform team
**Date:** 2026-09-30
**Severity:** High — needs confirmation per system; potentially critical for `smartpay_db`
**Scope:** `esukh`, `smartpay_db`, `sma_db`, `parkly` — schema (DDL) only, from each team's own
backup dumps. **No table data was read.**

## 1. Summary

While building the analytics platform we inventoried the schemas of all four application
databases. Every one of the four contains columns whose names indicate stored secrets —
passwords, PINs, API tokens, bank account numbers — and three contain what appear to be
**citizen register numbers**.

This is raised as one report rather than four because the pattern is consistent across systems
built by different teams, which makes it a practice question rather than four isolated defects.

**What we can determine from DDL:** the column exists, its name, and its type.
**What we cannot:** whether the stored value is plaintext, reversibly encrypted, or a one-way
hash. Only the owning team can answer that, and that is the ask of this report.

## 2. Why it matters regardless of the answer

- If any value is plaintext or reversible, a read-only leak of that table is a credential breach,
  not just a data breach — and for `smartpay_db` that is a payment-system credential.
- Citizen register numbers are personal data under the HTI Personal & Sensitive Data Protection
  Policy (2026-09-28) and are **never** copied into the analytics platform. They are listed here
  so each team knows they exist, not because we intend to use them.
- Only one column in four databases is *named* as a hash (`parkly.externalSystem.apiPasswordHash`).
  Naming is not proof, but it is the only signal available from outside, and its absence
  elsewhere means nobody reading the schema can tell whether the data is protected.

## 3. Findings by system

### 3.1 `smartpay_db` (Postgres 16) — highest priority

| Table.column | Type | Note |
|---|---|---|
| `admin.password` | `varchar(200)` | Not named as a hash |
| `merchant.authPassword` | `varchar(100)` | Not named as a hash |
| `userPin.tranPin` | `varchar(1000) NOT NULL` | **Transaction PIN.** 1000 chars is unusual — encrypted blob, or something else? |
| `token.token` | `varchar(1000)` | |
| `passwordResetToken.token` | `varchar(255)` | Expiry/single-use enforcement? |
| `card.tokenid` | `integer` | Card reference — confirm it is a gateway token, not a card number |
| `merchant.register`, `merchantRegister`, `subMerchantRegister`, `companyRegister`, `easyRegister` | `varchar(10)`–`varchar(20)` | See 3.5 |

This is a payment system holding a column named `tranPin` next to `admin.password`. We consider
it the most urgent of the four.

### 3.2 `parkly` (Postgres 14)

| Table.column | Type | Note |
|---|---|---|
| `system_admin.password` | `character varying` | **No length limit declared** |
| `merchant.password` | `character varying` | |
| `merchant.token` | `character varying` | |
| `routerConfig.wifiPassword` | `varchar(255)` | Infrastructure credential in an app table |
| `externalSystem.apiPasswordHash` | `varchar(255)` | Only column in any system named as a hash |
| `worker.mobileToken` | `text` | Push token, presumably |

### 3.3 `esukh` (MySQL 8)

| Table.column | Type | Note |
|---|---|---|
| `town.stateBankTransLoginName` / `…LoginPass` | `varchar(100)` / `varchar(105)` | **Third-party bank credentials.** `loginName`/`loginPass` pairs appear in several tables |
| `town.khanToken`, `branch.khanToken` | `varchar(245)` / `varchar(545)` | Bank API tokens |
| `bankAccountNumber` (several tables) | `varchar(20)`–`varchar(45)` | |
| `branchRegister`, `akrelRegister` | `varchar(10)`–`varchar(25)` | See 3.5 |

A `loginName`/`loginPass` pair strongly suggests credentials for a third-party system are stored
so the app can authenticate on a customer's behalf. If so they cannot be hashed — they must be
recoverable to be used — which makes **how they are encrypted at rest** the real question.

### 3.4 `sma_db` (MySQL 8)

| Table.column | Type | Note |
|---|---|---|
| `Users.pin` | `varchar(300)` | |
| `Users.expoToken` | `varchar(145)` | Expo push token — low sensitivity |
| `Users.registerNo` | `varchar(10)` | See 3.5 |
| `companyRegister`, `easyRegister` | `varchar(10)`–`varchar(50)` | |

Smallest exposure of the four.

### 3.5 Citizen register numbers — `varchar(10)`

`smartpay_db.register`, `sma_db.Users.registerNo` and `esukh.branchRegister` are all
`varchar(10)`. A Mongolian citizen register number is exactly 10 characters (two Cyrillic letters
plus eight digits), so these are very likely **personal national identity numbers**.

If so, they are sensitive personal data and need the same care as passwords: access control,
audit, and a retention limit. They are excluded from the analytics platform by policy.

## 4. What we are asking each team

1. For each column above: is the stored value **plaintext, reversibly encrypted, or hashed**?
   If hashed — which algorithm, and is it salted?
2. `smartpay`: what is stored in `userPin.tranPin`, and why is it 1000 characters?
3. `smartpay`: is `card.tokenid` a gateway token, or does any table hold a card number (PAN)?
4. `esukh`: are `loginPass` / `khanToken` encrypted at rest, and where does the key live?
5. `parkly`: why does `system_admin.password` have no declared length?
6. All: are the `varchar(10)` register columns citizen register numbers?

## 5. Recommended actions

1. **Confirm before changing anything** — answers to section 4 determine whether this is urgent
   or already handled.
2. Any plaintext password → hash with a modern KDF (bcrypt/argon2), force a reset cycle.
3. Any credential that must stay recoverable (third-party logins) → encrypt at rest with a key
   held outside the database, never in application config.
4. Restrict read access on these tables and enable audit logging.
5. Confirm no credential column is included in any analytics or reporting export.

## 6. Scope and method

Findings come from DDL extracted from each team's existing backup dumps on the platform server —
`pg_restore --schema-only` for Postgres, an awk filter keeping only `CREATE TABLE` blocks for
MySQL. Each extract was verified to contain zero `INSERT`/`COPY` lines, so **no row of data was
read from any system**. Column names and types are therefore all we know, which is exactly why
section 4 is questions rather than conclusions.

Dumps used: `smartpay_db_backup_2026-09-29_04-00-01.dump`,
`sma_db_backup_2026-09-30_02-00-01.sql`, `backupParkly-20260929_23_00_01.dump`, and the
2026-09-29 esukh restore. Production may differ.

## 7. Related, on the platform side

The same pattern appeared in the platform's own operational scripts on the backup server:
`/home/developer/mysql/backup_script.sh` had a production MySQL password on the command line
(fixed 2026-09-29 — now a `--defaults-extra-file` with mode 600), and `restore_script.sh` and
`restore_script_to_managed.sh` still contain plaintext credentials, including for a DigitalOcean
managed database. Those are ours to fix and are tracked separately; they are mentioned here only
because they are the same root cause.
