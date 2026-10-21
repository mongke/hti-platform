# HTI Data Platform — How to Get What Data

Oct 14, 2026 · @sis

## Start here

Ask the **HTI KPI** MCP server: it answers the 58 "Смарт Монгол туслах" KPIs and runs read-only SQL over the tokenised data of five systems. People appear only as UUID tokens, never names or IDs.

**Connect**

| Client | How |
| --- | --- |
| Claude Desktop / claude.ai | Settings → Connectors → Add custom connector → URL `https://datamgt.esukh.mn/mcp` → sign in with the operator login |
| ChatGPT | Settings → Connectors (Developer mode) → Create → same URL, OAuth |
| Claude Code | `claude mcp add --transport http hti-kpi https://datamgt.esukh.mn/mcp` |

**Which tool answers which question**

| You want | Call |
| --- | --- |
| What KPIs exist and which work today | `list_kpis(status?)` — status is available, partial or unavailable |
| What a KPI means, its formula and source tables | `get_kpi_definition(kpi_id)` |
| A KPI's numbers for a period | `get_kpi(kpi_id, date_from, date_to, grain)` — grain day, week or month |
| What data exists for a system | `get_data_dictionary(system?)` |
| What one table holds | `describe_table(table, layer)` — columns plus their meaning |
| Tables in a layer | `list_tables(layer, system?)` |
| Anything else | `run_sql(sql)` — one SELECT, max 200 rows |
| This guide | `get_guide()` |

`get_kpi_definition`, `get_data_dictionary` and `get_guide` are new as of 2026-10-14; before that the server had no dictionary or definitions.

## Data map

Five source systems feed two queryable layers: **silver**, with 281 tables of business data where every person identifier is replaced by a token, and **bronze\_ref**, with 142 tables of non-personal reference data. Raw **bronze** (personal data, kept 24 h) is never exposed.

| System | What it is | Silver tables | bronze\_ref tables | Source refresh | Last lake write |
| --- | --- | --- | --- | --- | --- |
| esukh | Apartment-owners association (СӨХ) billing: apartments, balances, payments | 138 | 72 | Nightly dump, restored 04:10 UTC | 2026-10-09 |
| myproperty | Property management: buildings, rooms, owners, tenants, invoices | 69 | 33 | Nightly dump (from 2026-10-14) | 2026-10-10 |
| parkly | Parking: parks, gates, access configuration, fees | 24 | 19 | Nightly dump | 2026-10-10 |
| smartpay | Payments: invoices, transactions, cards | 30 | 14 | On demand (last dump 2026-09-29) | 2026-10-10 |
| sma | Smart Mongol assistant app: users, cars, logs, subscriptions, listings | 20 | 4 | Nightly once SSH access is granted | 2026-10-10 |

Table names are `<system>_<source table in lower case>`, for example `silver.myproperty_invoice`. Query them as `silver.x` or `bronze_ref.x`.

**Freshness today:** the nightly pipeline has not completed since 2026-10-10, so every answer reflects data up to 2026-10-09 or 2026-10-10. Data after that arrives with the next successful run.

**Not in any table:** insurance, loyalty, groups, OTP counts, AI request logs and costs, server monitoring, API latency, store ratings. KPIs that need these stay unavailable (see KPI definitions).

## Data dictionary

The server now carries a dictionary of 423 tables and 4,935 columns: 421 tables have a description and 1,774 columns a stated meaning. Meanings come only from the schema DDL, the schema-analysis and review files, the filter documents and the KPI code; a column with no documented meaning is listed by name and type only.

