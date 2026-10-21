# smartpay schema analysis — domains and privacy classification

Generated 2026-09-30 10:09 UTC from `smartpay_schema.sql`
(structure only, no rows). **A proposal for the data officer, not a finding** — everything is
inferred from column names, and names lie. Nothing loads until it is in a signed control table.

## 1. Inventory

- Tables: **37**
- Columns: **366**

## 2. Proposed domains

**D1 Merchants & POS** — 11 tables

```
merchant, merchantBillings, merchantInvoiceCountDetails, merchantInvoiceItems, merchantInvoices, 
merchantPermission, merchantSettle, pos, productType, vatMerchant, vatMerchantPos
```

**D2 Transactions & cards** — 8 tables

```
bankTransactionLog, card, negdiHistory, negdiJoinCardHistory, paymentMethod, qpayHistory, 
transaction, transactionBucket
```

**D3 Invoicing, VAT & settle** — 7 tables

```
invoice, invoiceItem, invoiceItemVatInfo, sbIncome, sbIncomeByMerchant, settle, vatLog
```

**D4 Identity & access** — 5 tables

```
admin, passwordResetToken, permission, token, userPin
```

**D5 Support & content** — 4 tables

```
aiFunctionCall, faq, ticket, ticketComment
```

**D6 Logs** — 1 tables

```
log
```

**UNASSIGNED** — 1

```
incomeTransaction
```

## 3. CREDENTIALS IN THE DATABASE — highest priority

Columns whose names indicate a secret. These must **never** be copied to any layer, and
their presence is a source-system security question independent of this platform: if any
holds a plaintext or reversible value, that is a live issue for the owning team.

- `admin`: `password`
- `card`: `tokenid`
- `merchant`: `authPassword`
- `passwordResetToken`: `token`
- `token`: `token`
- `userPin`: `tranPin`

## 4. Never copied (policy section 4)

### 4.1 Correspondence tables — 2

Content is sensitive under policy 4.1.4; excluded whole, not column-filtered.

```
ticket, ticketComment
```

### 4.2 Identity columns — 27 in 13 tables

Names, phones, emails. Dropped, never tokenised. **Over-detected on purpose** — triage is a
data-officer task, because a false positive costs a review and a false negative copies
personal data.

- `admin`: `username`, `name`, `email`, `phone`
- `aiFunctionCall`: `name`
- `bankTransactionLog`: `bankName`
- `card`: `bankname`, `cardName`
- `invoice`: `phone`, `subMerchantRegister`
- `invoiceItem`: `subMerchantRegister`
- `invoiceItemVatInfo`: `merchantRegister`, `companyRegister`, `easyRegister`
- `merchant`: `name`, `email`, `phone`, `phone2`, `register`, `authUsername`
- `paymentMethod`: `name`
- `permission`: `name`
- `pos`: `transactionName`
- `productType`: `name`
- `vatMerchant`: `name`, `register`, `serviceName`

### 4.3 Registration / passport numbers — 7 in 5 tables

- `invoice`: `subMerchantRegister`
- `invoiceItem`: `subMerchantRegister`
- `invoiceItemVatInfo`: `merchantRegister`, `companyRegister`, `easyRegister`
- `merchant`: `register`
- `vatMerchant`: `register`

### 4.4 Free-text columns — 14 in 12 tables

- `aiFunctionCall`: `answer`, `description`
- `bankTransactionLog`: `description`
- `faq`: `question`, `gotAnswer`
- `invoice`: `description`
- `invoiceItem`: `description`
- `log`: `description`
- `merchantInvoiceCountDetails`: `description`
- `merchantInvoiceItems`: `description`
- `merchantInvoices`: `description`
- `permission`: `description`
- `ticketComment`: `comment`
- `transaction`: `description`

## 5. Copy to bronze, tokenise into silver — 44 columns in 25 tables

- `bankTransactionLog`: `relatedAccount`, `accountNumber`
- `card`: `userId`
- `incomeTransaction`: `merchantId`, `accountNumber`, `merchantSettleId`, `fromAccountNumber`
- `invoice`: `userId`, `merchantId`
- `invoiceItem`: `accountNumber`
- `log`: `merchantId`
- `merchant`: `address`, `accountNumber`, `userFee`, `userFeeType`
- `merchantBillings`: `merchantId`
- `merchantInvoiceCountDetails`: `merchantInvoiceId`
- `merchantInvoiceItems`: `merchantInvoiceId`
- `merchantInvoices`: `merchantId`
- `merchantPermission`: `merchantId`
- `merchantSettle`: `merchantId`, `subMerchantAmount`, `merchantAmount`
- `negdiJoinCardHistory`: `userId`
- `passwordResetToken`: `merchantId`
- `pos`: `vatMerchantId`
- `sbIncome`: `merchantFee`
- `sbIncomeByMerchant`: `merchantId`, `merchantFee`
- `ticket`: `merchantId`
- `transaction`: `accountNumber`, `merchantFee`, `merchantSettleId`, `fromAccountNumber`, `merchantFeePercent`
- `transactionBucket`: `accountNumber`, `merchantId`, `fromAccountNumber`
- `userPin`: `userId`
- `vatLog`: `merchantId`
- `vatMerchant`: `createrMerchantId`, `merchantTin`, `accountNumber`
- `vatMerchantPos`: `vatMerchantId`

## 6. Next steps

1. Owning team confirms whether the section 3 credential columns are hashed or plaintext.
2. Data officer triages section 4.2 — separate person names from object names.
3. Confirm or replace the domains above.
4. Purpose register entry per domain, then build the control table and gate it with
   `jobs/validate_control_table.py`.