"""Build datasets.json - the ONLY data the hardened MCP server can query (2026-10-14).

The server no longer accepts SQL. An analyst picks a dataset, metrics, group-by
fields, filters and a date range; the server builds the SQL from this allowlist.

Inputs: data_dictionary.json (tables, columns, meanings), ../../jobs/transform_rules.csv
(token / time_band / passthrough / drop per column), the validator's forbidden-name
vocabularies (identity, free text, credentials, banding).

Field roles:
  dimension       group by and filter on it (categories, org-level ids, flags)
  measure         sum / avg / min / max (amounts, areas, counts held in a column)
  date            filter by range, group by day / week / month / year
  count_distinct  person/vehicle/card tokens - ONLY counted, never shown or grouped
Anything else is excluded and listed in datasets_excluded.json with the reason.

Run: python3 build_datasets.py   (then rebuild the image)
"""
import csv, glob, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
JOBS = os.path.join(HERE, "..", "..", "jobs")
sys.path.insert(0, JOBS)
import validate_control_table as V  # noqa: E402  (forbidden-name vocabularies)

# Curated datasets: every table a KPI reads, plus the core esukh billing tables.
# Add a table here deliberately; nothing is exposed by default.
DATASETS = [
    "myproperty_building", "myproperty_invoice", "myproperty_invoicepayment", "myproperty_owner",
    "myproperty_payment", "myproperty_rentalagreement", "myproperty_room", "myproperty_tenant",
    "parkly_park", "parkly_parkaccessconfig",
    "sma_aiinfos", "sma_auctionsubscriptionbills", "sma_cars", "sma_directoffers", "sma_iotsubscriptions",
    "sma_propertysalerents", "sma_smaerrors", "sma_useractionlogs", "sma_usercars", "sma_users",
    "smartpay_card", "smartpay_invoice", "smartpay_transaction",
    "esukh_balance", "esukh_monthlypayment", "esukh_branch",
    # Added 2026-10-21 at the platform owner's request (KPI 21, 29, 30, 42, 48, 49, 52):
    "esukh_property", "esukh_userproperty", "esukh_group", "esukh_userbarrier",
    "parkly_carconfig", "parkly_inrecord", "parkly_payments", "parkly_group",
    "esukh_userfeedback",   # KPI 44, 45 (metadata only)
]
K_MIN = 5  # small-cell suppression threshold, enforced by the server
UNIT_DATASETS = {"myproperty_room", "myproperty_building", "parkly_park", "parkly_parkaccessconfig",
                 "esukh_branch", "sma_cars", "esukh_property"}

# Never queryable even if a rule says passthrough: quasi-identifiers, locations,
# network/device ids, account numbers and un-banded login times (review 2026-10-14).
EXCLUDE = re.compile(r"(plate|^ip$|ip$|^lat$|^lng$|^lon$|latitude|longitude|acnt|accountno|accountnumber|iban|"
                     r"door|^floor$|familycount|propertyno|roomno|lastlogged|imei|serial|^sn$|mac$|"
                     r"address|town$|khoroo|committee|apartmentname|lastname|firstname|^location$)", re.I)
# Ids that may be GROUPED BY: organisation / catalogue level only. Any other id
# (property, apartment, room, contract, invoice, payment, car, card ...) points at
# a household, a person's record or a transaction: grouping by it would print
# one household's history, which small-cell suppression does not prevent. Those
# are offered as count_distinct only.
ORG_ID = re.compile(r"^(branch|building|block|park|parentpark|bank|town|service|module|method|paymentgroup|"
                    r"group|category|product|producttype|merchant|pricing|priceinfo|priceinfomethod|state(bank)?)(_?id)$", re.I)
CATEGORY = re.compile(r"(type|status|kind|code|flag|method|mode|stage|level|state)$", re.I)
STALE = re.compile(r"(withdrawn|not on the .{0,20}allowlist|old values|holds? stale)", re.I)
PERSONISH = re.compile(r"(user|owner|tenant|worker|admin|agent|actor|member|customer|driver|"
                       r"assigned|created|updated|performed|applied|reversed|terminated|activated|changed|approved|by$)", re.I)
