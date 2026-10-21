# esukh filter rebuilt from the team's column document — 2026-10-08

Source: `docs/Data preparation For Esukh.docx` (received 2026-10-08, 172 tables).
Converted to `docs/esukh_columns_doc_2026-10-08.txt`, applied with
`python3 jobs/make_phase1.py --system esukh --columns-doc docs/esukh_columns_doc_2026-10-08.txt`.

The document is now the authority for which esukh columns may be copied, replacing our
pattern-derived list. **It is not an approval and we have not treated it as one** — the document
itself says *"Allowed to pass нь аналитикт дамжуулах санал бөгөөд эцсийн зөвшөөрөл биш"*. Every
row still carries `purpose_ref = PENDING-REVIEW-2026-10` and will not load for a signed purpose.

## What changed

| | before | after |
|---|---|---|
| tables | 166 | 110 |
| columns | 1,390 | 822 |
| validator | 0 errors | 0 errors, 33 warnings, 32 waived |

The team's lists are narrower than ours nearly everywhere. `user` went from 15 columns to 5
(`id, branchId, getVatType, createdAt, updatedAt`) — they exclude `image` and `validateCode`
themselves, which matches the rules we added on 2026-09-30.

29 columns are newly permitted. 28 are lookup labels (`town.townName`, `reference.name`,
`action.name`, `branch.name`, `paymentgroup.name`, `liftfloor.name`, …) — a label on a reference
row, not a person's name — and each carries a CT015 waiver citing this document.

## Decisions we could not make for you

### 1. Fifty-one correspondence tables (data officer)

The document proposes columns for 51 tables that policy 4.1.4 excludes **whole**: `post`,
`postcomment`, `postimage`, `postlike`, `message`, `forum`, `forumfiles`, `forumimages`,
`forumlike`, `news`, `newsfiles`, `newsimages`, `complainfiles`, `complainimages`,
`complainresult`, `complainResultFiles`, `help`, `helpcomment`, `helpCommentImage`,
`helpDeskStage`, `helpDeskTag`, `helpDeskTagFaq`, `massmail`, `internalAd`, `internalAdImage`,
`internalAdWhom`, `poll_question`, `poll_answer`, `poll_apartment`, `poll_chose_users`,
`poll_picture`, `branchHelpAssignee`, `branchHelpAssignmentLog`, `branchHelpTag`, and others.

**Nothing was included.** This is the same question as MyProperty's 12 correspondence tables:
the owner proposes keeping metadata after stripping the message body. Policy 4.1.4 currently says
the table is excluded whatever the columns are called. One ruling settles both systems.

### 2. `counter` — refused, needs one sentence from the esukh team

The document allows exactly one column, `jsondata`, and omits the primary key. Two problems: the
primary key would not be copied (CT011), and an opaque JSON blob of unknown content cannot be
cleared for analytics. Recorded in `control_table_esukh_phase1_excluded.csv`.

**Question:** what does `counter.jsondata` hold, and may `id` be copied?

### 3. `barrier.barrierName` — your own open question

The document asks *"barrierName-д хувийн мэдээлэл байгаа эсэхийг шалгах"* — check whether
`barrierName` contains personal information — and does not answer it. We waived CT015 so the load
runs, and the waiver is marked **UNVERIFIED** in
`control_table_esukh_phase1_exceptions.csv`. If gate names are ever a resident's name or flat
number, this must be reverted before silver is used.

### 4. "Бүх багана" (all columns) — refused by design

`advertize` and `advertizeBranch` say *all columns*. We do not accept a wildcard: a new column
added to the app would then flow into the lake with nobody having looked at it. Both tables keep
their previous explicit lists. Please send column names.

### 5. Thirteen conditional lists — the condition was not treated as approval

Thirteen entries end in a condition, e.g. `blackListPropertyHistory`: *"…; changedServices,
beforeState, afterState-аас зөвшөөрсөн үйлчилгээ/төлөвийг ялгасны дараа"* — after the approved
service/state fields have been separated out. That separation does not exist yet, so only the
unconditional part of each list was taken. The conditional columns are **not** copied.

## Two columns whose justification we rewrote

The waiver generator produces a generic sentence ("reference/business value, not a person
identifier per that document"). For three columns that sentence was wrong or unproven, and a data
officer signing it would have been signing the opposite of what happens:

- **`propertycaraccess.registeredWorkerId`** — CT015 matched `register`. It is not a national
  register number; it is the worker who registered the car access. It **is** a person reference
  and is tokenised to a UUID in silver, not passed through.
- **`adminaccount.tokenVersion`** — CT018 matched `token`. A JWT invalidation counter, not a
  secret or a token value.
- **`barrier.barrierName`** — see item 3; marked UNVERIFIED rather than justified.

## Already in silver, and not removed by this change

Silver is the durable layer and is never vacuumed, so a narrower filter governs **future loads
only**. Measured against the new allowlist, the 139 esukh tables in silver today hold:

| | count |
|---|---|
| tables no longer on the allowlist at all | 31 |
| tables carrying source columns the document now excludes | 70 |
| those columns, total | 195 |
| of which credential / network / financial identifiers | 36 |

The 36 include `barrier.code`, `barrier.ip`, `barrier.sn`, `billinglog.ip`, `log.ip`,
`adminbranchentry.requestIp`, `branch.certificate`, `property.financeCode`/`stateCode`/
`erchimCode`/`tCode`, `electricpayed.merchantCode`, `electricuser.ttCode`, `balance.qpayObjectId`,
`apartment.kontorCode`/`qpayInvoiceCode`, and `formula` on eight tables.

**Nothing was deleted.** Dropping 31 silver tables and rebuilding 70 is destructive and needs the
data officer's instruction; anything rebuilt also needs its bronze source re-pulled, because
bronze is vacuumed at 24 hours.
