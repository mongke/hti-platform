# esukh schema analysis — domains and privacy classification

Generated 2026-09-29 19:48 UTC from `esukh_schema.sql` (structure only, no rows).
Input was the DDL extracted from `/home/developer/mysql/backup_file.sql` (mysqldump of `esukh`
from host 43.231.113.13, server 8.0.33).

**This is a proposal for the data officer, not a finding.** Everything below is inferred from
column *names*. Names lie: a `note` column may hold a code and a `code` column may hold free
text. Nothing here is loadable until it is in a signed `jobs/control_table.csv`.

## 1. Inventory

| Metric | This dump | Data Ger (Nov 2024) |
|---|---|---|
| Tables | **241** | 152 |
| Columns | 2214 | not stated |
| Declared foreign keys | **112** | 368 |

Two gaps worth raising before N2 is signed. The table count has grown **89 tables
(+58%)** since the assessment, so the 9-domain categorisation in that
document cannot be applied as-is. And only 112 foreign keys are declared against Data Ger's 368,
meaning **most relationships are enforced in application code, not in the schema** — so FK-based
lineage will be incomplete. Only 61 of 241 tables are touched by any declared FK.

## 2. Proposed domains

### D1 Identity & access — 44 tables (6 correspondence)

```
adminaccount, adminaction, adminbranchentry, apartmentpaymentgroup, capitalworker, company, 
companybranch, companycapital, companyrating, electricuser, group, groupjoinrequest, groupuser, 
otp, otpv2, paymentgroup, phone, poll_chose_users, position, profession, qpaytoken, qpaytokensb, 
ratecompany, rateworker, signuplog, systemadmin, tttoken, user, useradvertise, userbarrier, 
userbpay, usercouponlog, userfeedback, userfeedbackanswer, userlog, usernote, useropenbarrier, 
userproperty, worker, workeraction, workerapartment, workernotification, workerratingdetail, 
workerwork
```

### D2 Property & housing — 52 tables (8 correspondence)

```
advertisebranch, allowlistproperty, allowlistpropertyhistory, apartment, apartmentmodule, 
blacklistproperty, blacklistpropertyhistory, branch, branchbalance, branchcharge, 
branchextracharge, branchhelp, branchhelpassignee, branchhelpassignmentlog, branchhelpimage, 
branchhelptag, branchinfo, branchinfofile, branchinfoimage, branchinfowhom, branchinvoice, 
branchinvoicepayment, branchinvoicepaymentdetail, branchinvoicesummarylog, branchpaymentdetail, 
branchpaymentsummary, branchstatedifference, couponbranch, garage_raw_import, groupapartment, 
groupbranch, grouptown, module, poll_apartment, pollapartment, property, property260226, 
propertycaraccess, propertycaraccesshistory, propertyconfig, propertydept, propertyjoinrequest, 
propertyownerhistory, propertyprivateconfig, ratebranchinfo, rent, room, roomimage, roomorder, 
town, towncorporate, townsealimage
```

### D3 Billing & payments — 39 tables (0 correspondence)

```
balance, balancegraph, balancehistory, billinglog, capital, capitalfiles, capitalimages, 
capitalrepairs, cost, counter, coupon, couponcreater, coupondiscount, errorvat, incomebytypes, 
incomepivot, invoice, invoicebucket, khanpaylog, monthlypayment, monthlypaymentapproved, 
monthremain, overpaidbalance, overpayment, paymentapprove, paymentapprovejob, paymentpartner, 
paymenttypereport, pricecheckrequest, priceinfo, priceinfomethod, probill, qpayhistory, 
statebalancedifference, statebankstatement, statepayment, staterawtransaction, tdbpaylog, vat
```

### D4 Metering & utilities — 6 tables (0 correspondence)

```
electricpayed, graphsummary, liftfloor, meter, meterhistory, meterinfo
```

### D5 Access control & devices — 8 tables (0 correspondence)

```
barrier, camera, car, cartemp, chip, chipbarrier, inouthistory, negdicard
```

### D6 Service & maintenance — 29 tables (15 correspondence)

