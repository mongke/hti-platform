"""Issue, list and revoke API keys for machine MCP clients (n8n ...). 2026-10-22.

    docker exec hti-mcp-kpi python /app/apikeys.py issue n8n --days 365 [--ip 1.2.3.4 ...]
    docker exec hti-mcp-kpi python /app/apikeys.py list
    docker exec hti-mcp-kpi python /app/apikeys.py revoke n8n

The key is printed ONCE at issue time and stored only as a SHA-256 hash.
"""
import argparse, datetime, os, sys
from auth import HtiOAuthProvider

def main() -> int:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    i = sub.add_parser("issue"); i.add_argument("name"); i.add_argument("--days", type=int, default=365)
    i.add_argument("--ip", action="append", default=[], help="only accept the key from this client IP (repeatable)")
    sub.add_parser("list")
    r = sub.add_parser("revoke"); r.add_argument("name")
    a = ap.parse_args()
    p = HtiOAuthProvider(os.environ.get("MCP_PUBLIC_URL", "https://datamgt.esukh.mn"), None)
    if a.cmd == "issue":
        print(p.issue_api_key(a.name, a.days, a.ip)); return 0
    if a.cmd == "revoke":
        ok = p.revoke_api_key(a.name); print("revoked" if ok else "no such key"); return 0 if ok else 1
    for k in p.list_api_keys():
        exp = datetime.datetime.fromtimestamp(k["expires_at"], datetime.timezone.utc).date() if k.get("expires_at") else "never"
        print(f"{k['name']:20} expires {exp}  ips={','.join(k.get('ips') or []) or 'any'}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
