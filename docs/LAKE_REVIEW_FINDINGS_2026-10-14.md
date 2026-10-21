# Lake review findings — 2026-10-14

Found while building the MCP data dictionary (one reviewer per system, schema files and
markdown only — no data dumps opened, no values copied). Nothing below has been changed
unless marked **done**. Credentials are covered separately in
`docs/CREDENTIALS_IN_SILVER_2026-10-14.md`.

## Personal data in exposed layers (silver / bronze_ref)

| # | System | Finding | Status |
| --- | --- | --- | --- |
| P1 | sma | `bronze_ref.sma_iotsubscriptions`, `sma_notifyons`, `sma_subscriptionbills`: stale copies with the raw integer `userId` (silver twins are tokenised). | **done**: withheld by the MCP server; lake copies remain |
| P2 | myproperty | `tenant.id`, `owner.id` are raw integers in silver; transform rules say token (G18 migration not run). | open |
| P3 | esukh | `user.id`, `worker.id` raw in silver (G18); `task.assignedTo`, `taskassignment.assignedBy`, `taskhistory.changedBy` are people passed through as integers. | open |
| P4 | esukh | Old columns still in silver: `statebankstatement.acntNo` (bank account), `barrier.ip/sn/code`, `log.ip`, `billinglog.ip`, free text `taskhistory.oldValue/newValue`, `property.doorNo/floor/familyCount/propertyNo`, `room.roomNo`, `nearbyservice.lat/lng`; `plateNumber` in `car`, `inouthistory` (token or raw not recorded). | open |
| P5 | esukh | 46 tables have no rows in `transform_rules.csv` (treatment unknown), incl. `car.userId`, `chip.userId`, `aiinfo.userId/device`, `monthremain.userId`, `propertydept.userId`. | open |
| P6 | esukh | `counter` and `town` are in the lake although refused / "never copy" (town's credential columns are not). | open |
| P7 | parkly | `delivery_*.approved_by/created_by/updated_by` are raw worker ids (worker is Red); `park.workerId` is tokenised. | open |
| P8 | parkly | `spayCheckLog` is Red in the parkly team's PDF but loaded to silver and bronze_ref. | open |
| P9 | myproperty | bronze_ref copies keep exact dates (e.g. `branchInvoice.issueDate`); hour-banding only applies in silver. | open |
| P10 | sma | `Users.lastLogged` passes through un-banded (CT106). | open |
| W1 | parkly | `branchExternalSystem.config` is pass-through JSON; DDL says it holds "apiUrl, apiKey etc.". Checked 2026-10-14: 3 non-null rows, no credential key names. | watch |

## Joins broken by tokenisation (results silently empty)

myproperty `room.id` ↔ every `roomId`; `tenant.id`/`owner.id` ↔ `tenantId`/`ownerId`;
`createdBy`/`updatedBy`/`workerId`/`worker_id` are separate token namespaces for one person;
`tenant_id` ↔ `tenantId`. esukh `room.id` ↔ `roomorder.roomId`, `roomimage.roomId`;
`workerratingdetail.rateWorkerId` (a rating id tokenised as a person). smartpay
`invoice.merchantId` ↔ `merchant.id`, `transaction.merchantSettleId` ↔ `merchantSettle.id`,
merchant-invoice items. sma `DealActions.actorUserId` ↔ `Users.id`. KPI 20 is affected.

## KPI correctness

| KPI | Finding | Status |
| --- | --- | --- |
| 9–12 | Filtered `room.type LIKE '%garage%'/'%warehouse%'`; real codes are `PARK` / `STORAGE` → returned 0. | **done**: now 90 garages, 19 storage; codes await the myproperty team's yes |
| 7 | Note says `room.createdAt` not allowlisted; it was loaded 2026-10-09. | open |
| 8 | Casts `building.id` to string to compare with integer `room.buildingId`. | open |
| 35, 38 | Paid-status values are guesses (`paid`, `success`, `төлсөн` ...). | open |
| 40 | `transaction.type` is NULL on almost all rows. | open |

## Stale or inconsistent copies

- Values written before rule fixes are still UUIDs until an in-place migration: esukh
  `branch.appCarTypes`, `propertyjoinrequest.ownerType`; myproperty `owner.ownershipType`,
  `meter.contractRoomServiceId`; parkly `compare.device`, `camera_health_log.processedPlates`.
- Layer orphans: bronze_ref copies of esukh `branch`, `reference`, `propertycaraccess`;
  smartpay `pos`, `merchantPermission`.
- In control tables but not in the lake: sma `AgentCommissions`, `DirectOfferApproves`;
  parkly `groupDiscount` (empty); smartpay `settle` (0 rows).
- sma `UserAppLogs` uses `updatedAt` as watermark but it can be NULL → rows may never load.
