# sma schema analysis — domains and privacy classification

Generated 2026-09-30 10:09 UTC from `sma_schema.sql`
(structure only, no rows). **A proposal for the data officer, not a finding** — everything is
inferred from column names, and names lie. Nothing loads until it is in a signed control table.

## 1. Inventory

- Tables: **34**
- Columns: **326**

## 2. Proposed domains

**D1 Users & identity** — 9 tables

```
ActiveUsers, AdminLogins, NotifyOns, Otps, UserActionLogs, UserAppLogs, UserCars, UserLogs, 
Users
```

**D2 Agents & commissions** — 2 tables

```
AgentCommissions, Agents
```

**D3 Listings, offers & deals** — 9 tables

```
Contracts, DealActions, Deals, DirectOfferApproves, DirectOffers, PropertySaleRentImages, 
PropertySaleRentOfferHistories, PropertySaleRentOffers, PropertySaleRents
```

**D4 Vehicles & parking** — 4 tables

```
Cars, Parks, userCarPostgre, userCarPostgres
```

**D5 Subscriptions & billing** — 4 tables

```
AuctionSubscriptionBills, IotSubscriptions, SubscriptionBills, auctionOfferSubscriptionBills
```

**D6 Notifications** — 2 tables

```
NotificationAds, Notifications
```

**D7 Analytics** — 3 tables

```
AiInfos, StatisticResults, Statistics
```

**D8 Logs & errors** — 1 tables

```
SmaErrors
```

## 3. CREDENTIALS IN THE DATABASE — highest priority

Columns whose names indicate a secret. These must **never** be copied to any layer, and
their presence is a source-system security question independent of this platform: if any
holds a plaintext or reversible value, that is a live issue for the owning team.

- `Users`: `expoToken`, `pin`

## 4. Never copied (policy section 4)

### 4.1 Correspondence tables — 4

Content is sensitive under policy 4.1.4; excluded whole, not column-filtered.

```
NotificationAds, Notifications, userCarPostgre, userCarPostgres
```

### 4.2 Identity columns — 30 in 14 tables

Names, phones, emails. Dropped, never tokenised. **Over-detected on purpose** — triage is a
data-officer task, because a false positive costs a review and a false negative copies
personal data.

- `AdminLogins`: `adminName`, `phone`
- `Agents`: `firstName`, `lastName`, `phone`, `email`
- `AiInfos`: `robotName`
- `AuctionSubscriptionBills`: `companyRegister`, `easyRegister`
- `Cars`: `markName`, `modelName`, `colorName`
- `DirectOfferApproves`: `townName`
- `Otps`: `phone`
- `PropertySaleRentImages`: `name`
- `PropertySaleRents`: `townName`, `branchName`
- `Statistics`: `name`
- `SubscriptionBills`: `companyRegister`, `easyRegister`
- `UserAppLogs`: `appName`
- `Users`: `lastName`, `registerNo`, `name`, `phone`, `phone2`, `email`, `userName`
- `auctionOfferSubscriptionBills`: `companyRegister`, `easyRegister`

### 4.3 Registration / passport numbers — 7 in 4 tables

- `AuctionSubscriptionBills`: `companyRegister`, `easyRegister`
- `SubscriptionBills`: `companyRegister`, `easyRegister`
- `Users`: `registerNo`
- `auctionOfferSubscriptionBills`: `companyRegister`, `easyRegister`

### 4.4 Free-text columns — 13 in 12 tables

- `Agents`: `notes`
- `AuctionSubscriptionBills`: `description`
- `DealActions`: `note`
- `Deals`: `failureReason`
- `IotSubscriptions`: `description`
- `NotificationAds`: `title`
- `Notifications`: `title`, `body`
- `Parks`: `description`
- `PropertySaleRentOffers`: `rejectionReason`
- `Statistics`: `description`
- `SubscriptionBills`: `description`
- `auctionOfferSubscriptionBills`: `description`

## 5. Copy to bronze, tokenise into silver — 39 columns in 27 tables

- `ActiveUsers`: `userId`
- `AgentCommissions`: `agentId`
- `AiInfos`: `userId`, `device`
- `AuctionSubscriptionBills`: `userId`
- `Cars`: `plateNumber`
- `DealActions`: `agentId`, `actorUserId`
- `Deals`: `agentId`
- `DirectOfferApproves`: `userId`, `roomCount`
- `DirectOffers`: `userId`
- `IotSubscriptions`: `userId`
- `NotificationAds`: `workerId`
- `Notifications`: `userId`
- `NotifyOns`: `userId`
- `Parks`: `userId`, `latitude`, `longitude`, `address`
- `PropertySaleRentOffers`: `userId`
- `PropertySaleRents`: `userId`, `roomCount`, `fullAddress`, `townAddress`
- `SmaErrors`: `userId`
- `StatisticResults`: `calculationTime`
- `SubscriptionBills`: `userId`
- `UserActionLogs`: `userId`
- `UserAppLogs`: `userId`
- `UserCars`: `userId`, `carId`
- `UserLogs`: `userId`
- `Users`: `deviceId`
- `auctionOfferSubscriptionBills`: `userId`
- `userCarPostgre`: `userId`, `plateNumber`
- `userCarPostgres`: `plateNumber`, `userId`

## 6. Next steps

1. Owning team confirms whether the section 3 credential columns are hashed or plaintext.
2. Data officer triages section 4.2 — separate person names from object names.
3. Confirm or replace the domains above.
4. Purpose register entry per domain, then build the control table and gate it with
   `jobs/validate_control_table.py`.