```
complain, complainfiles, complainimages, complainresult, complainresultfiles, conciergeitem, 
conciergemenu, help, helpcomment, helpcommentimage, helpdeskstage, helpdesktag, helpdesktagfaq, 
nearbyservice, performance, process, processcomment, ratingcriteria, salesprocess, service, task, 
taskassignment, taskattachment, taskcomment, taskcommentattachment, taskhistory, work, workfiles, 
workimages
```

### D7 Communications & content — 42 tables (35 correspondence)

```
advertise, answer, chatbotanswer, comment, contract, files, forum, forumfiles, forumimages, 
forumlike, forumwho, images, importantfiles, information, infowhom, internalad, internaladimage, 
internaladwhom, like, massmail, message, messagerecieved, news, newsfiles, newsimages, note, 
notification, poll, poll_answer, poll_file, poll_picture, poll_question, pollchose, pollresult, 
pollwhom, post, postcomment, postcommentimage, postcommentlike, postimage, postlike, word
```

### D8 Reference & config — 13 tables (0 correspondence)

```
action, aiinfo, category, defaultaction, mainconfig, mainconfighistory, method, methodtype, 
monthlyconfig, protopro, reference, secondsystem, tablename
```

### D9 Logs, audit & integration — 7 tables (0 correspondence)

```
burtelog, log, negdihistory, reverselog, tempdel, tempreport, wrongmail
```

### UNASSIGNED — 1 tables (0 correspondence)

```
statesuberrors
```

## 3. Never copied at all (policy section 4)

### 3.1 Correspondence tables — 64 of 241

Content of forums, chats, messages, comments, complaints, polls, news, notifications and
support tickets is sensitive under policy 4.1.4. These are excluded **entirely** — not
column-filtered — because the content *is* the table.

```
advertise, advertisebranch, answer, branchhelp, branchhelpassignee, branchhelpassignmentlog, 
branchhelpimage, branchhelptag, chatbotanswer, comment, complain, complainfiles, complainimages, 
complainresult, complainresultfiles, conciergemenu, forum, forumfiles, forumimages, forumlike, 
forumwho, help, helpcomment, helpcommentimage, helpdeskstage, helpdesktag, helpdesktagfaq, 
internalad, internaladimage, internaladwhom, like, massmail, message, messagerecieved, news, 
newsfiles, newsimages, note, notification, poll, poll_answer, poll_apartment, poll_chose_users, 
poll_file, poll_picture, poll_question, pollapartment, pollchose, pollresult, pollwhom, post, 
postcomment, postcommentimage, postcommentlike, postimage, postlike, processcomment, taskcomment, 
taskcommentattachment, useradvertise, userfeedback, userfeedbackanswer, usernote, 
workernotification
```

### 3.2 Identity columns — 188 columns in 107 tables

Names, phones, emails, register numbers. Policy drops these; they are **not** tokenised.
**Over-detected on purpose** — this list includes non-personal matches such as `action.name`,
`barrier.barrierName` and `branchinfofile.name`. Triage is a data-officer task; erring toward
over-inclusion is deliberate, because a false positive costs a review and a false negative
copies personal data.

