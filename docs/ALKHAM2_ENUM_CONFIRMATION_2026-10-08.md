# Алхам 2 — enum values to confirm, with the actual data

Produced 2026-10-08 by querying `silver` directly, so these are the values that really exist and
how often, not a guess. Confirm the right-hand column and we load it into
`bronze_ref.kpi_value_map` (`jobs/load_reference_csv.py --reference kpi_value_map`). The plan is
explicit that meanings live in that table, never hardcoded in KPI SQL. `confirmed_by` must be
filled in — the loader refuses a row without it, so an unconfirmed guess cannot drive a KPI.

Prefilled template: `jobs/reference/kpi_value_map_TEMPLATE.csv`.

## Answered by the data — myproperty `room.type` (KPI 9, 10, 11, 12)

| value | rows | proposed meaning |
|---|---|---|
| OFFICE | 1,753 | commercial_office |
| SHOP | 119 | commercial_shop |
| **PARK** | **90** | **garage (граж)** |
| APARTMENT | 50 | dwelling (сууц) |
| MARKET | 35 | commercial_market |
| **STORAGE** | **19** | **warehouse (агуулах)** |
| CLINIC / RESTAURANT / HOTEL / BANK / DRUGSTORE | 11 / 10 / 6 / 3 / 2 | commercial_other |
| OTHER | 2 | unknown |

The values are self-describing, so `PARK` = garage and `STORAGE` = warehouse need only a yes.

**But myproperty is the wrong source for KPI 7, 9 and 11.** It holds 2,100 rooms and only **50**
are `APARTMENT` — it is commercial property management. The residential estate is in esukh:
`esukh.property` has **202,335** rows across `propertyType` 1 (152,344), 2 (44,873) and 3 (5,118).
KPI 7/9/11 ("total dwellings / garages / warehouses, and growth") should almost certainly be
counted from esukh and only supplemented from myproperty. **Decision needed before we build them.**

## Blocked by a missing label, not by permission — `esukh.property.propertyType`

`propertyType` is stored as `1`, `2`, `3` with no labels. The labels live in `esukh.reference`,
and **`silver.esukh_reference` currently has no `name` or `shortname` column** — those columns
were outside the old allowlist. The esukh team's 2026-10-08 document now permits them, and they
are waived and in the control table as of today.

They are not personal data: `reference` is a lookup table and its `name` is a label.

**Update 2026-10-09 — loaded, and the result corrects this section.** The labels are in. They
resolve `branch.serviceType` properly (124 = СӨХ, 501 = Хөрөнгийн менежмент, 98 = lift
maintenance, 125 = security, 567 = cleaning), which is a real KPI dimension we did not have.

But **`propertyType` does not resolve this way.** It is not a foreign key into `reference`: its
values 1/2/3 happen to collide with `reference`'s top-level category ids, so a naive join labels
152,344 dwellings "Санал, гомдол, дуудлагын төрөл" (complaint/call type) — confident and wrong.
`barrier.subType` is mixed: 574 correctly resolves to `ZLAN`, while 1 and 2 collide.

**Question for esukh:** which columns are genuine foreign keys into `reference`, and what do
`property.propertyType` 1, 2 and 3 mean? The second one is a `kpi_value_map` row, not a join.

## Not answerable from the current columns — needs a source change

### KPI 16, 18 — "invoices paid through the Smart Mongol app"

`myproperty.payment.method` holds: `BANK_TRANSFER` 6,844 · `QPAY` 3,784 · `CREDIT` 2,204 ·
`ADJUSTMENT` 345 · `DEPOSIT` 119 · `DISCOUNT` 59 · `CASH` 1.

**There is no app value.** `QPAY` is a payment gateway — a QPay QR can be paid from the Smart
Mongol app or from any bank app, so it cannot stand in for "paid in our app". This column records
the *instrument*, not the *channel*.

**Question for myproperty:** where is the originating channel recorded? If nowhere, KPI 16 and 18
need a new field (e.g. `payment.sourceApp`) — a platform change, not a filter change.

### KPI 15 — "invoices the SMA user created themselves"

`invoice.payerType` = `TENANT` 13,557 · `OWNER` 16. `invoice.type` = `MONTHLY` 12,697 · `REMAIN`
773 · `OTHER` 60 · `ADJUST` 41 · `INSURANCE` 2.

`payerType` is **who pays**, not **who created**. Neither column answers the KPI.

**Question for myproperty:** is the creator recorded (a `createdBy`, or a self-service flag)? We
can tokenise a creator id, so a person reference is not the obstacle — the field has to exist.

### KPI 40 — "bundled payment fee"

- `smartpay.transaction.type` is **NULL on 87,466 of 87,600 rows**; only 134 say `POS`. Unusable.
- `smartpay.merchant.userFeeType` holds `PERCENT` / `FIXED` / `0` — *how* a fee is calculated,
  not whether a payment was bundled.
- `smartpay.merchantBillings.billFeeType` = `PER` (3 rows).

**Question for smartpay:** which column marks a bundled ("багцалсан") payment? Nothing we hold
distinguishes it.

### KPI 35, 36 — online service vs online store

`smartpay.invoice.productPaymentType` = `PURCHASE` 197 · `PAYMENT` 93. Only two values and 290
rows in total.

**Question for smartpay:** is `PURCHASE` the online store and `PAYMENT` the online service, or
does the split live in `productType` / `paymentMethodId`? And is 290 invoices really the whole
history, or is our dump partial?

## One thing we fixed on our side

Eight columns were being tokenised into UUIDs although they hold a business category, a config
value or a counter — the person-word in the name was incidental. `smartpay.merchant.userFeeType`
is the clearest: the token map shows its natural values were literally `FIXED` and `0`, so a fee
type had become two UUIDs. Also `myproperty.owner.ownershipType`, `esukh.propertyjoinrequest.
ownerType`, `esukh.branch.appCarTypes`, `parkly.compare.device`, `parkly.camera.templateId`,
`myproperty.meter.contractRoomServiceId`, and `parkly.camera_health_log.processedPlates` — an
`integer DEFAULT 0` counter.

They are `passthrough` from now on (`NOT_A_PERSON` in `jobs/make_phase1.py`). The UUIDs already
written to silver are only recovered by a reload.
