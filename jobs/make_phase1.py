#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/make_phase1.py                                    NEW FILE
#
# Builds, for one source system:
#   jobs/control_table_<sys>_phase1.csv             (+ _exceptions.csv header)
#   rows in jobs/transform_rules.csv                (replacing that system's rows)
#
# "Phase 1" = the system's full control table (or a named subset) with
# purpose_ref set to a PROVISIONAL marker, so the loader will run, plus a
# treatment rule for EVERY allowlisted column, so tokenize_silver.py will run.
# Nothing it writes is a data-officer approval and every row says so.
#
# Written 2026-10-04 because the 10-02 generator lived in a scratchpad and was
# lost; regenerating rules by hand for 1,396 columns is how mistakes get in.
#
# Treatment logic (first match wins). It consults the column's declared type
# from <sys>_schema.sql, because a name alone misleads: permaCar is an int limit
# (passthrough), plateNumber is text (token).
#   own primary key                               -> passthrough
#   address / bare error / query / stacktrace     -> drop   (no coarsening here)
#   card data: *pan, maskedpan, expdate, expiry   -> drop   (no analytical value; PCI)
#   count/amount/fee/limit... AND numeric, not *Id -> passthrough
#   ends in at/date/time AND a temporal TYPE      -> time_band (a string "date" is not)
#   person/vehicle/dwelling word AND ends in Id   -> token
#   plate/device/card/account/tin/*By/router user -> token
#   person word AND text type                     -> token
#   numeric                                       -> passthrough
#   anything else                                 -> passthrough
# Fail-safe direction is token: over-tokenising a surrogate FK costs nothing
# (same value -> same token within a system, so joins still work); passing a
# person identifier through is unrecoverable once it reaches silver.
#
# Usage:
#   python3 jobs/make_phase1.py --system parkly
#   python3 jobs/make_phase1.py --system sma --only AdminLogins UserCars ...
#   python3 jobs/make_phase1.py --system smartpay --columns-doc docs/smartpay_models_columns_safe.md
#   python3 jobs/make_phase1.py --system esukh --from-phase1     # re-derive rules/layers, keep allowlists
#   python3 jobs/make_phase1.py --system esukh --columns-doc docs/esukh_review_extracted.txt \
#       --exclude user.image worker.image roomimage.image cost.costimage coupon.image electricpayed.image user.validateCode \
#       --include module.name method.name service.name   # lookup labels, waived 10-02 (not person names)
#   (2026-10-06: the returned esukh review .docx predates the photo/credential rules, so
#    those columns are removed by hand; branch logos, imageType labels and town images stay.)
#
# --columns-doc: a source team's "safe columns" markdown ("### tableName: x" +
# "- column" lists). Tables become the doc's tables that exist in our dump, and
# each allowlist becomes the doc's columns that exist in our dump. Columns the
# doc keeps but our validator rejects (e.g. a reference table's `name`) get an
# exceptions row citing the document, so the team's reasoning is on record and
# the data officer sees exactly what was waived and why.
#
# target_layer (added 2026-10-06): a table whose columns need NO token and NO
# drop treatment holds no personal data -> `bronze-ref` (non-PII reference
# layer, not vacuumed, visible to BI). Anything with a person/vehicle token or a
# dropped column -> `bronze` (PII, <=24h). This is what section 2's layer table
# always said; until now every phase-1 row was `bronze`.
# =============================================================================
from __future__ import annotations
import argparse, csv, re, collections, sys
from pathlib import Path

# A table whose every ROW IS a person, a staff member or a vehicle. Its own
# primary key is therefore an identifier of that entity, not a harmless
# surrogate, and `treat()` would otherwise pass it straight through because of
# the "own primary key -> passthrough" rule - leaving the source system's real
# user id in the lake, and (for a table with no other token) routing the table
# to bronze-ref, which is never vacuumed and is visible to BI.
#
# The value is the token NAMESPACE to mint in, deliberately the same name the
# foreign keys pointing at this table already use (checked against the live
# token map on 2026-10-08: esukh userId=115,543 tokens, sma userId=43,934,
# sma carId=38,222 ...). Same namespace + same natural value = same token, so
# Users.id joins to UserCars.userId and NO existing token changes.
PERSON_ROW_PK: dict[tuple[str, str], str] = {
    ("esukh",      "user"):   "userId",
    ("esukh",      "worker"): "workerId",
    ("myproperty", "owner"):  "ownerId",
    ("myproperty", "tenant"): "tenantId",
    ("myproperty", "room"):   "roomId",     # added 2026-10-14 (action 1.5): a dwelling, joins roomId FKs
    ("sma",        "Users"):  "userId",
    ("sma",        "Cars"):   "carId",
}

