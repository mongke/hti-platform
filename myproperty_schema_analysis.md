# myproperty schema analysis — domains and privacy classification

Generated 2026-09-30 12:03 UTC from `myproperty_schema.sql`
(structure only, no rows). **A proposal for the data officer, not a finding** — everything is
inferred from column names, and names lie. Nothing loads until it is in a signed control table.

## 1. Inventory

- Tables: **96**
- Columns: **1146**

## 2. Proposed domains

**D1 Buildings, blocks & rooms** — 9 tables

```
block, building, capitalLocation, floor, room, roomBooking, roomBookingSetting, roomHistory, 
roomType
```

**D2 Contracts & tenancy** — 18 tables

```
contract, contractBalance, contractBalanceHistory, contractDepositHistory, 
contractDepositInvoice, contractHistory, contractRemainReason, contractRoom, contractRoomService, 
contractTemplate, owner, ownerHistory, rentalAgreement, tenant, tenantBalance, 
tenantBalanceHistory, tenantHistory, tenantMember
```

**D3 Invoicing & payments** — 15 tables

```
bankStatement, bankStatementPayment, branchWallet, branchWalletTransaction, invoice, 
invoiceBucket, invoiceItem, invoiceItemService, invoiceLateFee, invoicePayment, payment, 
paymentReverseHistory, qpayHistory, recurringInvoice, vat
```

**D4 Services & meters** — 6 tables

```
meter, meterReading, service, servicePack, servicePackItem, servicePackSyncTask
```

**D5 Capital assets** — 4 tables

```
capitalCategory, capitalDisposal, capitalItem, capitalMaintenance
```

**D6 Workers, tasks & planning** — 15 tables

```
action, branchWorkReport, helpRequest, internalMilestone, internalPlan, internalWorkTask, plan, 
planGoal, task, taskActivity, worker, workerAction, workerBuilding, workerDeviceToken, workerLog
```

**D7 Communications** — 10 tables

```
email, message, news, newsRead, notification, poll, pollAnswer, pollOption, pollQuestion, 
pollResponse
```

**D8 Branch & onboarding** — 16 tables

```
branch, branchBuilding, branchBuildingCorporate, branchBuildingMessageFormat, 
branchBuildingPaymentInfo, branchBuildingVatInfo, branchCorporate, branchInvoice, 
branchInvoiceHistory, branchMessageFormat, branchPaymentInfo, branchRegistration, 
branchRegistrationStep, branchSupportVar, branchVatInfo, onboardingRequest
```

**D9 Integration & misc** — 2 tables

```
archiveFile, ekontorCredential
```

**UNASSIGNED** — 1

```
userNotification
```

## 3. CREDENTIALS IN THE DATABASE — highest priority

Columns whose names indicate a secret. These must **never** be copied to any layer, and
their presence is a source-system security question independent of this platform: if any
holds a plaintext or reversible value, that is a live issue for the owning team.

- `branchBuildingCorporate`: `credential`
- `branchCorporate`: `credential`
- `ekontorCredential`: `passwordEncrypted`
- `onboardingRequest`: `codeHash`, `stateToken`
- `worker`: `passwordHash`
- `workerDeviceToken`: `token`

## 4. Never copied (policy section 4)

### 4.1 Correspondence tables — 14

Content is sensitive under policy 4.1.4; excluded whole, not column-filtered.

```
branchBuildingMessageFormat, branchMessageFormat, branchSupportVar, helpRequest, message, news, 
newsRead, notification, poll, pollAnswer, pollOption, pollQuestion, pollResponse, 
userNotification
```

### 4.2 Identity columns — 69 in 36 tables

Names, phones, emails. Dropped, never tokenised. **Over-detected on purpose** — triage is a
data-officer task, because a false positive costs a review and a false negative copies
personal data.

- `action`: `name`
- `archiveFile`: `fileName`
- `bankStatement`: `bankName`
- `block`: `name`, `contactPhone`, `contactEmail`
- `branch`: `name`, `companyName`, `phone`, `email`, `mainBuildingImageUrl`, `registerNo`
- `branchBuildingVatInfo`: `register`, `serviceName`
- `branchSupportVar`: `variableName`
- `branchVatInfo`: `register`, `serviceName`
- `branchWorkReport`: `imageUrls`
- `building`: `name`, `contactPhone`, `contactEmail`, `mainBuildingImageUrl`
- `capitalCategory`: `name`
- `capitalItem`: `name`, `imageUrls`
- `capitalMaintenance`: `imageUrls`
- `contractTemplate`: `name`
- `ekontorCredential`: `username`
- `email`: `recipientName`, `recipientEmail`
- `floor`: `name`, `floorImageUrl`
- `helpRequest`: `attachmentName`
- `invoiceItemService`: `serviceName`
- `message`: `phone`
- `news`: `imageUrl`, `imageUrls`
- `onboardingRequest`: `email`
- `owner`: `name`, `registerNo`, `phone`, `email`
- `paymentReverseHistory`: `tenantName`
- `planGoal`: `responsibleName`
- `poll`: `imageUrls`
- `pollOption`: `imageUrl`
- `pollQuestion`: `imageUrls`
- `room`: `name`
- `roomBooking`: `bookerName`, `bookerPhone`, `bookerEmail`
- `roomType`: `name`
- `service`: `name`
- `servicePack`: `name`
- `servicePackSyncTask`: `packName`
- `tenant`: `organizationName`, `registerNo`, `contactPhone`, `contactEmail`, `easyRegisterNo`, `contactPersonLastName`
- `worker`: `userName`, `fullName`, `phone`, `email`, `avatarUrl`, `firstName`, `lastName`, `registerNo`

### 4.3 Registration / passport numbers — 7 in 6 tables

