"""Build kpi_definitions.json from the KPI PDF text + hand-written English
definitions and computation notes. Run once; the JSON is what the server reads."""
import json, re, sys
pdf = open("/home/developer/hti-platform/docs/kpi_extracted.txt", encoding="utf-8").read()
body = pdf.split("үзүүлэлтүүд:", 1)[1]
mn = {}
for m in re.finditer(r"(?ms)^\s*(\d{1,2})\.\s+(.*?)(?=^\s*\d{1,2}\.\s|\Z)", body):
    mn[int(m.group(1))] = " ".join(m.group(2).split())
assert len(mn) == 58, len(mn)

EN = {
 1: "Total number of registered Smart Mongol app users.",
 2: "Number and share of active users (users with any app activity in the period ÷ all registered users).",
 3: "Share of active users who hit no app error in the period.",
 4: "New user registrations, by day / week / month.",
 5: "Users verified through DAN (the national e-ID), and its growth by day / week / month.",
 6: "SMA app users not registered with any apartment-owners association (СӨХ), and its growth.",
 7: "Total number of apartments (units), and its growth by day / week / month.",
 8: "Apartments by complex grade (expensive / average / cheap) and by floor area.",
 9: "Total number of garages, and its growth by day / week / month.",
 10: "Garages by complex grade (expensive / average / cheap) and by floor area.",
 11: "Total number of storage units (агуулах), and its growth by day / week / month.",
 12: "Storage units by complex grade (expensive / average / cheap) and by floor area.",
 13: "Invoices issued: count, total amount and average amount.",
 14: "Invoice ageing: share paid within 1, 3 and 6 months of issue.",
 15: "Invoices created by SMA users themselves: count, total and average amount.",
 16: "Invoices paid through the Smart Mongol app: count, total and average amount.",
 17: "Users who set up invoice auto-pay in the Smart Mongol app.",
 18: "Ageing of invoices paid through the app: paid within 1, 3 and 6 months.",
 19: "Number of tenants, and its growth by day / week / month.",
 20: "Tenant movement pattern: how long a unit/garage is rented, and whether tenants later become owners or rent elsewhere.",
 21: "Number of ownership changes, by day / week / month.",
 22: "New-owner profile: which complex and how many rooms they lived in before.",
 23: "Previous-owner profile: which complex they were registered in.",
 24: "Users granted temporary entry to a complex / users who actually entered temporarily.",
 25: "Cars granted temporary entry to a complex / cars that actually entered temporarily.",
 26: "Total registered cars, by age and by make/model.",
 27: "Cars with driver liability insurance, and the premium income.",
 28: "Cars with vehicle insurance, and the premium income.",
 29: "Cars with permanent entry rights to a complex, as a ratio of the complex's parking capacity.",
 30: "Cars permanently registered to a garage, as a ratio of the number of garages.",
 31: "Apartments, garages and storage units with property insurance, and the premium income.",
 32: "Users who activated the paid AI assistant.",
 33: "Share of AI assistant requests completed successfully.",
 34: "AI cost to AI revenue ratio.",
 35: "Online services: users served, fee income and total transaction amount.",
 36: "Online shop: users served, fee income and total transaction amount.",
 37: "Real-estate rental listings, by complex grade.",
 38: "Rental brokerage fee income.",
 39: "Fee income from activated relays (IoT gate/door relays).",
 40: "Fee income from bundled payments.",
 41: "OTP SMS messages sent, by day and month.",
 42: "Users with restricted access, their debt amount and debt ageing.",
 43: "Debt paid because access was restricted, as a share of total debt.",
 44: "Users who submitted feedback, by day.",
 45: "Feedback resolution rate, by day.",
 46: "Number of app error reports.",
 47: "Server outages and downtime hours.",
 48: "Total groups / groups created by users.",
 49: "Active groups.",
 50: "Invoices created inside groups: count and amount.",
 51: "Users who linked a payment card.",
 52: "Users who paid their parking fee.",
 53: "Businesses that issued loyalty points.",
 54: "Total loyalty points.",
 55: "Users who generated a loyalty QR code.",
 56: "Building entries via loyalty QR: number of entries / number of users.",
 57: "API latency (response speed).",
 58: "User ratings on the App Store and Play Store.",
}
HOW = {
 5: "COUNT of sma_users by danVerifiedAt (DAN verification time) truncated to the grain.",
 1: "COUNT(*) of sma_users. Every registered user: sma.Users has no active/status column.",
 2: "Distinct userId in sma_useractionlogs within the period ÷ COUNT(*) of sma_users.",
 3: "Active users (as KPI 2) minus those with any row in sma_smaerrors in the period, ÷ active users.",
 4: "COUNT(*) of sma_users grouped by createdAt truncated to the grain.",







 14: "First payment date per invoice (invoicepayment → payment.paymentDate) minus issueDate, bucketed ≤30 / ≤90 / ≤180 days; unpaid counted separately.",
 15: "myproperty_invoice by type and payerType. Which value means 'created by the SMA user' is not yet confirmed.",
 16: "myproperty_payment by method. Which method value is the app is not yet confirmed.",
 18: "As KPI 14, split by payment method.",
 19: "New myproperty_tenant rows by createdAt and grain.",
 20: "Average rental length from myproperty_rentalagreement; tenants who also appear as owners (same userId token); rooms per tenant.",

 26: "sma_usercars joined to sma_cars: cars, distinct owners, average age from buildYear, distinct makes.",

 32: "Distinct userId in sma_aiinfos. Cannot yet tell paid from free.",
 35: "Paid smartpay_invoice rows by productPaymentType: distinct users, count, totalAmount, feeAmount.",
 36: "The KPI 35 query filtered to the online-shop productPaymentType (value not yet confirmed).",
 37: "sma_propertysalerents by type, propertyType, townId and stage: count and average price.",
 38: "Paid sma_directoffers (by paidAt) plus paid sma_auctionsubscriptionbills (by createdAt): counts and income.",
 39: "sma_iotsubscriptions by createdAt: count, distinct users, SUM(price). Payment status is not available.",
 40: "smartpay_transaction by type: amount, spayFee, xpayFee. Which type is 'bundled' is not yet confirmed.",
 46: "sma_smaerrors by createdAt: errors and distinct users affected.",
 41: "Daily OTPs created = difference of the sma.Otps id counter between consecutive nightly snapshots, summed per period; only the counter is read, never an OTP, code or phone number.",
 47: "Minutes per day each server was unreachable, from central monitoring (Prometheus up of every server); summed to hours per period.",
 51: "smartpay_card: distinct userId, cards, approved cards.",
 57: "Response time of the public endpoints from blackbox HTTP probes every minute: average, 95th percentile and success rate per day.",
 52: "Distinct cars with a successful 'paid' parking payment per month, aggregated inside the parkly database (groups under 5 cars blanked).",
}
UNLOCK = {  # docs/KPI_UNLOCK_REQUESTS_2026-10-06.md row -> KPIs




 24: "Request 7: parkly team to classify the access (entry log) table.",

 32: "Request 3: sma team to provide the priceInfo / product lookup.",
 37: "Request 8 (complex_grade).",
 39: "Request 4: sma team to confirm how an IoT subscription's payment is recorded.",
}
out = []
sys.path.insert(0, "/home/developer/hti-platform/mcp")
import kpis as K
for k in K.KPIS:
    i = k["id"]
    tables = sorted(set(re.findall(r"\b((?:silver|bronze_ref)\.\w+)", k.get("sql") or "")))
    d = {"id": i, "title": k["title"], "status": k["status"],
         "definition_mn": mn[i], "definition_en": EN[i],
         "how_computed": HOW.get(i), "source_tables": tables,
         "caveat": k.get("note"), "missing": k.get("needs"), "unlock": UNLOCK.get(i)}
    out.append({a: b for a, b in d.items() if b})
json.dump({"source": "docs/Смарт Монгол туслах app KPI.pdf (wording), mcp/kpis.py (status, SQL), docs/KPI_UNLOCK_REQUESTS_2026-10-06.md (unlock)",
           "generated": "2026-10-14", "kpis": out},
          open("/home/developer/hti-platform/mcp/catalog/kpi_definitions.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(out), "kpis;", sum(1 for o in out if "how_computed" in o), "with how_computed;", sum(1 for o in out if o["status"]!="unavailable" and "how_computed" not in o), "computable without how")
