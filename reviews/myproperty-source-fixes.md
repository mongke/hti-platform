# myproperty — recommended source-database fixes

Prepared 30 September 2026 for the myproperty engineering team.

Findings come from the database schema only. No table data was read, so where a column looks like a stored secret we can say what the definition allows, not what the values are — those questions are for your team. Each item says what it costs the analytics platform, so you can weigh it against your own priorities.

## 1. Summary

| Metric | Value |
|---|---|
| Tables in the database | 96 |
| Tables with no update timestamp | 13 (13%) |
| Tables with no primary key | 0 |
| Composite primary keys | 0 |
| Case-colliding column names | 0 |
| Credential-looking columns | 6 |
| Possible citizen register numbers | 1 |


## 2. Stored secrets — highest priority

Whether these hold plaintext cannot be told from a schema. Two things can: a column named for its protection (passwordHash) tells a reader it is hashed, and a column too short to hold any standard hash cannot be storing one.

| Column | Type | Named as protected | Note |
|---|---|---|---|
| `branchBuildingCorporate.credential` | json | no |  |
| `branchCorporate.credential` | json | no |  |
| `ekontorCredential.passwordEncrypted` | text NOT NULL | yes | no length limit declared |
| `onboardingRequest.stateToken` | character varying(120) NOT NULL | no |  |
| `worker.passwordHash` | character varying(255) NOT NULL | yes | naming states protection |
| `workerDeviceToken.token` | character varying(500) NOT NULL | no |  |

- For each column above: is the value plaintext, reversibly encrypted, or hashed? If hashed, which algorithm?
- Any plaintext password: hash with bcrypt or argon2 and force a reset cycle.
- Any credential that must stay replayable (third-party logins): encrypt at rest with a key held outside the database.
- Rename to state the protection (password -> passwordHash), so the next reader does not have to ask.
- Declare a length. An unbounded text column for a secret hides both truncation bugs and unexpected values.


## 3. Missing update timestamps

13 of 96 tables have no updatedAt-style column. Without one there is no way to ask "what changed since last night?", so the platform must re-read the entire table on every run. For small reference tables that is harmless. For large transactional tables it is a full scan every night, forever. Adding a column that is set on every update converts that into reading only the rows that actually changed.

```
action, branchInvoiceHistory, contractBalanceHistory, contractDepositHistory, contractRoomService, invoicePayment, meterReading, ownerHistory, roomHistory, servicePackItem, tenantBalanceHistory, tenantHistory, workerAction
```


## 4. Structural issues

| Issue | Where | Why it matters |
|---|---|---|
| Possible citizen register numbers | `branch.registerNo` | varchar(10) matches the Mongolian citizen register format. If these are personal identity numbers they need the same care as passwords: restricted access, audit logging and a retention limit. |


## Credential naming here is the best of the five systems

worker.passwordHash, ekontorCredential.passwordEncrypted and onboardingRequest.codeHash all state what protection is applied. Anyone reading the schema can tell. This is the convention the other four systems should adopt; only branchCorporate.credential (json) is opaque.