- `action`: `name`
- `advertise`: `email`
- `aiinfo`: `phone`, `robotName`
- `answer`: `registerWorkerId`
- `apartment`: `apartmentName`, `stateEBillingLoginName`, `accountName`
- `balance`: `name`
- `barrier`: `barrierName`
- `billinglog`: `partnerId`, `partnerName`
- `branch`: `name`, `phone`, `email`, `latinName`, `msgPhone`, `branchRegister`, `invoiceMail`, `paymentNameApp`
- `branchhelpimage`: `name`
- `branchinfo`: `banner`
- `branchinfofile`: `name`
- `branchinfoimage`: `name`
- `branchpaymentsummary`: `branchName`, `moduleName`
- `branchstatedifference`: `apartmentName`, `branchName`
- `camera`: `name`
- `capital`: `capitalName`
- `capitalfiles`: `fileName`
- `capitalimages`: `imageName`
- `cartemp`: `ownerName`
- `category`: `name`
- `chatbotanswer`: `name`
- `company`: `name`, `register`, `email`, `phone1`, `phone2`
- `companybranch`: `email`, `phone1`, `phone2`
- `complain`: `complainerId`
- `complainfiles`: `fileName`
- `complainimages`: `imageName`
- `complainresultfiles`: `fileName`
- `conciergeitem`: `name`, `phone1`, `phone2`
- `conciergemenu`: `name`
- `contract`: `name`
- `coupon`: `name`, `phone`
- `couponcreater`: `name`, `phone`, `loginName`
- `electricuser`: `register`
- `files`: `fileName`
- `forumfiles`: `fileName`
- `forumimages`: `imageName`
- `garage_raw_import`: `c32_name`
- `group`: `name`
- `help`: `screenName`
- `helpcomment`: `workerName`
- `helpcommentimage`: `name`
- `helpdeskstage`: `name`
- `helpdesktag`: `name`
- `images`: `imageName`
- `internalad`: `phone1`, `phone2`
- `internaladimage`: `imageName`
- `khanpaylog`: `accountName`
- `liftfloor`: `name`
- `message`: `phone`
- `method`: `name`
- `methodtype`: `name`
- `module`: `name`
- `monthremain`: `apartmentName`, `ownerName`
- `nearbyservice`: `name`, `phone`
- `negdicard`: `bankname`, `cardName`
- `negdihistory`: `accountName`
- `newsfiles`: `fileName`
- `newsimages`: `imageName`
- `note`: `imageName`, `fileName`
- `otpv2`: `phone`
- `overpaidbalance`: `branchName`, `propertyName`, `apartmentName`
- `overpayment`: `branchName`
- `paymentgroup`: `name`, `msgName`, `vatRegister`
- `paymentpartner`: `name`, `email`, `phone`, `qpayLoginName`
- `paymenttypereport`: `name`, `register`
- `phone`: `name`, `phone`
- `poll_file`: `orignal_name`
- `poll_picture`: `orignal_name`
- `position`: `name`
- `postcommentimage`: `name`
- `postimage`: `name`
- `priceinfo`: `name`
- `probill`: `easyRegister`, `vatRegister`
- `profession`: `name`
- `property`: `akrelRegister`
- `property260226`: `akrelRegister`
- `propertycaraccess`: `registeredWorkerId`
- `propertycaraccesshistory`: `registeredWorkerId`
- `propertydept`: `apartmentName`, `userName`, `userPhone`
- `propertyjoinrequest`: `ownerType`
- `ratingcriteria`: `name`
- `reference`: `name`, `shortname`
- `room`: `name`, `phone1`, `phone2`
- `roomorder`: `email`, `phone`, `name`
- `salesprocess`: `branchName`, `branchEmail`, `branchPhone`, `calledUserName`, `calledUserPhone`
- `secondsystem`: `name`, `username`
- `service`: `name`
- `signuplog`: `name`, `phone`
- `systemadmin`: `loginName`, `email`, `name`, `phone`
- `tablename`: `name`
- `taskattachment`: `name`
- `taskcommentattachment`: `name`
- `taskhistory`: `fieldName`
- `tdbpaylog`: `accountName`
- `tempreport`: `name`
- `town`: `townName`, `stateBankTransLoginName`, `branchRegister`, `phone`
- `towncorporate`: `loginName`
- `townsealimage`: `imageName`
- `user`: `lastName`, `name`, `register`, `email`, `phone1`, `phone2`, `phone3`, `loginName`, `mobileToken`
- `userlog`: `actionName`
- `userproperty`: `ownerType`, `easyRegister`, `vatRegister`, `name`, `email`
- `word`: `engFilename`, `monFilename`
- `worker`: `lastName`, `name`, `register`, `email`, `phone`, `loginName`, `mobileToken`, `phone1`
- `workfiles`: `fileName`
- `workimages`: `imageName`
- `wrongmail`: `email`, `mailTitle`, `mail`, `massmailId`

### 3.3 Free-text columns — 124 columns in 88 tables

