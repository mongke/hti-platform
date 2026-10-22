# HTI KPI MCP server

Analytics-only MCP server for the 58 "Смарт Монгол туслах" KPIs and aggregate questions over
26 curated, tokenised datasets. Read-only; no records or identities are ever returned.
Hardened on 2026-10-14 against the MCP security best practices, the OWASP "Practical Guide
for Secure MCP Server Development", and the Obot and TrueFoundry checklists.

| | |
|---|---|
| Endpoint | **`https://datamgt.esukh.mn/mcp`** — the only way in. Caddy TLS 1.2+/HSTS, OAuth 2.1 (dynamic registration + PKCE); the operator signs in on `/login` with `MCP_LOGIN_USER` / `MCP_LOGIN_PASSWORD` from `mcp/.env` |
| Tools | `doc`, `list_kpis`, `get_kpi_definition`, `get_kpi`, `list_tables`, `describe_table`, `run_sql`, `list_datasets`, `describe_dataset`, `query` — call `doc()` for parameters and rules |
| Data | `catalog/datasets.json` (allowlist of datasets, fields, roles), `catalog/kpi_public.json`, `catalog/TOOLS.md` — built by `catalog/build_*.py` (see `catalog/README.md`) |
| Health | `GET /health` (no auth) |

This is the **only HTI service reachable from the internet** (ports 80/443 → Caddy →
mcp-kpi). Everything else stays loopback-only.

## Connect

**Claude Desktop / claude.ai** — Settings → Connectors → Add custom connector → name `HTI KPI`,
URL `https://datamgt.esukh.mn/mcp`. Claude registers itself and opens the sign-in page; it
names the client and the site the code goes to. Sign in only if you started it.

**ChatGPT** — Settings → Connectors (Developer mode) → Create → same URL, OAuth.

**Claude Code** — `claude mcp add --transport http hti-kpi https://datamgt.esukh.mn/mcp`
(OAuth in the browser; loopback redirect URIs are allowed).

**n8n** (and other machine clients that cannot do the browser sign-in) — API key:

1. Issue a key (printed once, stored only as a hash):
   `docker exec hti-mcp-kpi python /app/apikeys.py issue n8n --days 365 [--ip <n8n server IP>]`
2. In n8n: an **MCP Client Tool** node → Endpoint `https://datamgt.esukh.mn/mcp`,
   Server Transport **HTTP Streamable**, Authentication **Bearer Auth** → the key.
3. `apikeys.py list` shows keys and expiry; `apikeys.py revoke n8n` stops it immediately.
4. `apikeys.py set-ips n8n --ip <addr or CIDR> ...` locks a key to client IPs without re-issuing it.
   The n8n key is locked to n8n Cloud's published egress ranges (docs.n8n.io/manage-cloud/cloud-ip,
   2026-10-22). n8n may add ranges without notice: if n8n starts getting 401, compare that page
   with `apikeys.py list` and re-run `set-ips` with the new list.

A key gets the same read-only tools and limits as an OAuth client; calls are audited and
rate-limited as `apikey:<name>`. With `--ip`, the key only works from that address.

The SSH-tunnel path (`127.0.0.1:8765` + static `MCP_TOKEN`) was removed on 2026-10-14. The
static token now works only from inside the private Docker networks (operator tests).
Tokens issued before 2026-10-14 11:00 UTC stopped working when token storage moved to
hashes: each client signs in once more.

## Security controls

| Area | Control |
| --- | --- |
| Authentication | OAuth 2.1 + PKCE; access tokens 1 h, refresh 30 days, rotated; one read-only scope `kpi`; tokens bound to this server (`resource`) and stored as SHA-256 hashes |
| Client registration | Redirect URIs must be https on `MCP_REDIRECT_HOSTS` (claude.ai, claude.com, chatgpt.com, chat.openai.com) or loopback — checked at registration and authorization |
| Sign-in page | Names the client and redirect host; all values HTML-escaped; CSP `default-src 'none'`, no framing, no caching; 5 failures/IP or 30/hour globally → 15 min lock |
| Tools | Aggregates only, curated fields, tokens only as COUNT(DISTINCT); groups < 5 records or people suppressed; `run_sql` parsed (sqlglot) and confined: one SELECT, approved tables/fields/functions, no `*`, no window functions, joins need ON, ≤ 4 tables, ≤ 5000 chars |
| Resources | Tools run in worker threads; ≤ 4 Spark queries at once, each cancelled after 60 s; 200 rows, 300 chars per value; 60 calls/min per client |
| Output | No SQL text, paths, stack traces or internal notes in answers; generic error text |
| Audit | Every call logged: client id, tool, arguments, outcome, rows, duration; tool-manifest hash logged at start-up |
| Container | Non-root, read-only root fs, all capabilities dropped, no-new-privileges, 512 MB / 1 CPU / 128 PIDs, rotated logs; image pinned by digest; Python packages pinned by version and hash (`requirements.txt`), `pip-audit` clean on 2026-10-14 |
| Network | `mcp-kpi` only on internal networks: `mcp_edge` (Caddy) and `hti-mcp-data` (spark-thrift). No route to the databases or the internet; no published port. Caddy routes only the MCP/OAuth/login/health paths |

## Operate

    cd /home/developer/hti-platform/mcp
    docker compose up -d --build        # after editing server.py / auth.py / sqlcheck.py / catalog
    docker logs hti-mcp-kpi --tail 50   # audit lines start with "audit client="

Caddy's config is a single bind-mounted file: after editing `Caddyfile`, recreate the
container (`docker compose up -d --force-recreate caddy`) — a reload alone keeps reading
the old file. To revoke every client and token: `docker compose down -v` (also deletes the
certificate cache; Caddy re-issues it).
