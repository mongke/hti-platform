# mcp/catalog — what the MCP server knows about the data

Build inputs and outputs for the MCP server. The server reads the three served files; it never writes them. Rebuild the image after any change:
`cd /home/developer/hti-platform/mcp && docker compose up -d --build`.

**Hardened 2026-10-14:** the image ships ONLY `datasets.json`, `kpi_public.json` and
`TOOLS.md` (see the Dockerfile). Everything else here is internal build input.

| File | Served by | Source of truth |
| --- | --- | --- |
| `datasets.json` | `list_datasets`, `describe_dataset`, `query` (the allowlist) | `build_datasets.py`: curated DATASETS list + field roles; exclusions with reasons in `datasets_excluded.json` |
| `kpi_public.json` | `list_kpis`, `get_kpi_definition`, `get_kpi` | `build_datasets.py`: `kpi_definitions.json` + `kpis.py`, internal references stripped |
| `TOOLS.md` | `doc` | hand-written documentation of every tool, user-facing only |
| `kpi_definitions.json` | internal (input to kpi_public.json) | `build_kpi_definitions.py` — wording from `docs/kpi_extracted.txt` (the KPI PDF), status/SQL from `kpis.py`, unlocks from `docs/KPI_UNLOCK_REQUESTS_2026-10-06.md` |
| `data_dictionary.json` | internal (input to datasets.json) | `build_dictionary.py` = `live_catalog.json` + `notes_<system>.json` |
| `GUIDE.md` | not served (operator doc export) | Export of the "HTI Data Platform — How to Get What Data" doc (Claude Docs, markdown) |
| `live_catalog.json` | — | Spark Thrift `SHOW TABLES` / `DESCRIBE` only (2026-10-14). **Never add COUNT(*)**: a count over every table OOM-killed spark-thrift on this host. |
| `notes_<system>.json` | — | Hand-curated meanings from the schema DDL, `*_schema_analysis.md`, `reviews/`, `docs/`, control tables. Never invent a meaning: unknown = omitted. |

Rebuild order: `python3 build_kpi_definitions.py && python3 build_dictionary.py && python3 build_datasets.py`, then the image.
Nothing is exposed by default: a table reaches clients only by being listed in DATASETS
in `build_datasets.py`, and a column only if its role rules admit it. The camera/router
and stale sma bronze_ref tables are in no dataset.