- `advertise`: `title`, `description`
- `allowlistproperty`: `description`
- `allowlistpropertyhistory`: `description`
- `answer`: `complainId`, `text`
- `billinglog`: `requestBody`
- `blacklistproperty`: `description`
- `blacklistpropertyhistory`: `description`
- `branch`: `paperInvoiceText`, `messageLimit`, `payedMessage`, `courtInvoiceText`, `messageMultiply`
- `branchhelp`: `problemText`, `answerWorkerId`, `answer`
- `branchhelpassignmentlog`: `note`
- `branchinfo`: `title`, `infoText`
- `camera`: `insertBody`, `deleteBody`, `getBody`, `updateBody`
- `capitalrepairs`: `repairText`
- `car`: `description`
- `chatbotanswer`: `answer`, `description`
- `comment`: `contentId`, `commentText`, `commentType`
- `companybranch`: `deletedReason`
- `companyrating`: `reason`
- `complain`: `text`
- `complainfiles`: `contentId`
- `complainimages`: `contentId`
- `complainresult`: `complainId`, `description`
- `coupon`: `imageDescription`, `description`
- `coupondiscount`: `description`
- `files`: `contentId`
- `forum`: `text`
- `help`: `text`
- `helpcomment`: `content`, `contentFormat`, `commentFile`
- `helpcommentimage`: `helpCommentId`
- `helpdesktag`: `description`
- `helpdesktagfaq`: `question`, `answer`
- `images`: `contentId`
- `importantfiles`: `title`, `content`
- `information`: `title`, `infoText`
- `internalad`: `title`
- `khanpaylog`: `reason`
- `like`: `contentId`, `contentType`
- `log`: `actionText`
- `massmail`: `body`, `title`
- `message`: `messageText`, `messageType`
- `messagerecieved`: `messageText`
- `monthlypayment`: `descText`
- `monthlypaymentapproved`: `descText`
- `negdihistory`: `reason`
- `news`: `title`, `infoText`
- `note`: `note`
- `notification`: `title`
- `paymentpartner`: `warnTextAfterPay`
- `performance`: `description`
- `poll`: `title`
- `poll_answer`: `answer_id`, `question_id`, `option_text`
- `poll_chose_users`: `question_id`, `answer_id`
- `poll_file`: `question_id`
- `poll_picture`: `question_id`, `question_uniqueKey`
- `poll_question`: `question_id`, `title`
- `pollchose`: `choseText`
- `pollresult`: `text`
- `post`: `title`
- `postcomment`: `comment`
- `postcommentimage`: `postCommentId`
- `postcommentlike`: `postCommentId`
- `process`: `note`
- `processcomment`: `comment`
- `propertycaraccess`: `description`
- `propertycaraccesshistory`: `description`
- `propertyjoinrequest`: `reason`
- `propertyownerhistory`: `actionText`
- `rateworker`: `comment`
- `ratingcriteria`: `description`
- `salesprocess`: `note`
- `staterawtransaction`: `transText`
- `statesuberrors`: `errorText`
- `task`: `description`
- `taskcomment`: `comment`
- `taskcommentattachment`: `taskCommentId`
- `taskhistory`: `description`
- `tdbpaylog`: `reason`
- `town`: `courtInvoiceText`, `payedMessage`, `paperInvoiceText`
- `userfeedback`: `feedBack`, `complainId`
- `userfeedbackanswer`: `userFeedbackId`, `answer`
- `userlog`: `actionText`
- `usernote`: `text`
- `userproperty`: `isMessage`
- `work`: `description`
- `workernotification`: `title`
- `workfiles`: `contentId`
- `workimages`: `contentId`
- `wrongmail`: `title`, `body`

## 4. Copy to bronze, tokenise into silver — 141 columns in 96 tables

Plates, user/owner/customer ids, addresses, apartment and room identifiers, device and card
numbers. Policy permits these into bronze **only** because tokenisation needs them; they become
UUID tokens (per system) in silver, addresses become location groups, exact timestamps become
day + hour band.

