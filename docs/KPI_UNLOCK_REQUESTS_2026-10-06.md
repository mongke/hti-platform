# KPI unlock requests — what each source team must approve (2026-10-06)

Generated from the KPI gap list produced through the HTI KPI MCP server, checked against the
actual dumps (`*_schema.sql`) and the control tables. Nothing below is loaded until the owning
team confirms the table/columns and the data officer assigns a purpose reference. People stay
UUID tokens; no names, phones, plates or register numbers are requested anywhere.

| # | System | Table | Columns needed | Unlocks KPI | Status in the platform today | Ask |
|---|---|---|---|---|---|---|
| 1 | sma | `Users` | `id`, `createdAt`, `status`/active flag, DAN-verified flag or date | 1, 2, 4, 5 | In the dump. Our filter already proposes `id, lastLogged, gender, birthDate, createdAt, updatedAt, menuOrder, deviceId` (`control_table_sma.csv`), but the sma team did not name `Users` in their revised list, so it was **held back** from phase 1. No DAN column is visible in the dump — confirm where verification is stored. | sma team: approve `Users` with those columns; name the DAN-verification column. |
| 2 | sma | `Cars` | `id`, `userId` link (via `UserCars`), `buildYear`, make/model | 26 | In the dump. Our filter proposes `id, plateNumber(token), buildYear, importDate, fuelType, wheelPosition, createdAt, updatedAt`; `modelName` exists and is a reference label, not personal. Held back for the same reason as `Users`. | sma team: approve `Cars` without `plateNumber`, with `modelName`, `buildYear`, `fuelType`. |
| 3 | sma | subscription product reference (priceInfo / product) | `id`, product name/code | 32 | **No such table in the sma dump** — `priceInfoId` in `SubscriptionBills` / `IotSubscriptions` points to something outside this database (config or another service). | sma team: provide the priceInfo lookup (a static CSV is enough; it goes to `bronze_ref`). |
| 4 | sma | `IotSubscriptions` payment status | status column | 39 | Table is loaded; the dump has no status column on `IotSubscriptions`. Payment status may live in `SubscriptionBills.status` joined on `priceInfoId`/`userId`. | sma team: confirm how an IoT subscription's payment is recorded. |
| 5 | sma | `AuctionSubscriptionBills` | `price`, `status`, `createdAt`, `methodType` | 38 | **Already loaded** in silver (`sma_auctionsubscriptionbills`). KPI 38 now includes it. | none |
| 6 | myproperty | `room` | `createdAt` | 7, 9, 11 | In the dump, but **absent from the owner's masking inventory** (`MyProperty_Data_Masking_Inventory_2026-10-02.xlsx`), so it is not in the control table. A timestamp on a room is not personal data. | myproperty team: add `room.createdAt` to the inventory. |
| 7 | parkly | `access` (entry log) | `parkId`, car token, entry time, access type | 24, 25 | In the dump (`access`), **not among the 27 tables the parkly team classified Normal**. It contains a car/plate reference, which we tokenise. | parkly team: classify `access` and say which columns may be copied. |
| 8 | HTI | `complex_grade` (new reference) | `buildingId` or `townId`, `grade` (үнэтэй / дундаж / хямд) | 8, 10, 12, 37 | **Does not exist in any source system.** It is a business classification HTI must define. | HTI product: supply the list; we load it into `bronze_ref` as a reference table. |

Still impossible from databases (monitoring, store consoles, insurance, loyalty, groups, OTP
counts): KPIs 27, 28, 31, 33, 34, 41, 47–50, 53–58 — see `list_kpis(status="unavailable")`.
