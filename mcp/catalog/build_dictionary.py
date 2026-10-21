"""Build data_dictionary.json for the MCP server.

Inputs (both in this folder):
  live_catalog.json  every silver / bronze_ref table and its columns+types, dumped from
                     Spark Thrift with metadata-only statements (SHOW TABLES, DESCRIBE).
                     Never add COUNT(*) here: on 2026-10-14 a COUNT over every table
                     OOM-killed spark-thrift on this 7.8 GiB host.
  notes_<system>.json hand-curated meanings (systems, tables, columns, joins) extracted from
                     the *_schema_analysis.md, reviews/, docs/ and control tables. Edit
                     this file to improve the dictionary; never invent meanings.
Run:  python3 build_dictionary.py        (then rebuild the image: docker compose up -d --build)
"""
import json, os
from datetime import date

HERE = os.path.dirname(os.path.abspath(__file__))
live = json.load(open(os.path.join(HERE, "live_catalog.json"), encoding="utf-8"))
# One notes file per system (notes_esukh.json ...), merged here.
notes = {"systems": {}, "tables": {}}
for f in sorted(os.listdir(HERE)):
    if f.startswith("notes_") and f.endswith(".json"):
        part = json.load(open(os.path.join(HERE, f), encoding="utf-8"))
        notes["systems"].update(part.get("systems", {})); notes["tables"].update(part.get("tables", {}))

REFRESH = {  # how each source reaches the lake (see /home/developer/dbbackup/nightly_sources.sh)
    "esukh": "nightly dump, restored 04:10 UTC, then loaded by hti_nightly",
    "myproperty": "nightly dump (02:00 UB), restored 04:10 UTC since 2026-10-14",
    "parkly": "nightly dump (23:00 UB), restored 04:10 UTC",
    "smartpay": "on-demand dump only (last 2026-09-29)",
    "sma": "nightly dump (02:00 UB) once the SMA host grants SSH access; until then the 2026-09-30 dump",
}

# Withheld by server.py (BLOCKED_TABLES / BLOCKED_LAYER_TABLES) - not described either.
WITHHELD = {"silver.esukh_camera", "silver.parkly_camera", "silver.parkly_routerconfig",
            "bronze_ref.sma_iotsubscriptions", "bronze_ref.sma_notifyons", "bronze_ref.sma_subscriptionbills"}
systems, tables = {}, {}
for key, t in sorted(live.items()):
    if key in WITHHELD:
        continue
    layer, name = key.split(".", 1)
    system = name.split("_", 1)[0]
    n = notes.get("tables", {}).get(key, {})
    colnotes = n.get("columns", {})
    tables[key] = {
        "system": system, "layer": layer,
        **{f: n[f] for f in ("description", "key", "time_column", "joins") if n.get(f)},
        "columns": [{"name": c, "type": ty, **({"meaning": colnotes[c]} if colnotes.get(c) else {})}
                    for c, ty in t["columns"]],
    }
    s = systems.setdefault(system, {"description": notes.get("systems", {}).get(system, {}).get("description", ""),
                                    "refresh": REFRESH.get(system, ""), "silver_tables": 0, "bronze_ref_tables": 0,
                                    "tables_described": 0})
    s[f"{layer}_tables"] += 1
    s["tables_described"] += bool(n.get("description"))

out = {
    "generated": date.today().isoformat(),
    "layers": {
        "silver": "business data with every person identifier replaced by a per-system UUID token",
        "bronze_ref": "non-personal reference data (lookups, configuration, catalogues)",
        "bronze": "raw personal data, 24 h retention - NOT exposed by this server",
    },
    "naming": "<layer>.<system>_<source table in lower case>, e.g. silver.myproperty_invoice",
    "systems": systems,
    "tables": tables,
}
json.dump(out, open(os.path.join(HERE, "data_dictionary.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
described = sum(1 for t in tables.values() if t.get("description"))
annotated = sum(1 for t in tables.values() for c in t["columns"] if c.get("meaning"))
print(f"{len(tables)} tables ({described} described), "
      f"{sum(len(t['columns']) for t in tables.values())} columns ({annotated} with a meaning)")