MEASURE = re.compile(r"(amount|price|fee|total|balance|area|count|sum|quota|percent|cost|pay|paid|rate|"
                     r"capacity|spaces|perma|temp|limit|year|floors|duration|seconds|minutes|days|qty|quantity)", re.I)
NUMERIC = re.compile(r"^(tinyint|smallint|int|integer|bigint|decimal|double|float|long|short|byte)", re.I)
DATE = re.compile(r"^(timestamp|date)", re.I)
INTERNAL = re.compile(r"(report|document|DDL|classified|\bRed\b|\bD\d+\b|KPI|withdrawn|team|source[- ]fix|per the|\.md\b|\.csv\b|\.py\b|claude|\bG\d\d?\b|PENDING|CT\d{3}|waiv|allowlist|bronze|silver|dump|"
                      r"migration|Алхам|alkham|stale|reload|review|§|section|token namespace|namespace|not a real|"
                      r"raw |docs/|jobs/|control table|transform rule|data officer|data-officer|tokeni[sz]ed in|"
                      r"pre-fix|orphan|BI-visible)", re.I)


def clean(text, limit=220):
    """Keep only plain business meaning: drop any sentence that refers to internal
    files, review notes, layers or pipeline mechanics."""
    if not text:
        return None
    text = re.sub(r"\s*\([^()]*\)", lambda m: "" if INTERNAL.search(m.group(0)) else m.group(0), text)
    keep = [s.strip() for s in re.split(r"(?<=[.;])\s+", text) if s.strip() and not INTERNAL.search(s)]
    out = " ".join(keep).strip()
    return (out[: limit - 1] + "…") if len(out) > limit else (out or None)


def forbidden(col):
    for vocab, why in ((V.IDENTITY_PATTERNS, "identity"), (V.FREE_TEXT_PATTERNS, "free text"),
                       (V.CREDENTIAL_PATTERNS, "credential"), (V.BANDING_PATTERNS, "needs banding")):
        if V._forbidden_hits(col, vocab):
            return why
    if col.lower().endswith("pass") or "signature" in col.lower():
        return "credential"
    return None


rules = {}
for r in csv.DictReader(open(os.path.join(JOBS, "transform_rules.csv"), encoding="utf-8")):
    rules[(f"{r['source_system']}_{r['source_table']}".lower(), r["column"])] = r["treatment"]

# Today's owner allowlists (2026-10-14). Silver keeps columns an owner later withdrew
# (MERGE never drops a column), so a field is served only if its source column is
# still allowlisted - independent of how a dictionary note happens to be worded.
ALLOW = {}
for f in glob.glob(os.path.join(JOBS, "control_table_*_phase1.csv")):
    for r in csv.DictReader(open(f, encoding="utf-8")):
        ALLOW[f"{r['source_system']}_{r['source_table']}".lower()] = set(r["columns_allowlist"].split("|"))

