# HTI KPI analytics — tools

Read-only analytics over the Smart Mongol platform. Every answer is an aggregate: no
records, no identities, no writes. Groups with fewer than 5 records (or 5 people /
households) are suppressed. At most 200 rows per answer, 60 calls per minute.

| Tool | Use it to |
| --- | --- |
| `doc(tool?)` | read this documentation, or one tool's section |
| `list_kpis(status?)` | list the 58 KPIs |
| `get_kpi_definition(kpi_id)` | see what a KPI means and how it is computed |
| `get_kpi(kpi_id, date_from?, date_to?, grain?)` | compute a KPI |
| `list_tables(system?)` | list the queryable tables |
| `describe_table(table)` | see a table's fields and what each allows |
| `run_sql(sql)` | run one read-only SELECT that aggregates |
| `list_datasets(system?)` | same tables, as datasets for `query` |
| `describe_dataset(dataset)` | same as describe_table |
| `query(dataset, metrics, ...)` | aggregate without writing SQL |

Field roles (shown by describe_table / describe_dataset):

| Role | Allowed |
| --- | --- |
| dimension | select, group by, filter |
| measure | SUM, AVG, MIN, MAX |
| date | filter by range; group by day / week / month / year |
| count_distinct | only `COUNT(DISTINCT field)` — people, households, cars, cards, record ids |

## esukh calculation rules

- `esukh_balance.cost` = invoiced amount, `pay` = paid amount; sum those freely.
- `paymentBalance`, `prevBalance`, `monthBalance` are balances: take the latest row per property
  (highest `id`), never `SUM` across rows or months.
- `esukh_monthlypayment.priceSum` is a calculated charge (configuration), not a payment: do not add it
  to `balance`.
- `esukh_property.propertyType`: 1 = сууц, 2 = гараж, 3 = агуулах. `property.isDeleted` defaults to 1,
  so do not filter on it.
- `invoiceMonth` is YYYYMM (e.g. 202610).

## Data quality notes

- `esukh_monthlypayment.date` holds values from 2001 to 2031: about 499,000 rows are dated in the
  future and 442 before 2015 (a source-system issue, reported to the esukh team). Filter to a
  sensible range, e.g. `date_from="2020-01-01"` and `date_to` = today.
- `smartpay_*` reads the live SmartPay database since 2026-10-21 (it was a frozen copy that ended
  2025-12-08, with 290 invoices).
- `myproperty_payment.paymentDate` contains at least one date in 2027.

## doc

`doc(tool=None)` — this documentation. `doc("run_sql")` returns only that tool's section.

## list_kpis

`list_kpis(status=None)` — the 58 "Смарт Монгол туслах" KPIs with id, title, status and an
English definition. `status`: `available` (computed as written), `partial` (an
approximation), `unavailable` (the data does not exist yet).

Example: `list_kpis(status="available")`

## get_kpi_definition

`get_kpi_definition(kpi_id)` — Mongolian and English definition, how it is computed, the
tables it uses, caveats, and for partial/unavailable KPIs the missing data.

Example: `get_kpi_definition(14)`

## get_kpi

`get_kpi(kpi_id, date_from=None, date_to=None, grain="month")` — the KPI's numbers.
Dates are `YYYY-MM-DD`; `date_to` is exclusive; the default is the last 12 months.
`grain`: `day`, `week` or `month`. Unavailable KPIs return `result: null` and what is missing.

Example: `get_kpi(13, date_from="2026-01-01", date_to="2026-10-01", grain="month")`

## list_tables

`list_tables(system=None)` — the tables `run_sql` can read, as `silver.<table>`.
`system`: `esukh`, `myproperty`, `parkly`, `smartpay` or `sma`. Only these curated tables
are queryable.

Example: `list_tables(system="myproperty")`

## describe_table

`describe_table(table)` — the approved fields of one table with type, role and meaning.
Only these fields can be used in `run_sql` or `query`.

Example: `describe_table("silver.myproperty_invoice")`

## run_sql

`run_sql(sql)` — one read-only Spark SQL `SELECT`. The statement is parsed and checked:

- only `SELECT` (with `WITH` or `UNION`); anything that writes, `SET`, `SHOW`, `DESCRIBE` is refused
- tables: `silver.<table>` from `list_tables`; write the `silver.` prefix
- fields: those listed by `describe_table`; no `SELECT *` (`COUNT(*)` is fine)
- every selected value is aggregated or in `GROUP BY` (no row-level output, no window functions)
- `count_distinct` fields only as `COUNT(DISTINCT field)`
- a table's `id` only to join tables (`JOIN ... ON a.parkId = b.id`)
- functions: aggregates, date, math, string, `CASE`/`IF`/`COALESCE`/`CAST`
- groups under 5 are removed and the row count is capped at 200

Examples:

    SELECT date_trunc('month', issueDate) AS month, COUNT(*) AS invoices, SUM(totalAmount) AS billed
    FROM silver.myproperty_invoice WHERE issueDate >= '2026-01-01' GROUP BY 1 ORDER BY 1

    SELECT type, COUNT(*) AS rooms, ROUND(AVG(area), 1) AS avg_area
    FROM silver.myproperty_room GROUP BY type

    SELECT COUNT(DISTINCT userId) AS active_users
    FROM silver.sma_useractionlogs WHERE createdAt >= '2026-09-01'

    SELECT p.parkType, SUM(c.permaCar) AS permanent_cars
    FROM silver.parkly_parkaccessconfig c JOIN silver.parkly_park p ON p.id = c.parkId
    GROUP BY p.parkType

## list_datasets

`list_datasets(system=None)` — the same curated tables, named without `silver.`, with a
description and field count, for use with `query`.

## describe_dataset

`describe_dataset(dataset)` — same content as `describe_table`.

## query

`query(dataset, metrics, group_by=None, filters=None, date_field=None, date_from=None,
date_to=None, grain=None, order_by=None, descending=True, limit=100)` — aggregates without SQL.

- `metrics`: `count`, `count_distinct:<field>`, `sum:<field>`, `avg:<field>`, `min:<field>`, `max:<field>`
- `group_by`: up to 4 dimension fields
- `filters`: `{"field": value}` or `{"field": [values]}` on dimension fields (text without quotes, numbers, true/false)
- `date_field` + `date_from` / `date_to` (`YYYY-MM-DD`, `date_to` exclusive); `grain` `day|week|month|year` adds a `period` column

Examples:

    query("myproperty_invoice", ["count", "sum:totalAmount"], date_field="issueDate",
          date_from="2026-01-01", grain="month")
    query("myproperty_room", ["count"], group_by=["type"], filters={"type": ["PARK", "STORAGE"]})
    query("sma_useractionlogs", ["count_distinct:userId"], date_field="createdAt",
          date_from="2026-09-01", grain="week")