# Columns `treat()` tokenises because a PERSON word appears in the name, but
# which hold a BUSINESS CATEGORY, a config value or a counter. Tokenising one is
# not a privacy win - it is silent data loss: the value becomes a UUID and the
# KPI that grouped by it can no longer be computed. Each was checked against the
# live token map and the column's declared type on 2026-10-08:
#
#   smartpay merchant.userFeeType      varchar(10) 'PERCENT' - natural values in
#                                      the map were literally FIXED and 0
#   myproperty owner.ownershipType     varchar(20) 'FULL'  - 1 distinct value
#   esukh propertyjoinrequest.ownerType varchar(30)        - 4 distinct values
#   esukh branch.appCarTypes           varchar(145)        - list of car types
#   parkly compare.device              varchar(15)         - device kind
#   parkly camera.templateId           integer             - config template
#   parkly camera_health_log.processedPlates integer DEFAULT 0 - A COUNTER
#   myproperty meter.contractRoomServiceId integer         - service link
#
# "...Type" and "...Types" are the giveaway: a type is a category OF a thing,
# never the thing. Add here only after checking the declared type and the
# distinct values - the fail-safe direction remains token.
NOT_A_PERSON: set[tuple[str, str, str]] = {
    # 2026-10-14: esukh `room` is a bookable facility (hall/gym, hourPrice), not a dwelling.
    ("esukh", "roomorder", "roomId"), ("esukh", "roomimage", "roomId"),
    ("smartpay",   "merchant",          "userFeeType"),
    ("myproperty", "owner",             "ownershipType"),
    ("esukh",      "propertyjoinrequest", "ownerType"),
    ("esukh",      "branch",            "appCarTypes"),
    ("parkly",     "compare",           "device"),
    ("parkly",     "camera",            "templateId"),
    ("parkly",     "camera_health_log", "processedPlates"),
    ("myproperty", "meter",             "contractRoomServiceId"),
}

PURPOSE  = "PENDING-REVIEW-2026-10"
APPROVED = "PROVISIONAL - generated by jobs/make_phase1.py, NOT a data-officer approval"

NUMERIC = re.compile(r"^(int|bigint|smallint|tinyint|integer|numeric|decimal|double|float|real|boolean|bool|serial)")
TIME    = re.compile(r"(at|date|time|timestamp)$")
# room/contractRoom = one household's dwelling -> quasi-identifier, tokenised.
# building/block/floor are shared by many households and stay passthrough so KPIs
# can group by complex (decided 2026-10-06; the 10-02 rules tokenised all four).
PERSON  = re.compile(r"(user|worker|owner|tenant|customer|merchant|agent|resident|driver|actor|subject|booker|car(?!config)|vehicle|room(?!count|type)|contractroom)", re.I)
IDENT   = re.compile(r"(plate|vehicle|imei|device|card|account|tin$|routeruser|^user$|^owner$|createdby|updatedby|approvedby|completedby|cancelledby|confirmedby)", re.I)
COUNT   = re.compile(r"(count|total|max_|min_|active_|limit|amount|fee|percent|price|sum|quota|balance|perma|temp)", re.I)
DROP    = re.compile(r"(address|^error$|^query$|^stacktrace$|pan$|maskedpan|expdate|expiry|cvv|cvc)", re.I)
# ADDED 2026-10-14: credentials. Before this, camera.pass, camera.*Signature and
# routerConfig.routerPass/anydeskPass fell through to "anything else -> passthrough"
# and plaintext device passwords reached silver and the MCP server.
CREDENTIAL = re.compile(r"(^pass$|pass$|password|passwd|pwd|secret|signature$|apikey|api_key|privatekey|accesskey"
                        r"|(access|refresh|auth|api|bearer|session)_?token$|hash$|salt$|^otp$|otpcode|pincode|^pin$)", re.I)