| System | What it is | silver | bronze\_ref | Start with |
| --- | --- | --- | --- | --- |
| esukh | iСӨХ, the app for apartment owners' associations (СӨХ) | 138 | 72 | `esukh_balance`, `esukh_monthlypayment`, `esukh_branch`, `esukh_property` |
| myproperty | Property management: buildings, rooms, tenants, owners, invoices | 69 | 33 | `myproperty_room`, `myproperty_invoice`, `myproperty_payment`, `myproperty_tenant` |
| parkly | Parking: parks, gates, access configuration, fees | 24 | 19 | `parkly_park`, `parkly_parkaccessconfig` |
| smartpay | Payments: invoices, transactions, cards, merchants | 30 | 14 | `smartpay_invoice`, `smartpay_transaction`, `smartpay_card` |
| sma | "Смарт Монгол туслах" app: users, activity, errors, cars, listings | 20 | 4 | `sma_users`, `sma_useractionlogs`, `sma_smaerrors`, `sma_usercars` |

**How to look things up**

1. `get_data_dictionary()` — the five systems, table counts and freshness.
2. `get_data_dictionary(system="myproperty")` — every table with what one row is, its key and its date column.
3. `get_data_dictionary(search="invoice")` — tables and columns whose name or meaning contains a word.
4. `describe_table("myproperty_invoice")` — every column with type and meaning, plus joins.

Prefer `silver`: most `bronze_ref` tables are staging copies of a silver table with exact (unbanded) times.

**Joins that look right but return nothing.** Tokenisation broke some joins inside a system: one side is a token, the other a raw id. Known cases: myproperty `room.id` with any `roomId`, and `tenant.id` / `owner.id` with `tenantId` / `ownerId`; esukh `room.id` with `roomorder.roomId`, and `user.id` / `worker.id` with `userId` / `workerId`; smartpay `invoice.merchantId` with `merchant.id`. Each is flagged in the column's meaning. A join that returns zero rows is usually one of these, not missing data.

## KPI definitions

11 of the 58 KPIs are computable as written, 18 as an approximation, and 29 need data no source provides yet. Call `get_kpi_definition(id)` for the full record: Mongolian wording from the KPI PDF, source tables, caveat and what unlocks it.