dd = json.load(open(os.path.join(HERE, "data_dictionary.json"), encoding="utf-8"))
out, excluded = {}, {}
for name in DATASETS:
    t = dd["tables"].get(f"silver.{name}")
    if not t:
        print(f"  missing from dictionary, skipped: {name}"); continue
    fields, gone = {}, {}
    for c in t["columns"]:
        col, ty = c["name"], c["type"]
        treat = rules.get((name, col))
        lc = col.lower()
        why = None
        if col.startswith("_"):
            why = "platform metadata"
        elif name in ALLOW and col not in ALLOW[name]:
            why = "not in the owner's current allowlist (withdrawn)"
        elif treat == "drop":
            why = "dropped in silver"
        elif lc == "id" and treat != "token":
            why = "row key - use the count metric"
        elif (w := forbidden(col)):
            why = w
        elif EXCLUDE.search(col):
            why = "quasi-identifier, location or device id"
        elif STALE.search(c.get("meaning") or ""):
            why = "withdrawn column, stale values only"
        if why:
            gone[col] = why; continue
        if treat == "token" or (ty == "string" and lc.endswith("id") and treat != "passthrough"):
            role = "count_distinct"
        elif treat == "time_band" or DATE.match(ty):
            role = "date"
        elif treat == "passthrough" and CATEGORY.search(col):
            # A category that merely contains a person word (ownerType, workerStatus ...):
            # its rule says passthrough, so it is a code, not a person (2026-10-21).
            role = "dimension"
        elif NUMERIC.match(ty) and lc.endswith("id") and PERSONISH.search(col[:-2]):
            gone[col] = "person id stored without a token"; continue
        elif NUMERIC.match(ty) and PERSONISH.search(col) and not MEASURE.search(col):
            gone[col] = "person reference stored without a token"; continue
        elif lc.endswith("id") and not ORG_ID.match(col):
            role = "count_distinct"
        elif NUMERIC.match(ty) and MEASURE.search(col) and not lc.endswith("id") and not CATEGORY.search(col):
            role = "measure"
        else:
            role = "dimension"
        f = {"type": ty, "role": role}
        if lc == "id" and role == "count_distinct":
            # A person table's own key, tokenised into the namespace its foreign keys use
            # (e.g. sma_users.id = the userId token in sma_useractionlogs, sma_usercars ...).
            f["description"] = "Person token (the userId other tables of this system carry) - count only"
        elif (d := clean(c.get("meaning"), 160)):
            f["description"] = d
        fields[col] = f
    # The person a row belongs to: groups must hold >= K_MIN distinct of these, not
    # only >= K_MIN rows (five invoices of one owner are still one owner).
    # Rows of UNIT_DATASETS describe a unit (room, building), not a person's record.
    person = []
    if name not in UNIT_DATASETS:
        for pat in (r"^(user|tenant|owner|customer|member|payer)(_?id)$", r"^(property|household)(_?id)$", r"^apartment_?id$",
                    r"^car_?id$"):
            person = [f for f, v in fields.items() if v["role"] == "count_distinct" and re.search(pat, f, re.I)]
            if person:
                break
    out[name] = {"system": name.split("_", 1)[0], **({"person_fields": person} if person else {}),
                 **({"description": d} if (d := clean(t.get("description"))) else {}),
                 "fields": fields}
    excluded[name] = gone

json.dump({"k_min": K_MIN, "datasets": out}, open(os.path.join(HERE, "datasets.json"), "w", encoding="utf-8"),
          ensure_ascii=False, indent=1)
json.dump(excluded, open(os.path.join(HERE, "datasets_excluded.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
roles = {}
for d in out.values():
    for f in d["fields"].values():
        roles[f["role"]] = roles.get(f["role"], 0) + 1
print(f"{len(out)} datasets, {sum(len(d['fields']) for d in out.values())} fields {roles}, "
      f"{sum(len(g) for g in excluded.values())} excluded")

# Public KPI records: same cleaning, no internal request numbers or file references.
sys.path.insert(0, os.path.join(HERE, ".."))
import kpis as K  # noqa: E402
defs = {k["id"]: k for k in json.load(open(os.path.join(HERE, "kpi_definitions.json"), encoding="utf-8"))["kpis"]}
pub = []
for k in K.KPIS:
    d = defs.get(k["id"], {})
    srcs = sorted({x for x in re.findall(r"\bsilver\.(\w+)", k.get("sql") or "")})
    rec = {"id": k["id"], "title": k["title"], "status": k["status"],
           "definition_mn": d.get("definition_mn"), "definition_en": d.get("definition_en"),
           "how_computed": clean(d.get("how_computed"), 300), "datasets": srcs,
           "caveat": clean(k.get("note"), 300),
           "missing_data": clean(k.get("needs"), 200) if k["status"] != "available" else None}
    pub.append({a: b for a, b in rec.items() if b})
json.dump({"kpis": pub}, open(os.path.join(HERE, "kpi_public.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
leaky = [p["id"] for p in pub if any(INTERNAL.search(str(v)) for k2, v in p.items() if k2 not in ("title", "definition_mn"))]
print(f"{len(pub)} public KPI records; still internal-looking: {leaky}")
