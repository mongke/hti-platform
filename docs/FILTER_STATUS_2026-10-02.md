# Production filter status, built from ./docs (2026-10-02)

What each source team supplied, what could be built from it, and what still needs a decision.
Nothing here is loadable: `purpose_ref` is empty on every row, so the validator refuses all five.

## Coverage

| System | Document supplied | Covers | Production filter built? |
|---|---|---|---|
| **myproperty** | `MyProperty_Data_Masking_Inventory_2026-10-02.xlsx` | 950 columns / 92 tables, every column classified P0/P1/P2 | **Yes** — 92 tables, 699 columns |
| **parkly** | `parkly-postgresql-tables-hti-privacy.pdf` | 55 of 69 tables, Red/Normal, **table-level only** | **Partly** — 27 proposed, 42 excluded |
| **sma** | `sma-data-copy-review.docx` (our doc, revised) | 39 copied + 8 excluded, 32 column lists | **Blocked** — needs a fresh dump |
| **esukh** | `Data preparation For Esukh.docx` | **19 of 241 tables (7%)**, A→branchHelp, ends mid-entry | **No** |
| **smartpay** | *(nothing supplied)* | — | **No** |

`Смарт Монгол туслах app KPI.pdf` is a KPI document, not a filter input.

## myproperty — built, 18 conflicts to resolve

The inventory is the best input of the five: one row per physical column, with P0 (secrets, remove
outright), P1 (identity / free text / files / raw JSON), P2 (check and decide). Filter = all 950
columns minus the 250 masked. Only 1 inventory column was absent from our 2026-09-30 dump.

**Their list is stricter than our pattern filter in 221 places** — our filter was too permissive.
They mask `archiveFile.filePath`/`fileUrl`, `bankStatement.raw`/`referenceNo`/`relatedAccount`,
`branch.address`/`logoUrl`/`sealUrl`, and exact `createdAt`/`updatedAt` on many tables. The last is
consistent with CT106: an exact timestamp is a quasi-identifier and needs banding.

### Our filter over-detecting — WAIVED 2026-10-02 (4)
Recorded in `jobs/control_table_myproperty_exceptions.csv`, attributed to the platform team and
labelled a filter false positive, **not** a policy exemption.

| Column / table | Rule | Why it is a false positive |
|---|---|---|
| `pollAnswer.questionId`, `pollOption.questionId` | CT016 | foreign key to `pollQuestion.id`, not free text |
| `roomBooking.bookerSubjectId` | CT016 | identifier, not a message subject line |
| `branchSupportVar` | CT014 | configuration variable table; "support" is not a support-ticket table |

(The fourth was first written against `pollQuestion`, which has no `questionId` column - `CT102`
caught it as a stale waiver and it was corrected to `pollOption`. That is the stale-waiver rule
doing its job.)

### Genuine policy decisions — data officer (14)
**Correspondence tables with content columns already removed.** They propose keeping metadata only
(who, when, status) from `message`, `helpRequest`, `news`, `newsRead`, `notification`,
`userNotification`, `poll`, `pollAnswer`, `pollOption`, `pollQuestion`, `pollResponse`,
`branchMessageFormat`, `branchBuildingMessageFormat`.
Policy 4.1.4 excludes correspondence tables **whole**, on the basis that the content is the payload.
Their position is defensible - the bodies are stripped - but message *metadata* still reveals who
contacted whom and when, which is communication-pattern data. **This is the single biggest decision
in this round.** Either the policy admits a metadata-only carve-out, or these 13 stay excluded.

**Credential-store tables with the secrets removed:** `ekontorCredential`, `workerDeviceToken`.
`passwordEncrypted`, `username` and `token` are gone, leaving ids, flags and timestamps. CT019
refuses the table regardless, on the grounds that a credential store has no analytical value.
Cheaper to leave excluded than to argue, unless there is a real reporting need.

## parkly — built at table level only

27 Red tables now excluded on the team's classification, including `car`, `inOutHistory`, `inLog`,
`inRecord`, `worker`, `merchant`, `Payments`, `parkLocation` - the plate and vehicle-movement core.
That is a significant and welcome narrowing.

