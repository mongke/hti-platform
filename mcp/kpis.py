"""KPI registry for the "Смарт Монгол туслах" app (docs/Смарт Монгол туслах app KPI.pdf, 58 items).

Every KPI is computed from the tokenised `silver` layer or the non-PII `bronze_ref`
layer through the Spark Thrift server. Nothing here reads `bronze` (raw personal data,
24 h retention, policy section 4). People appear only as per-system UUID tokens, so
"distinct users" is COUNT(DISTINCT userId) over tokens - correct for counting, useless
for identifying anyone.

status:
  available   - the KPI as written in the PDF
  partial     - computable approximation; `note` says what differs
  unavailable - the data is not in the phase-1 allowlist (or not in any database);
                `needs` names the table/column that would unlock it

SQL templates use {start} / {end} (ISO dates, exclusive end) and {grain} (day|week|month).
"""
from __future__ import annotations

GRAINS = {"day": "date_trunc('day', {c})", "week": "date_trunc('week', {c})", "month": "date_trunc('month', {c})"}

def g(col: str) -> str:
    return "{grain_" + col + "}"

KPIS: list[dict] = [
 dict(id=1, title="Нийт хэрэглэгчийн тоо", status="available",
      sql="""SELECT COUNT(*) AS users, MAX(createdAt) AS newest_registration
             FROM silver.sma_users""",
      note="sma.Users loaded 2026-10-09 (Алхам 1). The table has no status/active column, so this is "
           "every registered user, not only active ones. Newest registration is reported so a stale "
           "dump is visible in the answer itself."),
 dict(id=2, title="Идэвхитэй хэрэглэгчийн тоо / хувь", status="available",
      sql="""SELECT COUNT(DISTINCT a.userId) AS active_users,
                    (SELECT COUNT(*) FROM silver.sma_users) AS registered_users,
                    ROUND(100.0 * COUNT(DISTINCT a.userId)
                          / NULLIF((SELECT COUNT(*) FROM silver.sma_users), 0), 2) AS active_pct
             FROM silver.sma_useractionlogs a
             WHERE a.createdAt >= '{start}' AND a.createdAt < '{end}'""",
      note="Active = has an action log in the period; denominator is now the real registered-user count. "
           "The ratio is only coherent because sma.Users.id and sma.UserActionLogs.userId share one token "
           "namespace (see G18) - before 2026-10-08 they were different UUIDs for the same person."),
 dict(id=3, title="Ямар ч алдаа гараагүй ашиглаж буй хэрэглэгчийн хувь", status="available",
      sql="""WITH act AS (SELECT DISTINCT userId FROM silver.sma_useractionlogs WHERE createdAt >= '{start}' AND createdAt < '{end}'),
                  err AS (SELECT DISTINCT userId FROM silver.sma_smaerrors WHERE createdAt >= '{start}' AND createdAt < '{end}')
             SELECT COUNT(*) AS active_users, COUNT(*) - COUNT(err.userId) AS error_free_users,
                    ROUND(100.0 * (COUNT(*) - COUNT(err.userId)) / NULLIF(COUNT(*),0), 2) AS error_free_pct
             FROM act LEFT JOIN err USING (userId)"""),
 dict(id=4, title="Шинэ хэрэглэгчийн тоо, өсөлт (өдөр/7 хоног/сар)", status="available",
      sql="""SELECT {grain_createdAt} AS period, COUNT(*) AS new_users
             FROM silver.sma_users
             WHERE createdAt >= '{start}' AND createdAt < '{end}'
             GROUP BY 1 ORDER BY 1""",
      note="sma.Users.createdAt is the real registration date (loaded 2026-10-09); this no longer "
           "approximates it with first appearance in a log."),
 dict(id=5, title="ДАН-гаар баталгаажсан хэрэглэгч", status="available",
      sql="""SELECT {grain_danVerifiedAt} AS period, COUNT(*) AS dan_verified_users
             FROM silver.sma_users
             WHERE danVerifiedAt >= '{start}' AND danVerifiedAt < '{end}'
             GROUP BY 1 ORDER BY 1""",
      note="Users whose DAN (national e-ID) verification time falls in each period (sma.Users.danVerifiedAt, "
           "loaded 2026-10-21, truncated to the hour). Users never verified are not counted."),
 dict(id=6, title="СӨХ-д бүртгэлгүй СМА хэрэглэгч", status="unavailable",
      needs="cross-system link sma.Users <-> myproperty.tenant/owner (open decision: cross-system linking)"),
 dict(id=7, title="Нийт сууцны тоо (өсөлт)", status="partial",
      sql="""SELECT COUNT(*) AS dwellings, COUNT(DISTINCT branchId) AS soh_count, COUNT(DISTINCT townId) AS town_count
             FROM silver.esukh_property WHERE propertyType = 1""",
      note="esukh.property.propertyType codes confirmed by the esukh team's own report spec (2026-10-21): 1 = сууц (dwelling), 2 = гараж (garage), 3 = агуулах (storage). property.isDeleted defaults to 1 in esukh, so it is NOT used as a filter. Current totals only: esukh.property carries no creation date, so growth by day/week/month cannot be computed.", needs="esukh.property creation date (for growth)"),
 dict(id=8, title="Сууц: хотхон ба талбайгаар", status="partial",
      sql="""SELECT branchId AS soh_id,
                    CASE WHEN size IS NULL OR size <= 0 THEN 'unknown' WHEN size < 40 THEN '<40m2' WHEN size < 80 THEN '40-80m2'
                         WHEN size < 120 THEN '80-120m2' ELSE '>=120m2' END AS area_band,
                    COUNT(*) AS dwellings, ROUND(AVG(CASE WHEN size > 0 THEN size END), 1) AS avg_area
             FROM silver.esukh_property WHERE propertyType = 1
             GROUP BY 1, 2 ORDER BY 1, 2""",
      note="esukh.property.propertyType codes confirmed by the esukh team's own report spec (2026-10-21): 1 = сууц (dwelling), 2 = гараж (garage), 3 = агуулах (storage). property.isDeleted defaults to 1 in esukh, so it is NOT used as a filter. Grouped by СӨХ (branchId) and floor-area band; no 'complex grade' (expensive/average/cheap) exists in any source.",
      needs="a complex_grade reference list"),
 dict(id=9, title="Нийт гражийн тоо (өсөлт)", status="partial",
      sql="""SELECT COUNT(*) AS garages, COUNT(DISTINCT branchId) AS soh_count, COUNT(DISTINCT townId) AS town_count
             FROM silver.esukh_property WHERE propertyType = 2""",
      note="esukh.property.propertyType codes confirmed by the esukh team's own report spec (2026-10-21): 1 = сууц (dwelling), 2 = гараж (garage), 3 = агуулах (storage). property.isDeleted defaults to 1 in esukh, so it is NOT used as a filter. Current totals only: esukh.property carries no creation date, so growth by day/week/month cannot be computed.", needs="esukh.property creation date (for growth)"),
 dict(id=10, title="Граж: хотхон ба талбайгаар", status="partial",
      sql="""SELECT branchId AS soh_id,
                    CASE WHEN size IS NULL OR size <= 0 THEN 'unknown' WHEN size < 40 THEN '<40m2' WHEN size < 80 THEN '40-80m2'
                         WHEN size < 120 THEN '80-120m2' ELSE '>=120m2' END AS area_band,
                    COUNT(*) AS garages, ROUND(AVG(CASE WHEN size > 0 THEN size END), 1) AS avg_area
             FROM silver.esukh_property WHERE propertyType = 2
             GROUP BY 1, 2 ORDER BY 1, 2""",
      note="esukh.property.propertyType codes confirmed by the esukh team's own report spec (2026-10-21): 1 = сууц (dwelling), 2 = гараж (garage), 3 = агуулах (storage). property.isDeleted defaults to 1 in esukh, so it is NOT used as a filter. Grouped by СӨХ (branchId) and floor-area band; no 'complex grade' (expensive/average/cheap) exists in any source.",
      needs="a complex_grade reference list"),
 dict(id=11, title="Нийт агуулахын тоо (өсөлт)", status="partial",
      sql="""SELECT COUNT(*) AS warehouses, COUNT(DISTINCT branchId) AS soh_count, COUNT(DISTINCT townId) AS town_count
             FROM silver.esukh_property WHERE propertyType = 3""",
      note="esukh.property.propertyType codes confirmed by the esukh team's own report spec (2026-10-21): 1 = сууц (dwelling), 2 = гараж (garage), 3 = агуулах (storage). property.isDeleted defaults to 1 in esukh, so it is NOT used as a filter. Current totals only: esukh.property carries no creation date, so growth by day/week/month cannot be computed.", needs="esukh.property creation date (for growth)"),
 dict(id=12, title="Агуулах: хотхон ба талбайгаар", status="partial",
      sql="""SELECT branchId AS soh_id,
                    CASE WHEN size IS NULL OR size <= 0 THEN 'unknown' WHEN size < 40 THEN '<40m2' WHEN size < 80 THEN '40-80m2'
                         WHEN size < 120 THEN '80-120m2' ELSE '>=120m2' END AS area_band,
                    COUNT(*) AS warehouses, ROUND(AVG(CASE WHEN size > 0 THEN size END), 1) AS avg_area
             FROM silver.esukh_property WHERE propertyType = 3
             GROUP BY 1, 2 ORDER BY 1, 2""",
      note="esukh.property.propertyType codes confirmed by the esukh team's own report spec (2026-10-21): 1 = сууц (dwelling), 2 = гараж (garage), 3 = агуулах (storage). property.isDeleted defaults to 1 in esukh, so it is NOT used as a filter. Grouped by СӨХ (branchId) and floor-area band; no 'complex grade' (expensive/average/cheap) exists in any source.",
      needs="a complex_grade reference list"),
 dict(id=13, title="Нийт үүссэн нэхэмжлэхийн тоо / дүн / дундаж", status="available",
      sql="""WITH e AS (SELECT to_date(CAST(invoiceMonth AS STRING), 'yyyyMM') AS m, cost FROM silver.esukh_balance WHERE cost > 0),
                  mp AS (SELECT issueDate AS m, totalAmount AS cost FROM silver.myproperty_invoice)
             SELECT 'esukh' AS system, {grain_m} AS period, COUNT(*) AS invoices, SUM(cost) AS total_amount, ROUND(AVG(cost), 2) AS avg_amount
             FROM e WHERE m >= '{start}' AND m < '{end}' GROUP BY 1, 2
             UNION ALL
             SELECT 'myproperty', {grain_m}, COUNT(*), SUM(cost), ROUND(AVG(cost), 2)
             FROM mp WHERE m >= '{start}' AND m < '{end}' GROUP BY 1, 2
             ORDER BY 2, 1""",
      note="esukh: one invoice = one balance row with cost > 0 (balance.cost = invoiced amount, per the esukh report spec), by invoiceMonth. "
           "myproperty: one invoice row by issueDate. Shown per system - never added together."),
 dict(id=14, title="Нэхэмжлэхийн насжилт (1/3/6 сарын дотор төлөгдсөн)", status="available",
      sql="""WITH paid AS (SELECT ip.invoiceId, MIN(p.paymentDate) AS first_paid
                           FROM silver.myproperty_invoicepayment ip JOIN silver.myproperty_payment p ON p.id = ip.paymentId GROUP BY 1)
             SELECT COUNT(*) AS invoices,
                    SUM(CASE WHEN datediff(first_paid, issueDate) <= 30  THEN 1 ELSE 0 END) AS paid_within_1m,
                    SUM(CASE WHEN datediff(first_paid, issueDate) <= 90  THEN 1 ELSE 0 END) AS paid_within_3m,
                    SUM(CASE WHEN datediff(first_paid, issueDate) <= 180 THEN 1 ELSE 0 END) AS paid_within_6m,
                    SUM(CASE WHEN first_paid IS NULL THEN 1 ELSE 0 END) AS unpaid
             FROM silver.myproperty_invoice i LEFT JOIN paid ON paid.invoiceId = i.id
             WHERE issueDate >= '{start}' AND issueDate < '{end}'"""),
 dict(id=15, title="СМА хэрэглэгч өөрөө үүсгэсэн нэхэмжлэх", status="partial",
      sql="""SELECT type, payerType, COUNT(*) AS invoices, SUM(totalAmount) AS total_amount, ROUND(AVG(totalAmount),2) AS avg_amount
             FROM silver.myproperty_invoice WHERE issueDate >= '{start}' AND issueDate < '{end}' GROUP BY 1,2 ORDER BY 3 DESC""",
      note="Breakdown by invoice type/payer; which value means 'created by the SMA user' must be confirmed with the myproperty team."),
 dict(id=16, title="Смарт Монгол апп-р төлсөн нэхэмжлэх", status="partial",
      sql="""SELECT method, COUNT(*) AS payments, SUM(paidAmount) AS paid_amount, ROUND(AVG(paidAmount),2) AS avg_amount
             FROM silver.myproperty_payment WHERE paymentDate >= '{start}' AND paymentDate < '{end}' GROUP BY 1 ORDER BY 2 DESC""",
      note="Grouped by payment.method; the app's method value must be confirmed with the myproperty team."),
 dict(id=17, title="Авто төлөлт тохиргоотой хэрэглэгч", status="unavailable", needs="an auto-pay settings table (none in sma/myproperty dumps)"),
 dict(id=18, title="Апп-р төлсөн нэхэмжлэхийн насжилт", status="partial",
      sql="""WITH paid AS (SELECT ip.invoiceId, MIN(p.paymentDate) AS first_paid, MIN(p.method) AS method
                           FROM silver.myproperty_invoicepayment ip JOIN silver.myproperty_payment p ON p.id = ip.paymentId GROUP BY 1)
             SELECT method, COUNT(*) AS invoices,
                    SUM(CASE WHEN datediff(first_paid, issueDate) <= 30  THEN 1 ELSE 0 END) AS paid_within_1m,
                    SUM(CASE WHEN datediff(first_paid, issueDate) <= 90  THEN 1 ELSE 0 END) AS paid_within_3m,
                    SUM(CASE WHEN datediff(first_paid, issueDate) <= 180 THEN 1 ELSE 0 END) AS paid_within_6m
             FROM silver.myproperty_invoice i JOIN paid ON paid.invoiceId = i.id
             WHERE issueDate >= '{start}' AND issueDate < '{end}' GROUP BY 1 ORDER BY 2 DESC"""),
 dict(id=19, title="Түрээслэгчийн тоо, өсөлт", status="available",
      sql="""SELECT {grain_createdAt} AS period, COUNT(*) AS new_tenants FROM silver.myproperty_tenant
             WHERE createdAt >= '{start}' AND createdAt < '{end}' GROUP BY 1 ORDER BY 1"""),
 dict(id=20, title="Түрээслэгчийн шилжилтийн загвар", status="unavailable",
      needs="myproperty.rentalAgreement holds only 2 agreements (2026-10-21) - too few for any pattern; "
            "the source must record rental agreements before this KPI means anything",
      note="Was 'available' until 2026-10-21 and returned averages over n=2."),
 dict(id=21, title="Өмчлөгч өөрчлөгдсөн тохиолдлын тоо", status="unavailable", needs="myproperty.ownerHistory.createdAt (timestamp not allowlisted)"),
 dict(id=22, title="Шинэ өмчлөгчийн загвар", status="unavailable", needs="ownerHistory timestamps + room link"),
 dict(id=23, title="Хуучин өмчлөгчийн загвар", status="unavailable", needs="ownerHistory timestamps"),
 dict(id=24, title="Түр нэвтрэх зөвшөөрөлтэй / нэвтэрсэн хэрэглэгч", status="unavailable", needs="parkly guest/visitor access tables (not in the 27 'Normal' tables)"),
 dict(id=25, title="Түр нэвтрэх эрх олгосон / түр нэвтэрсэн автомашин", status="available",
      sql="""WITH guest AS (SELECT c.id, c.carId, c.createdAt FROM silver.parkly_carconfig c
                            JOIN silver.parkly_group g ON g.id = c.groupId WHERE g.name = 'Зочин'),
                  granted AS (SELECT {grain_createdAt} AS period, COUNT(DISTINCT carId) AS cars_granted
                              FROM guest WHERE createdAt >= '{start}' AND createdAt < '{end}' GROUP BY 1),
                  entered AS (SELECT {grain_inDate} AS period, COUNT(DISTINCT i.carId) AS cars_entered
                              FROM silver.parkly_inrecord i JOIN guest ON guest.id = i.carConfigId
                              WHERE i.inDate >= '{start}' AND i.inDate < '{end}' GROUP BY 1)
             SELECT COALESCE(granted.period, entered.period) AS period, granted.cars_granted, entered.cars_entered
             FROM granted FULL OUTER JOIN entered ON granted.period = entered.period ORDER BY 1""",
      note="Temporary = parkly access group 'Зочин' (guest). Granted = distinct cars given a guest registration (carConfig) in the period; "
           "entered = distinct cars whose entry (inRecord) used a guest registration."),
 dict(id=26, title="Нийт бүртгэгдсэн автомашин", status="available",
      sql="""SELECT COUNT(*) AS cars,
                    COUNT(DISTINCT uc.userId) AS owners,
                    ROUND(AVG(YEAR(CURRENT_DATE) - c.buildYear), 1) AS avg_age_years,
                    COUNT(DISTINCT c.markName) AS distinct_makes
             FROM silver.sma_usercars uc
             JOIN silver.sma_cars c ON c.id = uc.carId""",
      note="sma.Cars loaded 2026-10-09 WITHOUT plateNumber (Алхам 1); markName/modelName/buildYear are "
           "allowed with a CT015 waiver - a car's make is not a person's name. The join works because "
           "Cars.id and UserCars.carId share the carId token namespace (G18)."),
 dict(id=27, title="Жолоочийн хариуцлагын даатгалтай автомашин", status="unavailable", needs="an insurance table (none in any dump)"),
 dict(id=28, title="Тээврийн хэрэгслийн даатгалтай автомашин", status="unavailable", needs="an insurance table"),
 dict(id=29, title="Байнгын нэвтрэх эрхтэй автомашин / багтаамж", status="available",
      sql="""WITH perm AS (SELECT c.parkId, g.name AS access_group, c.carId
                           FROM silver.parkly_carconfig c JOIN silver.parkly_group g ON g.id = c.groupId
                           WHERE g.type = 'main' AND g.name <> 'Зочин'
                             AND c.active = 1 AND c.isDeleted = 0
                             AND (c.endDate IS NULL OR c.endDate >= current_date())),
                  cap AS (SELECT parkType, SUM(parkingSpaces) AS parking_spaces FROM silver.parkly_park GROUP BY 1)
             SELECT p.parkType, perm.access_group, COUNT(DISTINCT perm.carId) AS permanent_cars, cap.parking_spaces,
                    ROUND(100.0 * COUNT(DISTINCT perm.carId) / NULLIF(cap.parking_spaces, 0), 1) AS cars_pct_of_capacity
             FROM perm JOIN silver.parkly_park p ON p.id = perm.parkId JOIN cap ON cap.parkType = p.parkType
             GROUP BY 1, 2, 4 ORDER BY 1, 3 DESC""",
      note="Permanent right = an active, unexpired parkly.carConfig in an access group of type 'main' other than 'Зочин' (guest): "
           "Оршин суугч, Байгууллага, Ажилтан, Оюутан, Захирал, Гэрээт (groupId -> parkly.group, confirmed by the platform owner "
           "2026-10-21). Service vehicles (special) and guests are excluded. Shown per park type and access group against capacity."),
 dict(id=30, title="Гражид бүртгэгдсэн автомашин / гражийн тоо", status="unavailable", needs="garage<->car registration (not in sma/myproperty allowlists)"),
 dict(id=31, title="Эд хөрөнгийн даатгалтай сууц/граж/агуулах", status="unavailable", needs="an insurance table"),
 dict(id=32, title="Төлбөртэй AI туслах идэвхижүүлсэн хэрэглэгч", status="partial",
      sql="""SELECT COUNT(DISTINCT userId) AS ai_users, COUNT(*) AS ai_devices FROM silver.sma_aiinfos""",
      note="Users with an AI assistant profile; 'paid' needs the subscription product mapping (sma_subscriptionbills.priceInfoId -> product)."),
 dict(id=33, title="AI хүсэлтийн амжилтын хувь", status="unavailable", needs="an AI request log with outcome (not in sma dump)"),
 dict(id=34, title="AI зардал / орлого", status="unavailable", needs="AI cost data (not in any database)"),
 dict(id=35, title="Онлайн үйлчилгээ: хэрэглэгч / шимтгэл / гүйлгээ", status="partial",
      sql="""SELECT {grain_createdAt} AS period, productPaymentType, COUNT(DISTINCT userId) AS users, COUNT(*) AS invoices,
                    SUM(totalAmount) AS total_amount, SUM(feeAmount) AS fee_income
             FROM silver.smartpay_invoice WHERE createdAt >= '{start}' AND createdAt < '{end}' AND status IN ('paid','PAID','success','SUCCESS')
             GROUP BY 1,2 ORDER BY 1,2""",
      note="SmartPay invoices by product payment type; which types are 'online services' vs 'online shop' (KPI 36) must be confirmed."),
 dict(id=36, title="Онлайн дэлгүүр: хэрэглэгч / шимтгэл / гүйлгээ", status="partial", sql=None, note="See KPI 35 - same query, filter productPaymentType."),
 dict(id=37, title="Үл хөдлөх түрээсийн зарын тоо, хотхоноор", status="partial",
      sql="""SELECT type, propertyType, townId, stage, COUNT(*) AS listings, ROUND(AVG(price),0) AS avg_price
             FROM silver.sma_propertysalerents WHERE createdAt >= '{start}' AND createdAt < '{end}' GROUP BY 1,2,3,4 ORDER BY 5 DESC""",
      note="Grouped by town, not 'complex grade' (no such field)."),
 dict(id=38, title="Түрээсийн зуучлалын шимтгэлийн орлого", status="partial",
      sql="""SELECT period, SUM(direct_offers) AS direct_offers, SUM(direct_income) AS direct_income,
                    SUM(auction_bills) AS auction_bills, SUM(auction_income) AS auction_income,
                    SUM(direct_income) + SUM(auction_income) AS total_income
             FROM (
               SELECT {grain_paidAt} AS period, COUNT(*) AS direct_offers, SUM(price) AS direct_income, 0 AS auction_bills, 0 AS auction_income
               FROM silver.sma_directoffers WHERE paidAt >= '{start}' AND paidAt < '{end}' GROUP BY 1
               UNION ALL
               SELECT {grain_createdAt} AS period, 0, 0, COUNT(*), SUM(price)
               FROM silver.sma_auctionsubscriptionbills WHERE createdAt >= '{start}' AND createdAt < '{end}' AND lower(status) IN ('paid','success','completed','төлсөн') GROUP BY 1
             ) u GROUP BY period ORDER BY period""",
      note="Direct-offer payments plus paid auction subscription bills; the exact 'paid' status values must be confirmed with the sma team."),
 dict(id=39, title="Идэвхижүүлсэн релейний шимтгэлийн орлого", status="partial",
      sql="""SELECT {grain_createdAt} AS period, COUNT(*) AS subscriptions, COUNT(DISTINCT userId) AS users, SUM(price) AS income
             FROM silver.sma_iotsubscriptions WHERE createdAt >= '{start}' AND createdAt < '{end}' GROUP BY 1 ORDER BY 1""",
      note="IoT (relay) subscriptions by creation date; payment status column not allowlisted."),
 dict(id=40, title="Багцалсан төлбөрийн шимтгэлийн орлого", status="partial",
      sql="""SELECT {grain_createdAt} AS period, type, COUNT(*) AS transactions, SUM(amount) AS amount, SUM(spayFee) AS spay_fee, SUM(xpayFee) AS xpay_fee
             FROM silver.smartpay_transaction WHERE createdAt >= '{start}' AND createdAt < '{end}' GROUP BY 1,2 ORDER BY 1,2""",
      note="All SmartPay transaction fees by type; the 'bundled' type must be confirmed."),
 dict(id=41, title="Илгээсэн OTP мессэжний тоо", status="available",
      sql="""SELECT {grain_day} AS period, SUM(CAST(otp_sent AS BIGINT)) AS otp_sent
             FROM bronze_ref.sma_otp_daily
             WHERE day >= '{start}' AND day < '{end}'
             GROUP BY 1 ORDER BY 1""",
      note="Count-only (action 2.5, 2026-10-14): OTPs created per day = the difference of the sma.Otps "
           "id counter between consecutive nightly dumps (02:00 Ulaanbaatar to 02:00). No OTP row, code or "
           "phone number is read. Days with a missing dump are absent rather than estimated. History starts 2026-10-10."),
 dict(id=42, title="Эрх хязгаарлагдсан хэрэглэгч, өрийн дүн, насжилт", status="partial",
      sql="""WITH last AS (SELECT propertyId, paymentBalance,
                                  ROW_NUMBER() OVER (PARTITION BY propertyId ORDER BY id DESC) AS rn
                           FROM silver.esukh_balance),
                  mcost AS (SELECT propertyId, AVG(cost) AS avg_cost FROM silver.esukh_balance
                            WHERE cost > 0 AND to_date(CAST(invoiceMonth AS STRING), 'yyyyMM') >= add_months(current_date(), -12)
                            GROUP BY propertyId),
                  debt AS (SELECT l.propertyId, l.paymentBalance AS debt, l.paymentBalance / NULLIF(m.avg_cost, 0) AS months_owed
                           FROM last l LEFT JOIN mcost m USING (propertyId) WHERE l.rn = 1 AND l.paymentBalance > 0)
             SELECT CASE WHEN months_owed IS NULL THEN 'unknown' WHEN months_owed < 1 THEN '<1 month' WHEN months_owed < 3 THEN '1-3 months'
                         WHEN months_owed < 6 THEN '3-6 months' ELSE '6+ months' END AS debt_age,
                    COUNT(*) AS properties_in_debt, ROUND(SUM(debt), 2) AS total_debt, ROUND(AVG(debt), 2) AS avg_debt
             FROM debt GROUP BY 1 ORDER BY 1""",
      note="Debt = the LATEST balance row's paymentBalance per property (never a sum of rows, per the esukh report spec); "
           "age = debt / the property's average monthly invoice over the last 12 months. Access restriction cannot be shown: "
           "esukh.blackListProperty has 0 rows.", needs="esukh.blackListProperty records (restricted access)"),
 dict(id=43, title="Эрх хязгаарласнаар төлөгдсөн өрийн хувь", status="unavailable", needs="as KPI 42"),
 dict(id=44, title="Санал хүсэлт өгсөн хэрэглэгч (өдрөөр)", status="available",
      sql="""SELECT {grain_createdAt} AS period, COUNT(*) AS feedback_items, COUNT(DISTINCT userId) AS users
             FROM silver.esukh_userfeedback WHERE createdAt >= '{start}' AND createdAt < '{end}'
             GROUP BY 1 ORDER BY 1""",
      note="esukh.userFeedback (metadata only - the feedback text is never loaded)."),
 dict(id=45, title="Санал хүсэлтийн шийдвэрлэлтийн хувь (өдрөөр)", status="available",
      sql="""SELECT {grain_createdAt} AS period, COUNT(*) AS feedback_items,
                    SUM(CASE WHEN status = 'CLOSED' THEN 1 ELSE 0 END) AS closed,
                    ROUND(100.0 * SUM(CASE WHEN status = 'CLOSED' THEN 1 ELSE 0 END) / COUNT(*), 1) AS closed_pct
             FROM silver.esukh_userfeedback WHERE createdAt >= '{start}' AND createdAt < '{end}'
             GROUP BY 1 ORDER BY 1""",
      note="Closed = status CLOSED (by an admin or by the user). By the period the feedback was created."),
 dict(id=46, title="Апп алдааны мэдээллийн тоо", status="available",
      sql="""SELECT {grain_createdAt} AS period, COUNT(*) AS errors, COUNT(DISTINCT userId) AS users_affected
             FROM silver.sma_smaerrors WHERE createdAt >= '{start}' AND createdAt < '{end}' GROUP BY 1 ORDER BY 1"""),
 dict(id=47, title="Серверийн уналт / зогссон цаг", status="available",
      sql="""SELECT {grain_day} AS period, server,
                    ROUND(SUM(CAST(down_minutes AS DOUBLE)) / 60, 2) AS downtime_hours,
                    ROUND(AVG(CAST(up_ratio AS DOUBLE)) * 100, 3) AS uptime_pct
             FROM bronze_ref.monitoring_downtime_daily
             WHERE day >= '{start}' AND day < '{end}'
             GROUP BY 1, 2 ORDER BY 1, 2""",
      note="Action 7.1 (2026-10-14): from the central Prometheus, minutes per Ulaanbaatar day each server's "
           "node exporter was unreachable. Prometheus keeps 30 days; history is kept from 2026-09-14 on."),
 dict(id=48, title="Нийт групп / хэрэглэгчийн үүсгэсэн групп", status="partial",
      sql="""SELECT status, COUNT(*) AS groups, SUM(CASE WHEN createdUserId IS NOT NULL THEN 1 ELSE 0 END) AS created_by_users
             FROM silver.esukh_group WHERE isDeleted = 0 GROUP BY 1 ORDER BY 1""",
      note="esukh.group (PUBLIC / PRIVATE). Whether these are the Smart Mongol app groups the KPI means is not confirmed."),
 dict(id=49, title="Идэвхтэй групп", status="partial",
      sql="""SELECT {grain_updatedAt} AS period, COUNT(*) AS active_groups
             FROM silver.esukh_group WHERE isDeleted = 0 AND updatedAt >= '{start}' AND updatedAt < '{end}'
             GROUP BY 1 ORDER BY 1""",
      note="Active = a group changed (updatedAt) in the period; esukh.group has no activity log. Same caveat as KPI 48."),
 dict(id=50, title="Групп доторх нэхэмжлэх", status="unavailable", needs="group tables"),
 dict(id=51, title="Төлбөрийн картаа холбосон хэрэглэгч", status="available",
      sql="""SELECT COUNT(DISTINCT userId) AS users_with_card, COUNT(*) AS cards, SUM(CASE WHEN approved THEN 1 ELSE 0 END) AS approved_cards
             FROM silver.smartpay_card"""),
 dict(id=52, title="Зогсоолын төлбөрөө төлсөн хэрэглэгч", status="partial",
      sql="""SELECT period, CAST(distinct_cars AS BIGINT) AS cars_paid, CAST(payments AS BIGINT) AS payments,
                    CAST(paid_amount AS DOUBLE) AS paid_amount
             FROM bronze_ref.parkly_payment_daily
             WHERE grain = 'month' AND payment_type = 'paid' AND success = 'true'
               AND period >= substr('{start}', 1, 7) AND period < substr('{end}', 1, 7)
             ORDER BY 1""",
      note="Aggregate-only (action 5.1, 2026-10-14): computed inside the parkly database, no payment row "
           "leaves it; groups under 5 cars are blanked. The payer is a car (parkly has no user on a payment), "
           "so this counts distinct cars that paid, per month. Counts payment_type 'paid' with success; "
           "the parkly team must confirm whether 'split' and 'full' also mean a paid fee.",
      needs="parkly team: confirm which payment_type values mean a paid parking fee"),
 dict(id=53, title="Лояалти оноо үүсгэсэн бизнес", status="unavailable", needs="loyalty tables (none in any dump)"),
 dict(id=54, title="Лояалти онооны нийлбэр", status="unavailable", needs="loyalty tables"),
 dict(id=55, title="Лояалти QR үүсгэсэн хэрэглэгч", status="unavailable", needs="loyalty tables"),
 dict(id=56, title="Лояалти QR-аар нэвтэрсэн тохиолдол", status="unavailable", needs="loyalty tables"),
 dict(id=57, title="API latency", status="available",
      sql="""SELECT {grain_day} AS period, target,
                    ROUND(AVG(CAST(avg_ms AS DOUBLE))) AS avg_ms, MAX(CAST(p95_ms AS DOUBLE)) AS p95_ms,
                    ROUND(AVG(CAST(success_ratio AS DOUBLE)) * 100, 2) AS success_pct
             FROM bronze_ref.api_latency_daily
             WHERE day >= '{start}' AND day < '{end}'
             GROUP BY 1, 2 ORDER BY 1, 2""",
      note="Action 7.2 (2026-10-14): blackbox HTTP probes every minute from the central monitoring server to "
           "the public endpoints (api.esukh.mn, spay.esukh.mn, sites, MCP). Response time as a user sees it, not "
           "server-side processing time. Data from 2026-10-15; the sma app API URL is not probed yet."),
 dict(id=58, title="AppStore / PlayStore үнэлгээ", status="unavailable", needs="store consoles, not a database"),
]

BY_ID = {k["id"]: k for k in KPIS}
