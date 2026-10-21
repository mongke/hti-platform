# SmartPay — хүснэгт ба баганын жагсаалт (нууц багана хассан)

Нууцлах ёстой, гадагш задруулж болохгүй багануудыг хассан жагсаалт. Эх сурвалж: `API/models` (Sequelize model).

- Нийт хүснэгт: **39**, бүлэг: **8**
- `createdAt`, `updatedAt` — Sequelize автоматаар нэмдэг (`timestamps`).
- `id` — model дээр бичээгүй ч Sequelize автоматаар нэмдэг хүснэгтэд мөн оруулсан.
- Хассан баганын ангилал — Хавсралтад.

---

## 1. Нэхэмжлэл ба төлбөр

### tableName: invoice

- id
- userId
- merchantId
- amount
- status
- productPaymentType
- paymentMethodId
- feeAmount
- totalAmount
- invoiceItemCount
- createdAt
- updatedAt

### tableName: invoiceItem

- id
- amount
- status
- bankCode
- invoiceId
- productTypeId
- vatInfoId
- transactionId
- createdAt
- updatedAt

### tableName: invoiceItemVatInfo

- id
- type
- status
- time
- createdAt
- updatedAt

### tableName: paymentMethod

- id
- name
- createdAt
- updatedAt

### tableName: productType

- id
- name
- paymentType
- settleType
- createdAt
- updatedAt

### tableName: qpayHistory

- id
- invoiceId
- status
- checked
- qpayType
- createdAt
- updatedAt

### tableName: negdiHistory

- id
- invoiceId
- status
- settleId
- paymentType
- createdAt
- updatedAt

### tableName: negdiJoinCardHistory

- id
- userId
- status
- cancelStatus
- amount
- createdAt
- updatedAt

### tableName: card

- id
- userId
- brand
- bankname
- status
- color
- approved
- createdAt
- updatedAt

---

## 2. Гүйлгээ ба өндөрлөгөө

### tableName: transaction

- id
- invoiceItemId
- bankCode
- status
- settledAt
- journalNo
- settleType
- amount
- merchantFee
- merchantFeePercent
- xpayFee
- xpayFeePercent
- spayFee
- processingFee
- processingFeePercent
- afterFeeAmount
- merchantSettleId
- type
- createdAt
- updatedAt

### tableName: transactionBucket

- id
- transactionIds
- totalCount
- totalAmount
- totalFee
- status
- merchantId
- bankCode
- createdAt
- updatedAt

### tableName: merchantSettle

- id
- merchantId
- amount
- count
- spayFeePercent
- subMerchantAmount
- merchantAmount
- xpayAmount
- processingAmount
- status
- settledAt
- settledType
- createdAt
- updatedAt

### tableName: settle

- id
- type
- recordId
- amount
- extracted
- status
- createdAt
- updatedAt

### tableName: bankTransactionLog

- id
- bankName
- trnDate
- journalNo
- amount
- recordId
- invoiceId
- transactionBucketId
- linkSource
- linkConfidence
- linkedAt
- createdAt
- updatedAt

### tableName: incomeTransaction

- id
- merchantId
- bankCode
- merchantSettleId
- status
- settledAt
- journalNo
- amount
- fee
- feeShareRuleId
- createdAt
- updatedAt

---

## 3. Шимтгэлийн хуваарилалт ба орлого

### tableName: feeShareRule

- id
- merchantId
- bankCode
- percent
- active
- description
- createdAt
- updatedAt

### tableName: transactionFeeShare

- id
- transactionId
- merchantSettleId
- feeShareRuleId
- incomeTransactionId
- merchantFee
- percent
- amount
- bankCode
- createdAt
- updatedAt

### tableName: sbIncome

- id
- date
- total
- commission
- merchantFee
- billingSubs
- createdAt
- updatedAt

### tableName: sbIncomeByMerchant

- id
- merchantId
- sbIncomeId
- date
- total
- commission
- merchantFee
- billingSubs
- createdAt
- updatedAt

---

## 4. Мерчант

### tableName: merchant

- id
- productTypeId
- feePercent
- spayFeePercent
- userFee
- userFeeType
- bankCode
- iconPath
- slogan
- pack
- createdAt
- updatedAt

### tableName: merchantBillings
_(model `merchantBilling` дээр tableName заагаагүй — Sequelize-ийн default нэр `merchantBillings` гэж үзсэн; DB дээр шалгана уу)_

- id
- merchantId
- billFeeType
- billFee
- createdAt
- updatedAt

### tableName: merchantPermission

- id
- merchantId
- permissionId
- createdAt
- updatedAt

### tableName: permission

- id
- name
- description
- type
- createdAt
- updatedAt

### tableName: pos

- id
- supplier
- mark
- status
- vatMerchantId
- transactionName
- createdAt
- updatedAt

---

## 5. Мерчантад гаргах нэхэмжлэл (SmartPay → мерчант)

### tableName: merchantInvoices
_(model `merchantInvoice` дээр tableName заагаагүй — Sequelize-ийн default нэр `merchantInvoices` гэж үзсэн; DB дээр шалгана уу)_

- id
- dueDate
- amount
- vatAmount
- total
- paid
- status
- merchantId
- paidJournalNo
- paidDate
- description
- validUntil
- vatLogId
- createdAt
- updatedAt

### tableName: merchantInvoiceItems
_(model `merchantInvoiceItem` дээр tableName заагаагүй — Sequelize-ийн default нэр `merchantInvoiceItems` гэж үзсэн; DB дээр шалгана уу)_