| # | KPI | Status | How it is computed, or what is missing |
| --- | --- | --- | --- |
| 1 | Total number of registered Smart Mongol app users. | available | COUNT(\*) of sma\_users. Every registered user: sma.Users has no active/status column. |
| 2 | Number and share of active users (users with any app activity in the period ÷ all registered users). | available | Distinct userId in sma\_useractionlogs within the period ÷ COUNT(\*) of sma\_users. |
| 3 | Share of active users who hit no app error in the period. | available | Active users (as KPI 2) minus those with any row in sma\_smaerrors in the period, ÷ active users. |
| 4 | New user registrations, by day / week / month. | available | COUNT(\*) of sma\_users grouped by createdAt truncated to the grain. |
| 5 | Users verified through DAN (the national e-ID), and its growth by day / week / month. | unavailable | Missing: sma.Users (dan verification flag/date). Unlock: Request 1: sma team to name the DAN-verification column in sma.Users. |
| 6 | SMA app users not registered with any apartment-owners association (СӨХ), and its growth. | unavailable | Missing: cross-system link sma.Users <-> myproperty.tenant/owner (open decision: cross-system linking). |
| 7 | Total number of apartments (units), and its growth by day / week / month. | partial | Rooms by type and usageStatus from myproperty\_room. A current total only: no growth until room.createdAt is allowlisted. Unlock: Request 6: myproperty team to add room.createdAt to the masking inventory. |
| 8 | Apartments by complex grade (expensive / average / cheap) and by floor area. | partial | Rooms by building and area band (<40, 40-80, 80-120, >=120 m²). Building construction year shown in place of complex grade. Unlock: Request 8: HTI product to supply a complex\_grade reference list (no source has one). |
| 9 | Total number of garages, and its growth by day / week / month. | partial | Rooms with room.type = PARK (garage, граж; code pending the myproperty team's confirmation). Current total only. Unlock: Request 6 (room.createdAt). |
| 10 | Garages by complex grade (expensive / average / cheap) and by floor area. | partial | PARK rooms (garages) per building with average area. Unlock: Request 8 (complex\_grade). |
| 11 | Total number of storage units (агуулах), and its growth by day / week / month. | partial | Rooms with room.type = STORAGE (warehouse, агуулах; code pending confirmation). Current total only. Unlock: Request 6 (room.createdAt). |
| 12 | Storage units by complex grade (expensive / average / cheap) and by floor area. | partial | STORAGE rooms per building with average area. Unlock: Request 8 (complex\_grade). |
| 13 | Invoices issued: count, total amount and average amount. | available | myproperty\_invoice by issueDate: COUNT, SUM(totalAmount), AVG(totalAmount). |
| 14 | Invoice ageing: share paid within 1, 3 and 6 months of issue. | available | First payment date per invoice (invoicepayment → payment.paymentDate) minus issueDate, bucketed ≤30 / ≤90 / ≤180 days; unpaid counted separately. |
| 15 | Invoices created by SMA users themselves: count, total and average amount. | partial | myproperty\_invoice by type and payerType. Which value means 'created by the SMA user' is not yet confirmed. |
| 16 | Invoices paid through the Smart Mongol app: count, total and average amount. | partial | myproperty\_payment by method. Which method value is the app is not yet confirmed. |
| 17 | Users who set up invoice auto-pay in the Smart Mongol app. | unavailable | Missing: an auto-pay settings table (none in sma/myproperty dumps). |
| 18 | Ageing of invoices paid through the app: paid within 1, 3 and 6 months. | partial | As KPI 14, split by payment method. |
| 19 | Number of tenants, and its growth by day / week / month. | available | New myproperty\_tenant rows by createdAt and grain. |
| 20 | Tenant movement pattern: how long a unit/garage is rented, and whether tenants later become owners or rent elsewhere. | partial | Average rental length from myproperty\_rentalagreement; tenants who also appear as owners (same userId token); rooms per tenant. |
| 21 | Number of ownership changes, by day / week / month. | unavailable | Missing: myproperty.ownerHistory.createdAt (timestamp not allowlisted). |
| 22 | New-owner profile: which complex and how many rooms they lived in before. | unavailable | Missing: ownerHistory timestamps + room link. |
| 23 | Previous-owner profile: which complex they were registered in. | unavailable | Missing: ownerHistory timestamps. |
| 24 | Users granted temporary entry to a complex / users who actually entered temporarily. | unavailable | Missing: parkly guest/visitor access tables (not in the 27 'Normal' tables). Unlock: Request 7: parkly team to classify the access (entry log) table. |
| 25 | Cars granted temporary entry to a complex / cars that actually entered temporarily. | partial | Configured temporary-car counts and limits per park (parkly\_parkaccessconfig). Actual entries need the parkly access log. Unlock: Request 7 (parkly access log). |
| 26 | Total registered cars, by age and by make/model. | available | sma\_usercars joined to sma\_cars: cars, distinct owners, average age from buildYear, distinct makes. |
| 27 | Cars with driver liability insurance, and the premium income. | unavailable | Missing: an insurance table (none in any dump). |
| 28 | Cars with vehicle insurance, and the premium income. | unavailable | Missing: an insurance table. |
| 29 | Cars with permanent entry rights to a complex, as a ratio of the complex's parking capacity. | available | parkly\_parkaccessconfig.permaCar ÷ parkly\_park.parkingSpaces per park. |
| 30 | Cars permanently registered to a garage, as a ratio of the number of garages. | unavailable | Missing: garage<->car registration (not in sma/myproperty allowlists). |
| 31 | Apartments, garages and storage units with property insurance, and the premium income. | unavailable | Missing: an insurance table. |
| 32 | Users who activated the paid AI assistant. | partial | Distinct userId in sma\_aiinfos. Cannot yet tell paid from free. Unlock: Request 3: sma team to provide the priceInfo / product lookup. |
| 33 | Share of AI assistant requests completed successfully. | unavailable | Missing: an AI request log with outcome (not in sma dump). |
| 34 | AI cost to AI revenue ratio. | unavailable | Missing: AI cost data (not in any database). |
| 35 | Online services: users served, fee income and total transaction amount. | partial | Paid smartpay\_invoice rows by productPaymentType: distinct users, count, totalAmount, feeAmount. |
| 36 | Online shop: users served, fee income and total transaction amount. | partial | The KPI 35 query filtered to the online-shop productPaymentType (value not yet confirmed). |
| 37 | Real-estate rental listings, by complex grade. | partial | sma\_propertysalerents by type, propertyType, townId and stage: count and average price. Unlock: Request 8 (complex\_grade). |
| 38 | Rental brokerage fee income. | partial | Paid sma\_directoffers (by paidAt) plus paid sma\_auctionsubscriptionbills (by createdAt): counts and income. |
| 39 | Fee income from activated relays (IoT gate/door relays). | partial | sma\_iotsubscriptions by createdAt: count, distinct users, SUM(price). Payment status is not available. Unlock: Request 4: sma team to confirm how an IoT subscription's payment is recorded. |
| 40 | Fee income from bundled payments. | partial | smartpay\_transaction by type: amount, spayFee, xpayFee. Which type is 'bundled' is not yet confirmed. |
| 41 | OTP SMS messages sent, by day and month. | unavailable | Missing: sma.Otps is a credential-store table (CT019) and is never copied; a count-only extract would need a separate approval. |
| 42 | Users with restricted access, their debt amount and debt ageing. | unavailable | Missing: access-restriction flag (not in allowlists). |
| 43 | Debt paid because access was restricted, as a share of total debt. | unavailable | Missing: as KPI 42. |
| 44 | Users who submitted feedback, by day. | unavailable | Missing: smartpay.ticket (not classified) or an sma feedback table. |
| 45 | Feedback resolution rate, by day. | unavailable | Missing: as KPI 44. |
| 46 | Number of app error reports. | available | sma\_smaerrors by createdAt: errors and distinct users affected. |
| 47 | Server outages and downtime hours. | unavailable | Missing: monitoring system, not a database. |
| 48 | Total groups / groups created by users. | unavailable | Missing: group tables (none in sma dump). |
| 49 | Active groups. | unavailable | Missing: group tables. |
| 50 | Invoices created inside groups: count and amount. | unavailable | Missing: group tables. |
| 51 | Users who linked a payment card. | available | smartpay\_card: distinct userId, cards, approved cards. |
| 52 | Users who paid their parking fee. | unavailable | Missing: parkly payment/transaction tables (not in the 27 'Normal' tables). |
| 53 | Businesses that issued loyalty points. | unavailable | Missing: loyalty tables (none in any dump). |
| 54 | Total loyalty points. | unavailable | Missing: loyalty tables. |
| 55 | Users who generated a loyalty QR code. | unavailable | Missing: loyalty tables. |
| 56 | Building entries via loyalty QR: number of entries / number of users. | unavailable | Missing: loyalty tables. |
| 57 | API latency (response speed). | unavailable | Missing: APM/monitoring, not a database. |
| 58 | User ratings on the App Store and Play Store. | unavailable | Missing: store consoles, not a database. |

## Recipes

Most questions take three calls: find the table, read its columns, run one aggregate query. In Claude you can simply ask in words ("monthly invoice totals for 2026"); these are the calls it makes.

**Find where something lives**

1. `get_data_dictionary()` — the five systems and what each holds.
2. `get_data_dictionary(search="invoice")` — every table or column whose name or meaning mentions invoices.
3. `describe_table("myproperty_invoice", "silver")` — its columns, types, meanings, key, date column and joins.

**Get a KPI**

1. `list_kpis(status="available")` — the 11 that work as written.
2. `get_kpi_definition(13)` — what KPI 13 means and how it is computed.
3. `get_kpi(13, date_from="2026-01-01", date_to="2026-10-01", grain="month")` — the numbers, with the SQL used.

**Write your own query** (one SELECT, tables qualified, aggregate)

| Question | SQL |
| --- | --- |
| Monthly myproperty invoice total and amount still unpaid | `SELECT date_trunc('month', issueDate) AS m, COUNT(*) AS invoices, SUM(totalAmount) AS billed, SUM(balance) AS unpaid FROM silver.myproperty_invoice WHERE issueDate >= '2026-01-01' GROUP BY 1 ORDER BY 1` |
| myproperty payments by method | `SELECT method, COUNT(*) AS payments, SUM(paidAmount) AS paid FROM silver.myproperty_payment GROUP BY 1 ORDER BY 3 DESC` |
| Daily active app users | `SELECT date_trunc('day', createdAt) AS d, COUNT(DISTINCT userId) AS users FROM silver.sma_useractionlogs WHERE createdAt >= '2026-09-01' GROUP BY 1 ORDER BY 1` |
| Most-used app screens | `SELECT screen, COUNT(*) AS views FROM silver.sma_useractionlogs GROUP BY 1 ORDER BY 2 DESC LIMIT 20` |
| Parking capacity by park type | `SELECT parkType, COUNT(*) AS parks, SUM(parkingSpaces) AS spaces FROM silver.parkly_park WHERE isDeleted = 0 GROUP BY 1` |
| SmartPay fees by transaction type | `SELECT type, COUNT(*) AS tx, SUM(amount) AS amount, SUM(spayFee) AS spay_fee FROM silver.smartpay_transaction GROUP BY 1` |

**Good habits:** filter by a date column first, then aggregate. Prefer `silver` tables: several esukh tables appear in both layers, and silver is the governed copy. Ignore the `_ingested_at`, `_load_date`, `_source` and `_tokenised_at` columns unless you need load metadata.

## Rules and limits

The server enforces these rules itself; a query that breaks one is refused with the reason.

| Rule | What it means for you |
| --- | --- |
| People are tokens | `userId`, `tenantId`, car IDs and similar are per-system UUIDs. Count them; you cannot identify anyone. |
| No cross-system person link | The same person has different tokens in esukh, myproperty, parkly, smartpay and sma. Join people only inside one system. |
| One SELECT or WITH | No DDL or DML, no `SET`, no `USE`, one statement per call. |
| Qualify every table | Write `silver.myproperty_invoice`, never `myproperty_invoice`. Only `silver` and `bronze_ref` are allowed; bronze, gold, default and file paths are refused anywhere in the query, including subqueries and comma joins. |
| 200 rows max | Larger results are cut at 200. Aggregate (GROUP BY) instead of listing rows. |
| Dates | Spark SQL. Use ISO strings: `createdAt >= '2026-09-01' AND createdAt < '2026-10-01'`. `get_kpi` treats `date_to` as exclusive and defaults to the last 12 months. |
| Heavy queries | The Spark server shares a 7.8 GiB host. A full scan of a large esukh table can stall it for everyone, so filter by date first. |
| Maintenance windows | During nightly loads the Spark server may be stopped; the tools then answer "not reachable, retry in a few minutes". |

**Withheld tables.** Refused and hidden from `list_tables` since 2026-10-14:

- `esukh_camera`, `parkly_camera`, `parkly_routerconfig` held plaintext device passwords and API signatures. They return once those columns are purged from the lake.
- `bronze_ref.sma_iotsubscriptions`, `bronze_ref.sma_notifyons`, `bronze_ref.sma_subscriptionbills` are stale copies with raw user IDs. Use the `silver` tables of the same name, where `userId` is a token.

Statuses marked `PENDING-REVIEW` in the control tables are provisional phase-1 allowlists: columns can be added or removed after the data officer's review.
