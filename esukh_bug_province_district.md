# Bug report — branch province/district mismatch (esukh)

**Reported by:** HTI data platform team
**Date:** 2026-09-29
**Severity:** Medium — silent data corruption, still occurring
**Found:** while building the analytics platform's reference-data layer, by validating
`branch.province` / `branch.district` against the `reference` hierarchy.

## Summary

8 of 432 rows in `branch` have a `district` that does not belong to the stated `province`.
`reference.root` defines the hierarchy (district → parent province), and for these rows
`reference.root(district) <> branch.province`.

**7 of the 8 point at the same district: Чингэлтэй дүүрэг (id 276), an Ulaanbaatar district,
recorded under rural аймаг.**

## Affected rows

| branch_id | province (claimed) | district (recorded) | district's real parent | created |
|---|---|---|---|---|
| 166 | 374 Ховд аймаг | 113 Хан-Уул дүүрэг | 66 Улаанбаатар | (null) |
| 254 | 445 Дорноговь | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | (null) |
| 330 | 447 Завхан | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | (null) |
| 448 | 441 Баян-Өлгий | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | 2025-10-30 |
| 458 | 443 Булган | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | 2025-12-04 |
| 472 | 445 Дорноговь | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | 2026-01-09 |
| 578 | 440 Архангай | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | 2026-08-27 |
| 581 | 449 Өмнөговь | 276 Чингэлтэй дүүрэг | 66 Улаанбаатар | 2026-09-03 |

**This is ongoing, not historical.** The newest affected record was created 2026-09-03.

## Suspected cause

The district dropdown appears to default to Чингэлтэй дүүрэг (276). When a user selects an
аймаг in the province field, the district list is likely not reset or re-filtered, so the
default value is saved unchanged. That would explain why 7 of 8 cases are the same district,
and why they are spread across many different provinces.

## Suggested reproduction

1. Create or edit a branch.
2. Set province to any аймаг (e.g. Архангай).
3. Do **not** touch the district field.
4. Save, then re-read `branch.province` and `branch.district`.

Expected: saving is blocked, or district resets to one belonging to the chosen province.
Observed (inferred): district remains 276 (Чингэлтэй дүүрэг).

## Suggested fix

1. **Reset and re-filter** the district list whenever province changes, so only districts with
   `reference.root = <chosen province>` are selectable.
2. **Validate on save** — reject when `reference.root(district) <> province`. This is the
   important one: it stops the problem regardless of UI behaviour, including API writes.
3. **Backfill** the 8 rows above, in consultation with each organisation about the correct district.

## How to verify

```sql
SELECT b.id, b.province, b.district, d.root AS district_parent
FROM branch b JOIN reference d ON d.id = b.district
WHERE d.root <> b.province;
```

Same check likely applies to `apartment`, `company` and `town`, which carry the same
`province`/`district`/`committee` columns — we have not checked those.

## Note

This was found from a 2026-09-29 restore of the esukh backup, not from the live database, so
counts may differ slightly from production today. No personal data was involved in this analysis.