- `aiinfo`: `userId`, `device`
- `apartment`: `apartmentIdBank`, `apartmentIdTransBank`, `bankAccountNumber`
- `apartmentmodule`: `apartmentId`
- `apartmentpaymentgroup`: `apartmentId`
- `balance`: `apartmentId`, `userId`
- `barrier`: `apartmentId`
- `branch`: `address`, `bankAccountNumber`, `canUserAddNews`, `appCarTypes`, `mqttCarUrl`, `carLimit`, `canUserDeleteCar`
- `branchpaymentdetail`: `apartmentId`
- `branchstatedifference`: `apartmentId`
- `camera`: `user`
- `capital`: `apartmentId`
- `car`: `apartmentId`, `userId`, `plateNumber`
- `cartemp`: `plateNumber`, `oldPlateNumber`
- `chip`: `chipNo`, `userId`, `apartmentId`
- `chipbarrier`: `chipId`, `barrierId`
- `comment`: `userId`
- `company`: `address`, `accountNumber`
- `companybranch`: `bankAccountNumber`
- `complain`: `apartmentId`
- `complainresult`: `userId`
- `conciergeitem`: `address`
- `electricpayed`: `electricUserId`
- `electricuser`: `userId`
- `group`: `createdUserId`
- `groupapartment`: `apartmentId`
- `groupjoinrequest`: `userId`
- `grouptown`: `apartmentId`
- `groupuser`: `userId`
- `incomepivot`: `apartmentId`
- `information`: `userId`
- `inouthistory`: `carId`, `plateNumber`, `address`
- `internalad`: `userId`
- `internaladwhom`: `apartmentId`
- `khanpaylog`: `bankAccount`
- `liftfloor`: `barrierId`
- `like`: `userId`
- `message`: `apartmentId`
- `meter`: `apartmentId`
- `monthlyconfig`: `apartmentId`
- `monthlypayment`: `apartmentId`
- `monthlypaymentapproved`: `apartmentId`
- `monthremain`: `apartmentId`, `userId`
- `nearbyservice`: `address`, `lng`, `lat`
- `negdicard`: `userId`
- `negdihistory`: `userId`, `bankAccountNumber`
- `notification`: `userId`
- `otp`: `userId`
- `overpaidbalance`: `apartmentId`
- `paymentapprove`: `apartmentId`
- `paymentapprovejob`: `apartmentId`
- `poll_apartment`: `apartment_id`
- `poll_chose_users`: `poll_chose_users_id`, `apartment_id`, `user_id`
- `pollapartment`: `apartmentId`
- `pollresult`: `userId`
- `post`: `userId`
- `postcomment`: `userId`
- `postcommentlike`: `userId`
- `postlike`: `userId`
- `pricecheckrequest`: `userId`
- `priceinfo`: `barrierId`, `userFilter`
- `property`: `apartmentId`, `roomCount`, `fullAddress`
- `property260226`: `apartmentId`, `roomCount`, `fullAddress`
- `propertycaraccess`: `carAccess`
- `propertycaraccesshistory`: `carAccess`
- `propertyconfig`: `apartmentId`
- `propertydept`: `userId`, `apartmentId`
- `propertyjoinrequest`: `userId`
- `propertyownerhistory`: `currentUserId`, `prevUserId`
- `rent`: `userPropertyId`
- `room`: `apartmentId`, `roomNo`
- `roomimage`: `roomId`
- `roomorder`: `roomId`, `userId`, `apartmentId`, `zahApartmentId`, `address`
- `salesprocess`: `branchAddress`
- `statebalancedifference`: `apartmentId`
- `statebankstatement`: `regUser`, `accountNumber`
- `statepayment`: `apartmentId`
- `taskassignment`: `userId`
- `taskcomment`: `userId`
- `taskhistory`: `ipAddress`, `userAgent`
- `tdbpaylog`: `bankAccount`
- `town`: `bankAccountNumber`
- `towncorporate`: `accountNumber`
- `user`: `khanWalletUserId`
- `useradvertise`: `userId`, `apartmentId`
- `userbarrier`: `barrierId`, `userId`, `apartmentId`
- `userbpay`: `userId`
- `usercouponlog`: `userId`
- `userfeedback`: `userId`
- `userfeedbackanswer`: `userId`
- `userlog`: `userId`
- `usernote`: `userId`
- `useropenbarrier`: `barrierId`, `userId`
- `userproperty`: `userId`
- `worker`: `address`, `lastDeviceId`
- `workerapartment`: `apartmentId`
- `wrongmail`: `userId`, `apartmentId`

## 5. Can it be filtered, or must the table stay out?

| Case | Count | Decision |
|---|---|---|
| Correspondence tables | 64 | **Exclude whole table.** The sensitive content is the payload. |
| Tables with identity columns but a usable non-identity remainder | 80 | **Column-filter.** Drop the identity columns at copy-in; the allowlist does this by omission. |
| Ad-hoc / temp / dated tables | 9 | **Exclude.** Not a stable interface; see list below. |