# Only genuine timestamp/date types may be banded. A string that merely ends in
# "date" (card expiry "12/27", free-form "Date" fields) cast to timestamp yields
# nulls or pre-1582 garbage, and Spark refuses to write the latter
# (WRITE_ANCIENT_DATETIME) - smartpay.card failed exactly this way on 2026-10-04.
TEMPORAL = re.compile(r"^(timestamp|datetime|date|time)")

def coltypes(schema: Path) -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = collections.defaultdict(dict); cur = None
    for line in schema.open(encoding="utf-8", errors="replace"):
        m = (re.match(r'^CREATE TABLE `([^`]+)`', line) or re.match(r'^CREATE TABLE (?:[\w.]+\.)?"([^"]+)"', line)
             or re.match(r'^CREATE TABLE (?:[\w]+\.)?(\w+)\s*\(', line))
        if m: cur = m.group(1); continue
        if cur is None: continue
        if line.startswith(")"): cur = None; continue
        if re.match(r"^\s+(PRIMARY|UNIQUE|KEY|CONSTRAINT|INDEX|FULLTEXT|SPATIAL|CHECK|FOREIGN)\b", line, re.I): continue
        mc = (re.match(r'^\s+`([^`]+)`\s+(\S+)', line) or re.match(r'^\s+"([^"]+)"\s+(\S+)', line)
              or re.match(r'^\s+(\w+)\s+(\S+)', line))
        if mc: out[cur][mc.group(1)] = mc.group(2).lower()
    return out

def treat(col: str, ty: str | None, pk: str, person_pk: str = "",
          not_a_person: bool = False) -> tuple[str, str]:
    n = col.lower().replace("_", ""); ty = ty or ""
    if CREDENTIAL.search(col) and col != pk:          return "drop", "Credential (password, secret, signature, key or hash) - never copied to the lake"
    if not_a_person and col != pk:
                                                       return ("passthrough", "Business category, config value or counter - the person word in its name is incidental (see NOT_A_PERSON)")
    if col == pk and person_pk:                        return "token", f"Primary key of a table whose rows ARE people/vehicles - tokenised into the '{person_pk}' namespace so it matches the foreign keys pointing here"
    if col == pk:                                      return "passthrough", "Surrogate row key of this table, not a person identifier"
    if DROP.search(col):                               return "drop", "Address or free text that cannot be coarsened in this phase - dropped (location grouping is a later transform)"
    if COUNT.search(col) and NUMERIC.match(ty) and not n.endswith("id"):
                                                       return "passthrough", "Business value with no identifying content"
    if TIME.search(n) and TEMPORAL.match(ty):          return "time_band", "Exact timestamp is a quasi-identifier - truncated to the hour"
    if PERSON.search(col) and n.endswith("id"):        return "token", "Identifies a person, vehicle or dwelling - UUID via the token map, per system"
    if IDENT.search(col) or (PERSON.search(col) and not NUMERIC.match(ty)):
                                                       return "token", "Identifies a person, vehicle or dwelling - UUID via the token map, per system"
    if NUMERIC.match(ty):                              return "passthrough", "Business value with no identifying content"
    return "passthrough", "Organisation/config identifier or business value - not identifying"

def parse_columns_doc(path: Path) -> dict[str, list[str]]:
    """Two formats: SmartPay markdown ("### tableName: x" + "- col" lines) and the
    text extracted from a returned data-copy-review .docx ("table   (N columns)"
    followed by one comma-separated line of columns)."""
    out: dict[str, list[str]] = {}; cur = None; expect_csv = False
    for line in path.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^### tableName:\s*(\S+)", line)
        if m: cur = m.group(1); out[cur] = []; expect_csv = False; continue
        if line.startswith("## ") and "Хавсралт" in line: cur = None   # appendix = removed columns
        m2 = re.match(r"^(\w+)\s+\((\d+) columns?\)\s*$", line)
        if m2: cur = m2.group(1); out[cur] = []; expect_csv = True; continue
        if cur and expect_csv:
            out[cur] = [c.strip() for c in line.split(",") if c.strip()]; cur = None; expect_csv = False; continue
        if cur and re.match(r"^- \S+$", line): out[cur].append(line[2:].strip())
    return out