**The PDF gives no column detail**, so the 27 surviving tables still use our pattern-derived column
filter. They need a column-level pass like myproperty's before this is production-ready.
`spayCheckLog` appears in our allowlist but in neither Red nor Normal - unclassified.
`feedback_system`, `models`, `loggerV2` and `sma_exit_correction_request` are named in the PDF but
are not in our dump, so their schema has moved on.

## sma — blocked on a fresh dump

They revised our document properly: dropped `ActiveUsers` ("dead table, not planned to be used"),
added tables, adjusted column counts. **11 tables they approved do not exist in our 2026-09-30
dump**: `Admins`, `CarOwnerRelationTypes`, `DanServiceResponses`, `NotificationPreferences`,
`ParkingGuestInvites`, `PropertAds`, `PropertyAdChatMessages`, `PropertyAdImages`, `UserCarPostgre`,
`WalletPasses`, `WalletRegistrations`. We cannot validate columns for tables we have no schema for,
so this needs a current `sma_db` dump before the filter can be built.

Their `UserCarPostgre` also replaces our `userCarPostgre`/`userCarPostgres` pair - which is the
CT014 false positive we logged ("post" matching "Postgre").

## esukh — 7% covered, and it conflicts with policy in 16 places

The document covers 19 of 241 tables and stops mid-entry at `branchHelp`. It cannot produce a
production filter. It also approves columns policy forbids:

| Table | Approved column | Rule |
|---|---|---|
| `branch` | `phone`, `email`, `invoiceMail` | CT015 - contact details, never copied |
| `blackListProperty` | `description` | CT016 - free text about a resident |
| `apartment` | `apartmentName` | CT015 - may be a person's name |
| `branch`, `balance`, `Action`, `billingLog` | `name`, `partnerName`, `paymentNameApp` | CT015 - needs the name triage |

**Six of the 16 were our filter over-detecting and are now WAIVED (2026-10-02).** These columns were
also *added back* to the esukh allowlist, since a waiver only clears an error on a column that is
actually in the list - waiving a column we were not copying would have matched nothing and raised
`CT102`:

| Column | Rule | Why it is a false positive |
|---|---|---|
| `adminaccount.tokenVersion` | CT018 | token **metadata** - a version counter used to invalidate sessions, not the token |
| `branch.messageLimit`, `branch.messageMultiply` | CT016 | numeric SMS configuration, not message content |
| `branch.logoImage`, `bgImage`, `stampImage` | CT015 | organisation branding, not photographs of people |

**The remaining ten are a direct conflict** between what the esukh team wants and what policy
section 4 permits - `branch.phone`, `branch.email`, `branch.invoiceMail`,
`blackListProperty.description`, `apartment.apartmentName`, and the `name` columns. Those columns
have **not** been added to the allowlist and are **not** waived. Only the data officer can settle
them.

## What is needed next

1. **Data officer:** the correspondence-metadata question (myproperty, 13 tables) - the decision
   that unblocks the most.
2. **Data officer:** the esukh conflicts, especially `branch.phone`/`email`.
3. **esukh team:** finish the document - 222 of 241 tables remain.
4. **parkly team:** a column-level pass for the 27 Normal tables.
5. **sma team:** a current dump, so their 11 new tables can be validated.
6. **smartpay team:** no document yet.
7. **Everyone:** `purpose_ref`. All five filters reject on CT013 until a purpose register exists.

## Update 2026-10-14 — credential columns filtered out (parkly, esukh)

Seven columns holding plaintext credentials are now **filtered out** of every control table, so
they never enter the lake (not even raw bronze). Column-level record with reasons:
`jobs/control_table_parkly_excluded_columns.csv`, `jobs/control_table_esukh_excluded_columns.csv`.

| System | Table | Columns filtered out |
|---|---|---|
| parkly | `camera` | `pass`, `addSignature`, `deleteSignature`, `selectSignature`, `getRecordSignature` |
| parkly | `routerConfig` | `routerPass`, `anydeskPass` |
| esukh | `camera` | the same five as parkly `camera` |

The generator (`jobs/make_phase1.py`) now removes any credential-named column from the allowlist
after `--include`, and the validator (CT018) flags `signature` and names ending in `pass`. Details,
and what is still open (purging existing lake copies, rotating the credentials):
`docs/CREDENTIALS_IN_SILVER_2026-10-14.md`.