- id
- description
- quantity
- rate
- amount
- merchantInvoiceId
- createdAt
- updatedAt

### tableName: merchantInvoiceCountDetails
_(model `merchantInvoiceCountDetail` дээр tableName заагаагүй — Sequelize-ийн default нэр `merchantInvoiceCountDetails` гэж үзсэн; DB дээр шалгана уу)_

- id
- description
- count
- rate
- total
- merchantInvoiceId
- createdAt
- updatedAt

---

## 6. НӨАТ (И-баримт)

### tableName: vatMerchant

- id
- createrMerchantId
- serviceName
- serviceCode
- vatDistrictCode
- taxType
- taxProductCode
- approved
- status
- feePercent
- bankCode
- individual
- createdAt
- updatedAt

### tableName: vatLog

- id
- merchantId
- status
- time
- createdAt
- updatedAt

---

## 7. Админ ба нэвтрэлт

### tableName: admin

- id
- createdAt
- updatedAt

### tableName: emailOtpVerification

- id
- expiresAt
- attempts
- verified
- verifiedAt
- createdAt
- updatedAt

### tableName: passwordResetToken

- id
- merchantId
- expires_at
- createdAt
- updatedAt

### tableName: token

- id
- type
- createdAt
- updatedAt

### tableName: userPin

- id
- userId
- createdAt
- updatedAt

---

## 8. Тусламж, FAQ, лог

### tableName: ticket

- id
- merchantId
- problemTypeId
- stage
- createdAt
- updatedAt

### tableName: ticketComment

- id
- ticketId
- notified
- createdAt
- updatedAt

### tableName: faq

- id
- question
- gotAnswer
- type
- aiFunctionCallId
- createdAt
- updatedAt

### tableName: aiFunctionCall

- id
- answer
- name
- description
- image
- createdAt
- updatedAt

### tableName: log

- id
- merchantId
- createdAt
- updatedAt

---

## Хавсралт: Хассан баганын ангилал

Доорх төрлийн багануудыг гадагш задруулахгүй гэж үзэж жагсаалтаас хассан. Утгыг нь оруулаагүй.

| Ангилал | Хассан баганын нэр (хүснэгтээр) |
|---|---|
| Холбоо барих мэдээлэл | invoice: `phone`; merchant: `email`, `phone`, `phone2`, `address`; admin: `email`, `phone`; emailOtpVerification: `email` |
| Чөлөөт текст (тоот, нэр агуулж болно) | invoice: `description`; invoiceItem: `description`; transaction: `description`; bankTransactionLog: `description`; ticket: `problem`; ticketComment: `comment`; log: `description` |
| URL/callback | invoice: `returnUrl`, `successCallback`, `callBackResponse`; invoiceItem: `successCallback`, `callBackResponse`; qpayHistory: `callBackUrl` |
| Нэвтрэлт/нууц үг/токен | invoice: `secureId`; merchant: `authUsername`, `authPassword`; admin: `username`, `password`; emailOtpVerification: `otpHash`; passwordResetToken: `token`; token: `token`; userPin: `tranPin` |
| Регистр/ТТД | invoice: `subMerchantRegister`; invoiceItem: `subMerchantRegister`; invoiceItemVatInfo: `merchantRegister`, `companyRegister`, `easyRegister`; merchant: `register`; vatMerchant: `register`, `merchantTin` |
| Дансны дугаар | invoiceItem: `accountNumber`; transaction: `accountNumber`, `fromAccountNumber`; transactionBucket: `accountNumber`, `fromAccountNumber`; bankTransactionLog: `accountNumber`, `relatedAccount`; incomeTransaction: `accountNumber`, `fromAccountNumber`; feeShareRule: `accountNumber`; transactionFeeShare: `accountNumber`; merchant: `accountNumber`; vatMerchant: `accountNumber` |
| JSON/payload | invoiceItem: `data`; invoiceItemVatInfo: `qrJson`, `requestData`; settle: `rawJson`; vatLog: `qrJson`, `requestData`; log: `data` |
| Төлбөрийн шлюзийн дотоод ID | qpayHistory: `qpayId`; negdiHistory: `checkid`, `tranid`; negdiJoinCardHistory: `checkid`, `tranid` |
| Картын мэдээлэл | negdiJoinCardHistory: `cancelApprovalCode`; card: `tokenid`, `expdate`, `maskedpan`, `cardName` |
| Дансны үлдэгдэл | bankTransactionLog: `remain` |
| Хүн/байгууллагын нэр | feeShareRule: `recipientName`; transactionFeeShare: `recipientName`; merchant: `name`; vatMerchant: `name`; admin: `name` |
| IP хаяг | vatLog: `ip`; emailOtpVerification: `ipAddress`; log: `ip` |

Нийт хадгалсан багана: **322** (createdAt/updatedAt орсон), хассан: **77**.

**Тэмдэглэл**
- `name` баганыг зөвхөн хүн/байгууллагын нэр бол хассан (`admin`, `merchant`, `vatMerchant`). Лавлах хүснэгтийн нэр (`productType`, `paymentMethod`, `permission`, `aiFunctionCall`) үлдсэн.
- `description`-ийг гүйлгээ, нэхэмжлэлийн хүснэгтэд хассан — тоот, хүний нэр, дансны мэдээлэл орж болдог. Лавлах/үйлчилгээний тайлбар үлдсэн.
- `bankCode` (банкны код) ба `journalNo` (гүйлгээний журнал) үлдсэн. Дансны дугаарыг бүгдийг нь хассан.
- `invoiceItem.data` (JSON — propertyId, townName) хассан.