def write_doc_waivers(a, jobs: Path, rows, exc: Path) -> None:
    """Run the validator; every error on a column the team's document keeps becomes
    an exceptions row citing that document. Rows for other reasons are untouched."""
    import subprocess, json
    out = jobs / f"control_table_{a.system}_phase1.csv"
    hdr = "source_system,source_table,column,rule,justification,approved_by"
    existing = [l for l in exc.read_text(encoding="utf-8").splitlines() if l.strip()]
    if not existing: existing = [hdr]
    keep = [l for l in existing if "columns-doc" not in l]      # regenerate ours only
    exc.write_text("\n".join(keep) + "\n", encoding="utf-8")
    res = subprocess.run([sys.executable, str(jobs / "validate_control_table.py"), str(out), "--exceptions", str(exc)],
                         capture_output=True, text=True)
    added = 0
    for line in res.stdout.splitlines() + res.stderr.splitlines():
        # validator format: "ERROR   line   31  CT015  columns_allowlist: 'name' matched [...]"
        m = re.match(r"ERROR\s+line\s+(\d+)\s+(CT\d{3})\s+columns_allowlist: '([^']+)'", line)
        if not m: continue
        lineno, rule, col = int(m.group(1)), m.group(2), m.group(3)
        row = rows[lineno - 2] if 0 <= lineno - 2 < len(rows) else None     # line 1 = header
        if row is None or col not in row["columns_allowlist"].split("|"): continue
        table = row["source_table"]
        keep.append(f"{a.system},{table},{col},{rule},"
                    f"\"Kept by the source team's safe-columns document {a.columns_doc.name} (columns-doc); reference/business value, not a person identifier per that document\","
                    f"\"Source team document {a.columns_doc.name} - PROVISIONAL until the data officer signs the purpose register\"")
        added += 1
    exc.write_text("\n".join(keep) + "\n", encoding="utf-8")
    print(f"  exceptions: {added} waiver(s) written from {a.columns_doc.name}")

