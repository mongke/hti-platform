# esukh — recommended source-database fixes

Prepared 30 September 2026 for the esukh engineering team.

Findings come from the database schema only. No table data was read, so where a column looks like a stored secret we can say what the definition allows, not what the values are — those questions are for your team. Each item says what it costs the analytics platform, so you can weigh it against your own priorities.

## 1. Summary

| Metric | Value |
|---|---|
| Tables in the database | 241 |
| Tables with no update timestamp | 162 (67%) |
| Tables with no primary key | 1 |
| Composite primary keys | 0 |
| Case-colliding column names | 0 |
| Credential-looking columns | 25 |
| Possible citizen register numbers | 3 |


## 2. Stored secrets — highest priority

Whether these hold plaintext cannot be told from a schema. Two things can: a column named for its protection (passwordHash) tells a reader it is hashed, and a column too short to hold any standard hash cannot be storing one.

| Column | Type | Named as protected | Note |
|---|---|---|---|
| `adminaccount.tokenVersion` | int NOT NULL DEFAULT '0' | no |  |
| `apartment.stateEBillinLoginPass` | varchar(45) DEFAULT NULL | no |  |
| `branch.khanToken` | varchar(545) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL | no |  |
| `couponcreater.password` | varchar(20) DEFAULT NULL | no | cannot hold any standard hash (20 chars) |
| `negdicard.tokenid` | int DEFAULT NULL | no |  |
| `notification.token` | varchar(145) DEFAULT NULL | no |  |
| `paymentpartner.qpayLoginPass` | varchar(145) DEFAULT NULL | no |  |
| `paymentpartner.qpayToken` | varchar(545) DEFAULT NULL | no |  |
| `paymentpartner.tokenDate` | datetime DEFAULT NULL | no |  |
| `qpaytoken.token` | varchar(1045) DEFAULT NULL | no |  |
| `qpaytokensb.token` | varchar(1045) DEFAULT NULL | no |  |
| `secondsystem.password` | varchar(255) DEFAULT NULL | no |  |
| `secondsystem.token` | text | no | no length limit declared |
| `secondsystem.tokenExpired` | datetime DEFAULT NULL | no |  |
| `systemadmin.loginPass` | varchar(100) NOT NULL | no |  |
| `town.stateBankTransLoginPass` | varchar(45) DEFAULT NULL | no |  |
| `town.khanToken` | varchar(245) DEFAULT NULL | no |  |
| `towncorporate.loginPass` | varchar(100) DEFAULT NULL | no |  |
| `towncorporate.token` | varchar(500) DEFAULT NULL | no |  |
| `tttoken.token` | varchar(1000) DEFAULT NULL | no |  |
| `user.loginPass` | varchar(105) DEFAULT NULL | no |  |
| `user.mobileToken` | varchar(100) DEFAULT NULL | no |  |
| `worker.loginPass` | varchar(100) DEFAULT NULL | no |  |
| `worker.mobileToken` | varchar(250) DEFAULT NULL | no |  |
| `workernotification.token` | varchar(255) DEFAULT NULL | no |  |

- For each column above: is the value plaintext, reversibly encrypted, or hashed? If hashed, which algorithm?
- Any plaintext password: hash with bcrypt or argon2 and force a reset cycle.
- Any credential that must stay replayable (third-party logins): encrypt at rest with a key held outside the database.
- Rename to state the protection (password -> passwordHash), so the next reader does not have to ask.
- Declare a length. An unbounded text column for a secret hides both truncation bugs and unexpected values.


## 3. Missing update timestamps

162 of 241 tables have no updatedAt-style column. Without one there is no way to ask "what changed since last night?", so the platform must re-read the entire table on every run. For small reference tables that is harmless. For large transactional tables it is a full scan every night, forever. Adding a column that is set on every update converts that into reading only the rows that actually changed.

**The clearest case is monthlypayment at 16.5 million rows. It has regDate (creation) but no update timestamp, and regDate cannot be used as a substitute: isApprove changes after insert, so a creation-timestamp watermark would fetch a row once and never notice it was later approved.**

```
action, adminaction, advertise, advertisebranch, aiinfo, answer, apartment, apartmentpaymentgroup, balance, balancegraph, balancehistory, barrier, branchbalance, branchextracharge, branchhelp, branchhelpimage, branchinfo, branchinfofile, branchinfoimage, branchinfowhom, branchpaymentdetail, camera, capital, capitalfiles, capitalimages, capitalrepairs, capitalworker, car, cartemp, category, chatbotanswer, chip, chipbarrier, comment, company, companybranch, companycapital, complainfiles, complainimages, complainresult, conciergeitem, conciergemenu, contract, cost, counter, couponbranch, defaultaction, electricuser, errorvat, files, forum, forumfiles, forumimages, forumlike, forumwho, garage_raw_import, graphsummary, help, helpcommentimage, images, incomebytypes, incomepivot, information, infowhom, inouthistory, internaladimage, internaladwhom, khanpaylog, liftfloor, like, log, mainconfig, massmail, message, messagerecieved, meter, method, methodtype, monthlyconfig, monthlypayment, monthlypaymentapproved, monthremain, nearbyservice, negdicard, news, newsfiles, newsimages, note, notification, otp, otpv2, paymentapprove, paymentapprovejob, paymentgroup, paymentpartner, paymenttypereport, performance, phone, poll_answer, poll_apartment, poll_chose_users, poll_file, poll_picture, poll_question, pollapartment, pollchose, pollresult, pollwhom, position, priceinfo, priceinfomethod, process, processcomment, profession, property, property260226, propertyconfig, propertydept, protopro, qpaytoken, qpaytokensb, ratebranchinfo, ratecompany, rateworker, reference, rent, room, roomimage, roomorder, salesprocess, service, signuplog, statebalancedifference, statepayment, staterawtransaction, statesuberrors, tablename, taskattachment, taskcommentattachment, taskhistory, tdbpaylog, tempdel, tempreport, town, towncorporate, townsealimage, tttoken, useradvertise, userbarrier, usernote, useropenbarrier, userproperty, word, work, workeraction, workerapartment, workernotification, workerratingdetail, workerwork, workfiles, workimages, wrongmail
```


## 4. Structural issues

| Issue | Where | Why it matters |
|---|---|---|
| No primary key | `forumwho` | Rows cannot be merged or de-duplicated reliably; the platform must fall back to replacing the whole table. |
| Possible citizen register numbers | `branch.branchRegister, probill.vatRegister, worker.register` | varchar(10) matches the Mongolian citizen register format. If these are personal identity numbers they need the same care as passwords: restricted access, audit logging and a retention limit. |


## Data quality: branch province/district mismatch

8 of 432 branch rows have a district that does not belong to their province; 7 of the 8 are Chingeltei duureg, an Ulaanbaatar district, recorded under rural aimags. The newest was created 2026-09-03, so this is ongoing. Likely cause: the district dropdown is not reset when the province changes. Fix: reject on save when reference.root(district) <> province. See the separate bug report.


## town stores third-party bank credentials

town.stateBankTransLoginName / stateBankTransLoginPass and khanToken hold credentials for an external bank system. These must be replayable, so they cannot be hashed - the question is how they are encrypted at rest and where the key lives.