```
cartemp, garage_raw_import, property260226, protopro, secondsystem, tablename, tempdel, tempreport, tttoken
```

Filtering works by **omission**: `columns_allowlist` names what is copied, so an identity column
is excluded by simply not listing it. No `DROP`, no masking step, nothing to forget. That is why
`validate_control_table.py` refuses `*`.

## 6. Next steps

1. Data officer triages section 3.2 — separate personal names from object names.
2. Confirm the 9 domains above, or supply Data Ger's original categorisation for the 152-table subset.
3. Purpose register entry per domain (policy step 1) — `purpose_ref` values for the control table.
4. Build `jobs/control_table.csv` from the survivors; `validate_control_table.py` gates it.

## 7. Draft control table (generated 2026-09-29)

`jobs/control_table.csv` — **170 tables proposed, 71 excluded, 241 accounted for.** It fails
validation with 170 `CT013` errors by design: `purpose_ref` is empty on every row, so the draft
cannot be loaded until a purpose register entry exists for each. A draft that validated clean
would look approved when it is not.

Columns were filtered by *omission* using the same patterns `validate_control_table.py` enforces,
so no `CT014`/`CT015`/`CT016` fires. There are no structural errors: every row's primary key and
watermark are present in its own allowlist. 58 rows are `incremental` (a usable `updatedAt`),
112 are `full`.

### 7.1 Every row is `bronze` — deliberately

An earlier pass assigned 60 tables to `bronze-ref` by heuristic (no tokenise-candidate columns,
no identity columns dropped). **That heuristic is unsafe and was reverted.** A table can hold
personal data through a foreign key while having no personal-looking column name — `invoice`,
`balancehistory`, `branchinvoice`, `meterhistory` and `adminaccount` all landed in `bronze-ref`
that way. Since `bronze-ref` carries *longer* retention than bronze's ≤24 h, a wrong assignment
keeps personal data beyond what policy allows. `bronze` is therefore the default and promotion
to `bronze-ref` is a per-table data-officer decision. Candidates to consider:

```
adminaccount, adminaction, adminbranchentry, allowlistproperty, allowlistpropertyhistory, 
balancegraph, balancehistory, blacklistproperty, blacklistpropertyhistory, branchbalance, 
branchcharge, branchextracharge, branchinfo, branchinfowhom, branchinvoice, branchinvoicepayment, 
branchinvoicepaymentdetail, branchinvoicesummarylog, burtelog, capitalrepairs, capitalworker, 
companycapital, companyrating, cost, counter, couponbranch, coupondiscount, defaultaction, 
errorvat, graphsummary, groupbranch, importantfiles, incomebytypes, infowhom, invoice, 
invoicebucket, log, mainconfig, mainconfighistory, meterhistory, meterinfo, performance, 
priceinfomethod, process, propertyprivateconfig, qpayhistory, qpaytoken, qpaytokensb, 
ratebranchinfo, ratecompany, rateworker, reverselog, staterawtransaction, statesuberrors, task, 
vat, work, workeraction, workerratingdetail, workerwork
```

### 7.2 Over-filtered lookup tables — 13 tables left with ≤2 columns

These are almost certainly lookup tables whose only meaningful column is a `name` that was
dropped as identity. A `profession.name` or `category.name` is not personal data. Each needs a
`CT015` waiver in `control_table_exceptions.csv` rather than a pattern change:

```
branchinfofile(2), branchinfoimage(2), category(1), counter(2), files(1), images(2), methodtype(1), 
position(1), profession(1), signuplog(2), townsealimage(2), workfiles(2), workimages(2)
```

### 7.3 Known false positives to waive

Seen on `branch`: `paperInvoiceText`, `courtInvoiceText`, `messageLimit`, `payedMessage`,
`messageMultiply` — matched on `text` and `message` but are invoice templates and numeric
config, not correspondence. Representative of the ~183 identity and ~126 free-text matches
across the draft; triage is the review.

### 7.4 Excluded tables

`jobs/control_table_excluded.csv` records all 71 with a reason — 62 correspondence tables
(policy 4.1.4) and 9 ad-hoc/temp/dated tables. Every one of the 241 tables appears in exactly
one of the two files, so nothing is dropped silently.
