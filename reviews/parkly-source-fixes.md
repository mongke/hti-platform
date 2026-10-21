# parkly — recommended source-database fixes

Prepared 30 September 2026 for the parkly engineering team.

Findings come from the database schema only. No table data was read, so where a column looks like a stored secret we can say what the definition allows, not what the values are — those questions are for your team. Each item says what it costs the analytics platform, so you can weigh it against your own priorities.

## 1. Summary

| Metric | Value |
|---|---|
| Tables in the database | 69 |
| Tables with no update timestamp | 4 (5%) |
| Tables with no primary key | 0 |
| Composite primary keys | 1 |
| Case-colliding column names | 1 |
| Credential-looking columns | 7 |
| Possible citizen register numbers | 0 |


## 2. Stored secrets — highest priority

Whether these hold plaintext cannot be told from a schema. Two things can: a column named for its protection (passwordHash) tells a reader it is hashed, and a column too short to hold any standard hash cannot be storing one.

| Column | Type | Named as protected | Note |
|---|---|---|---|
| `externalSystem.apiPasswordHash` | character varying(255) | yes | naming states protection |
| `merchant.password` | character varying NOT NULL | no |  |
| `merchant.token` | character varying | no | no length limit declared |
| `routerConfig.wifiPassword` | character varying(255) | no |  |
| `system_admin.password` | character varying NOT NULL | no |  |
| `worker.loginPass` | character varying(255) | no |  |
| `worker.mobileToken` | text | no | no length limit declared |

- For each column above: is the value plaintext, reversibly encrypted, or hashed? If hashed, which algorithm?
- Any plaintext password: hash with bcrypt or argon2 and force a reset cycle.
- Any credential that must stay replayable (third-party logins): encrypt at rest with a key held outside the database.
- Rename to state the protection (password -> passwordHash), so the next reader does not have to ask.
- Declare a length. An unbounded text column for a secret hides both truncation bugs and unexpected values.


## 3. Missing update timestamps

4 of 69 tables have no updatedAt-style column. Without one there is no way to ask "what changed since last night?", so the platform must re-read the entire table on every run. For small reference tables that is harmless. For large transactional tables it is a full scan every night, forever. Adding a column that is set on every update converts that into reading only the rows that actually changed.

```
compare, feedback_comment_attachments, feedback_issue_histories, models
```


## 4. Structural issues

| Issue | Where | Why it matters |
|---|---|---|
| Composite primary key | `models (workerId, WorkerId)` | Supported, but a single surrogate key is simpler for incremental loading and downstream joins. |
| Columns differ only in case | `models (workerid)` | Legal in PostgreSQL, impossible in analytics engines that treat identifiers case-insensitively. Blocks copying entirely. |


## models has two columns differing only in case

models has both workerId and WorkerId, both in its composite primary key. Legal in PostgreSQL because quoted identifiers are case-sensitive, but impossible to load into most analytics engines, which treat identifiers case-insensitively. The table cannot be copied until one is renamed.