- `branch`: `registerNo`
- `branchBuildingVatInfo`: `register`
- `branchVatInfo`: `register`
- `owner`: `registerNo`
- `tenant`: `registerNo`, `easyRegisterNo`
- `worker`: `registerNo`

### 4.4 Free-text columns — 77 in 56 tables

- `bankStatement`: `description`
- `block`: `description`
- `branch`: `description`
- `branchInvoice`: `notes`
- `branchInvoiceHistory`: `note`
- `branchRegistrationStep`: `notes`
- `branchWalletTransaction`: `description`
- `branchWorkReport`: `title`, `description`
- `building`: `description`
- `capitalCategory`: `description`
- `capitalDisposal`: `reason`
- `capitalItem`: `description`
- `capitalMaintenance`: `notes`
- `contract`: `description`
- `contractBalanceHistory`: `reason`
- `contractDepositHistory`: `description`
- `contractDepositInvoice`: `description`
- `contractRemainReason`: `note`
- `contractRoom`: `note`
- `contractRoomService`: `note`
- `contractTemplate`: `description`
- `email`: `subject`, `body`, `responseMessage`
- `floor`: `description`
- `helpRequest`: `description`, `resolutionNote`
- `internalMilestone`: `title`, `description`
- `internalPlan`: `title`, `description`
- `invoice`: `remarks`
- `invoiceItem`: `description`
- `invoiceItemService`: `description`
- `message`: `message`, `externalMessageId`, `responseMessage`
- `meter`: `locationNote`
- `news`: `title`, `description`, `content`
- `notification`: `title`, `body`
- `owner`: `note`
- `ownerHistory`: `note`
- `payment`: `description`
- `paymentReverseHistory`: `description`, `reverseReason`
- `plan`: `title`, `description`, `notes`
- `planGoal`: `title`, `notes`
- `poll`: `title`, `description`
- `pollAnswer`: `questionId`
- `pollOption`: `questionId`
- `pollQuestion`: `question`, `description`
- `recurringInvoice`: `description`
- `rentalAgreement`: `note`
- `room`: `remark`
- `roomBooking`: `notes`, `bookerSubjectId`, `cancelReason`
- `roomHistory`: `description`
- `servicePack`: `description`
- `task`: `title`, `description`
- `taskActivity`: `note`
- `tenant`: `note`
- `tenantBalanceHistory`: `reason`
- `tenantHistory`: `note`
- `tenantMember`: `remark`
- `userNotification`: `body`, `responseMessage`

## 5. Copy to bronze, tokenise into silver — 87 columns in 54 tables

- `bankStatement`: `accountNumber`, `relatedAccount`
- `branch`: `address`
- `branchBuildingCorporate`: `bankAccountNumber`
- `branchBuildingPaymentInfo`: `bankAccountNumber`, `depositBankAccountNumber`
- `branchCorporate`: `bankAccountNumber`
- `branchInvoiceHistory`: `workerId`
- `branchPaymentInfo`: `bankAccountNumber`
- `building`: `address`, `latitude`, `longitude`
- `capitalLocation`: `roomId`
- `contract`: `lateFeeRate`, `workerId`, `ownerId`, `invoiceRecipientOwnerId`
- `contractDepositHistory`: `workerId`
- `contractHistory`: `workerId`
- `contractRemainReason`: `worker_id`
- `contractRoom`: `roomId`, `calculatedArea`
- `contractRoomService`: `contractRoomId`
- `contractTemplate`: `lateFeeRate`
- `email`: `ownerId`, `workerId`
- `floor`: `totalRooms`
- `helpRequest`: `workerId`, `assignedWorkerId`
- `internalMilestone`: `assignedWorkerIds`
- `internalWorkTask`: `workerId`
- `invoice`: `ownerId`
- `invoiceItem`: `roomId`, `contractRoomId`, `calculatedArea`
- `invoiceLateFee`: `lateFeeRate`, `calculatedAt`, `daysLate`
- `invoicePayment`: `lateFeeId`, `lateFeeAmount`
- `message`: `ownerId`, `workerId`
- `meter`: `roomId`, `serialNo`, `contractRoomServiceId`
- `meterReading`: `gatewayId`
- `news`: `createdByWorkerId`
- `newsRead`: `workerId`
- `notification`: `workerId`
- `onboardingRequest`: `workerId`
- `owner`: `userId`, `address`, `ownershipType`
- `ownerHistory`: `ownerId`, `workerId`
- `payment`: `ownerId`, `lateFeeAmount`, `workerId`
- `plan`: `ownerId`
- `planGoal`: `responsibleWorkerId`
- `pollResponse`: `workerId`
- `rentalAgreement`: `roomId`, `ownerId`
- `room`: `ownerId`
- `roomBooking`: `roomId`, `createdByWorkerId`, `cancelledByWorkerId`, `confirmedByWorkerId`
- `roomBookingSetting`: `roomId`
- `roomHistory`: `roomId`, `relatedRoomIds`
- `servicePackSyncTask`: `workerId`
- `task`: `createdByWorkerId`, `assignedWorkerId`
- `taskActivity`: `workerId`
- `tenant`: `userId`, `address`
- `tenantHistory`: `workerId`
- `tenantMember`: `userId`
- `userNotification`: `ownerId`, `workerId`
- `workerAction`: `workerId`
- `workerBuilding`: `workerId`
- `workerDeviceToken`: `workerId`, `platform`, `deviceId`
- `workerLog`: `workerId`

## 6. Next steps

1. Owning team confirms whether the section 3 credential columns are hashed or plaintext.
2. Data officer triages section 4.2 — separate person names from object names.
3. Confirm or replace the domains above.
4. Purpose register entry per domain, then build the control table and gate it with
   `jobs/validate_control_table.py`.