def main(argv=None) -> int:
    ap = argparse.ArgumentParser(); ap.add_argument("--system", required=True)
    ap.add_argument("--only", nargs="*", default=[], help="restrict to these source tables")
    ap.add_argument("--jobs", type=Path, default=Path(__file__).resolve().parent)
    ap.add_argument("--columns-doc", type=Path, help="team markdown of safe columns (see header)")
    ap.add_argument("--exclude", nargs="*", default=[], metavar="table.column",
                    help="columns to remove from the allowlist even if the document keeps them (person photos, credentials)")
    ap.add_argument("--include", nargs="*", default=[], metavar="table.column",
                    help="columns to add to the allowlist beyond the document (must exist in the dump; needs a waiver if a rule fires)")
    ap.add_argument("--from-phase1", action="store_true",
                    help="start from the existing control_table_<sys>_phase1.csv (keeps hand-edited allowlists) instead of the full control table")
    a = ap.parse_args(argv); jobs = a.jobs; root = jobs.parent
    src = jobs / (f"control_table_{a.system}_phase1.csv" if a.from_phase1 else f"control_table_{a.system}.csv")
    if not src.is_file(): print(f"error: {src} missing", file=sys.stderr); return 2
    rows = list(csv.DictReader(src.open(encoding="utf-8")))
    if a.only:
        keep = set(a.only); missing = keep - {r["source_table"] for r in rows}
        if missing: print(f"error: not in {src.name}: {sorted(missing)}", file=sys.stderr); return 2
        rows = [r for r in rows if r["source_table"] in keep]
    types = coltypes(root / f"{a.system}_schema.sql")
    doc_waivers: list[list[str]] = []
    if a.columns_doc:
        doc = parse_columns_doc(a.columns_doc)
        lower = {t.lower(): t for t in types}
        kept = []
        for dt, dcols in doc.items():
            if dt.lower() not in lower:
                print(f"  doc table not in our dump, skipped: {dt}"); continue
            t = lower[dt.lower()]; have = {c.lower(): c for c in types[t]}
            cols = [have[c.lower()] for c in dcols if c.lower() in have]
            dropped = [c for c in dcols if c.lower() not in have]
            if dropped: print(f"  {t}: doc columns absent from dump, skipped: {dropped}")
            base = next((r for r in rows if r["source_table"].lower() == t.lower()), None)
            if base is None:
                print(f"  {t}: not in control_table_{a.system}.csv (never classified) - skipped"); continue
            r = dict(base); r["source_table"] = t; r["columns_allowlist"] = "|".join(cols)
            kept.append(r)
        rows = kept
    for r in rows: r["purpose_ref"] = PURPOSE
    excl = {tuple(x.split(".", 1)) for x in a.exclude}
    for r in rows:
        cols = [c for c in r["columns_allowlist"].split("|") if (r["source_table"], c) not in excl]
        if len(cols) != len(r["columns_allowlist"].split("|")):
            print(f"  excluded from {r['source_table']}: {[c for c in r['columns_allowlist'].split('|') if c not in cols]}")
        r["columns_allowlist"] = "|".join(cols)
    for x in a.include:
        t, c = x.split(".", 1); r = next((r for r in rows if r["source_table"] == t), None)
        if r is None or c not in types.get(t, {}): print(f"  --include {x}: table not in phase1 or column not in dump - ignored"); continue
        if c not in r["columns_allowlist"].split("|"):
            r["columns_allowlist"] += "|" + c; print(f"  included {x}")
    # Credentials are FILTERED OUT, not merely dropped at silver: a "drop" column
    # still lands in raw bronze for up to 24 h. After --include on purpose, so a
    # manual include cannot bring one back. Added 2026-10-14 (camera.pass etc.).
    for r in rows:
        cols = r["columns_allowlist"].split("|")
        cred = [c for c in cols if CREDENTIAL.search(c) and c != r["primary_key"]]
        if cred:
            r["columns_allowlist"] = "|".join(c for c in cols if c not in cred)
            print(f"  credentials filtered out of {r['source_table']}: {cred} "
                  f"(record them in control_table_{a.system}_excluded_columns.csv)")
    rows = [r for r in rows if r["columns_allowlist"]]
    # Layer routing: see header.
    for r in rows:
        ppk = PERSON_ROW_PK.get((a.system, r["source_table"]), "")
        ts = {treat(c, types.get(r["source_table"], {}).get(c), r["primary_key"],
                    ppk if c == r["primary_key"] else "",
                    (a.system, r["source_table"].lower(), c) in NOT_A_PERSON)[0]
              for c in r["columns_allowlist"].split("|")}
        r["target_layer"] = "bronze" if ts & {"token", "drop"} else "bronze-ref"
    out = jobs / f"control_table_{a.system}_phase1.csv"
    with out.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
    exc = jobs / f"control_table_{a.system}_phase1_exceptions.csv"
    if not exc.exists():
        exc.write_text("source_system,source_table,column,rule,justification,approved_by\n", encoding="utf-8")
    rules_path = jobs / "transform_rules.csv"
    existing = list(csv.reader(rules_path.open(encoding="utf-8"))) if rules_path.exists() else \
               [["source_system","source_table","column","treatment","justification","approved_by","entity"]]
    hdr, body = existing[0], [x for x in existing[1:] if x[0] != a.system]
    if "entity" not in hdr:                      # migrate the file in place
        hdr = hdr + ["entity"]
    body = [x + [""] * (len(hdr) - len(x)) for x in body]
    new = []; tc = collections.Counter()
    for r in rows:
        ppk = PERSON_ROW_PK.get((a.system, r["source_table"]), "")
        for c in r["columns_allowlist"].split("|"):
            alias = ppk if c == r["primary_key"] else ""
            t, why = treat(c, types.get(r["source_table"], {}).get(c), r["primary_key"], alias,
                           (a.system, r["source_table"].lower(), c) in NOT_A_PERSON)
            new.append([a.system, r["source_table"], c, t, why, APPROVED, alias]); tc[t] += 1
    with rules_path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh); w.writerow(hdr); w.writerows(body + new)
    layers = collections.Counter(r["target_layer"] for r in rows)
    print(f"{a.system}: phase1 tables={len(rows)} columns={len(new)} treatments={dict(tc)} layers={dict(layers)} -> {out.name}, {rules_path.name}")
    if a.columns_doc:
        write_doc_waivers(a, jobs, rows, exc)
    return 0

if __name__ == "__main__":
    sys.exit(main())
