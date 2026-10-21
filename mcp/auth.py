"""Minimal OAuth 2.1 authorization server for the HTI KPI MCP server.

Why: Claude Desktop and ChatGPT connectors only accept a public HTTPS MCP URL and
authenticate with OAuth (dynamic client registration + PKCE). This provider implements
exactly that for ONE human identity - the operator login in MCP_LOGIN_USER /
MCP_LOGIN_PASSWORD - and nothing else. Clients register themselves, the user proves
who they are on /login, codes/tokens are random and stored in SQLite under /data.
Tokens: access 1 h, refresh 30 days, rotated on use. 5 failed logins per IP -> 15 min lock.

Hardened 2026-10-14 (MCP security best practices, OWASP MCP guide):
  * redirect URIs: https on an allowlisted host (MCP_REDIRECT_HOSTS) or loopback - checked at
    registration AND at authorization; the sign-in page names the client and shows where the
    code will be sent (confused-deputy / DCR phishing)
  * `resource` must be this server (audience); tokens carry it and are checked on use
  * the static MCP_TOKEN is accepted only on the internal network, never via the public proxy
  * codes and tokens are stored as SHA-256 hashes, not in plaintext
  * global lockout (30 failures/hour) on top of the per-IP one
  * sign-in page: every dynamic value HTML-escaped; no framing, no scripts, no caching
"""
from __future__ import annotations
import contextvars, hashlib, html, json, os, secrets, sqlite3, time, hmac
from typing import Any
from urllib.parse import urlencode, urlparse

from mcp.server.auth.provider import (AccessToken, AuthorizationCode, AuthorizationParams, AuthorizeError,
                                      OAuthAuthorizationServerProvider, RefreshToken, RegistrationError,
                                      construct_redirect_uri)
from mcp.shared.auth import OAuthClientInformationFull, OAuthToken
from starlette.requests import Request
from starlette.responses import HTMLResponse, RedirectResponse, Response

DB_PATH = os.environ.get("MCP_OAUTH_DB", "/data/oauth.db")
SCOPE = "kpi"
ACCESS_TTL, REFRESH_TTL, CODE_TTL, TXN_TTL = 3600, 30 * 86400, 300, 600
REDIRECT_HOSTS = {h.strip().lower() for h in os.environ.get(
    "MCP_REDIRECT_HOSTS", "claude.ai,claude.com,chatgpt.com,chat.openai.com").split(",") if h.strip()}
LOOPBACK = {"localhost", "127.0.0.1", "::1"}
GLOBAL_FAILS, GLOBAL_WINDOW = 30, 3600
# Set per request by ProxyMarker (server.py): True when the request came through Caddy.
# Default True = treat as public unless proven internal.
VIA_PROXY: contextvars.ContextVar[bool] = contextvars.ContextVar("via_proxy", default=True)

def _h(token: str) -> str:
    """Codes and tokens are stored under their SHA-256, never in plaintext."""
    return hashlib.sha256(token.encode()).hexdigest()

def redirect_ok(uri: str) -> bool:
    u = urlparse(str(uri))
    host = (u.hostname or "").lower()
    if u.scheme == "http":
        return host in LOOPBACK
    return u.scheme == "https" and any(host == d or host.endswith("." + d) for d in REDIRECT_HOSTS)

class Store:
    def __init__(self, path: str):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        self.c = sqlite3.connect(path, check_same_thread=False)
        self.c.executescript("""
          CREATE TABLE IF NOT EXISTS kv (ns TEXT, k TEXT, v TEXT, exp REAL, PRIMARY KEY (ns, k));
          CREATE TABLE IF NOT EXISTS fails (ip TEXT PRIMARY KEY, n INTEGER, until REAL);""")
    def put(self, ns, k, v: dict, ttl: float | None = None):
        self.c.execute("REPLACE INTO kv VALUES (?,?,?,?)", (ns, k, json.dumps(v, default=str), time.time() + ttl if ttl else None)); self.c.commit()
    def get(self, ns, k) -> dict | None:
        r = self.c.execute("SELECT v, exp FROM kv WHERE ns=? AND k=?", (ns, k)).fetchone()
        if not r: return None
        if r[1] is not None and r[1] < time.time(): self.delete(ns, k); return None
        return json.loads(r[0])
    def delete(self, ns, k):
        self.c.execute("DELETE FROM kv WHERE ns=? AND k=?", (ns, k)); self.c.commit()
    def sweep(self):
        self.c.execute("DELETE FROM kv WHERE exp IS NOT NULL AND exp < ?", (time.time(),)); self.c.commit()
    # login throttling
    def locked(self, ip) -> bool:
        now = time.time()
        r = self.c.execute("SELECT n, until FROM fails WHERE ip=?", (ip,)).fetchone()
        g = self.c.execute("SELECT n, until FROM fails WHERE ip='*'").fetchone()
        return bool((r and r[0] >= 5 and r[1] > now) or (g and g[0] >= GLOBAL_FAILS and g[1] > now))
    def fail(self, ip):
        now = time.time()
        r = self.c.execute("SELECT n FROM fails WHERE ip=?", (ip,)).fetchone(); n = (r[0] if r else 0) + 1
        self.c.execute("REPLACE INTO fails VALUES (?,?,?)", (ip, n, now + 900))
        # Global counter: distributed guessing from many IPs locks sign-in for everyone.
        g = self.c.execute("SELECT n, until FROM fails WHERE ip='*'").fetchone()
        gn = (g[0] + 1) if g and g[1] > now else 1
        self.c.execute("REPLACE INTO fails VALUES ('*',?,?)", (gn, now + (900 if gn >= GLOBAL_FAILS else GLOBAL_WINDOW)))
        self.c.commit()
    def clear(self, ip):
        self.c.execute("DELETE FROM fails WHERE ip=?", (ip,)); self.c.commit()


class HtiOAuthProvider(OAuthAuthorizationServerProvider):
    def __init__(self, public_url: str, static_token: str | None):
        self.public_url = public_url.rstrip("/")
        self.static_token = static_token
        self.db = Store(DB_PATH)
        self.audiences = {self.public_url, self.public_url + "/mcp"}

    # ---- clients (dynamic registration)
    async def get_client(self, client_id: str) -> OAuthClientInformationFull | None:
        d = self.db.get("client", client_id)
        return OAuthClientInformationFull.model_validate(d) if d else None

    async def register_client(self, client_info: OAuthClientInformationFull) -> None:
        bad = [str(u) for u in (client_info.redirect_uris or []) if not redirect_ok(u)]
        if not client_info.redirect_uris or bad:
            raise RegistrationError("invalid_redirect_uri",
                                    "redirect URIs must be https on an approved client host, or loopback")
        if client_info.client_name and len(client_info.client_name) > 100:
            raise RegistrationError("invalid_client_metadata", "client_name too long")
        self.db.put("client", client_info.client_id, client_info.model_dump(mode="json"))

    # ---- authorization: park the request, send the human to /login
    async def authorize(self, client: OAuthClientInformationFull, params: AuthorizationParams) -> str:
        # Re-checked here too: clients registered before 2026-10-14 were not validated.
        if not redirect_ok(params.redirect_uri):
            raise AuthorizeError("invalid_request", "redirect_uri is not an approved client host")
        if params.resource and str(params.resource).rstrip("/") not in self.audiences:
            raise AuthorizeError("invalid_request", "resource must be this MCP server")
        txn = secrets.token_urlsafe(24)
        self.db.put("txn", txn, {"client_id": client.client_id, **params.model_dump(mode="json")}, TXN_TTL)
        return f"{self.public_url}/login?{urlencode({'txn': txn})}"

    def complete_login(self, txn: str) -> str | None:
        """Called by the /login POST after the password check: mint the code, build the redirect."""
        p = self.db.get("txn", txn)
        if not p: return None
        self.db.delete("txn", txn)
        code = secrets.token_urlsafe(32)
        ac = AuthorizationCode(code=code, scopes=p.get("scopes") or [SCOPE], expires_at=time.time() + CODE_TTL,
                               client_id=p["client_id"], code_challenge=p["code_challenge"], redirect_uri=p["redirect_uri"],
                               redirect_uri_provided_explicitly=p["redirect_uri_provided_explicitly"], resource=p.get("resource"))
        self.db.put("code", _h(code), ac.model_dump(mode="json", exclude={"code"}), CODE_TTL)
        return construct_redirect_uri(str(p["redirect_uri"]), code=code, state=p.get("state"))

    async def load_authorization_code(self, client, authorization_code: str) -> AuthorizationCode | None:
        d = self.db.get("code", _h(authorization_code))
        return AuthorizationCode.model_validate({**d, "code": authorization_code}) if d and d["client_id"] == client.client_id else None

    async def exchange_authorization_code(self, client, authorization_code: AuthorizationCode) -> OAuthToken:
        self.db.delete("code", _h(authorization_code.code))
        return self._issue(client.client_id, authorization_code.scopes, authorization_code.resource)

    # ---- tokens
    def _issue(self, client_id: str, scopes: list[str], resource: str | None) -> OAuthToken:
        at, rt = secrets.token_urlsafe(32), secrets.token_urlsafe(32)
        now = time.time()
        resource = resource or self.public_url + "/mcp"          # every token is bound to this server
        self.db.put("access", _h(at), AccessToken(token="-", client_id=client_id, scopes=scopes, expires_at=int(now + ACCESS_TTL), resource=resource).model_dump(mode="json", exclude={"token"}), ACCESS_TTL)
        self.db.put("refresh", _h(rt), RefreshToken(token="-", client_id=client_id, scopes=scopes, expires_at=int(now + REFRESH_TTL)).model_dump(mode="json", exclude={"token"}), REFRESH_TTL)
        self.db.sweep()
        return OAuthToken(access_token=at, token_type="Bearer", expires_in=ACCESS_TTL, scope=" ".join(scopes), refresh_token=rt)

    async def load_refresh_token(self, client, refresh_token: str) -> RefreshToken | None:
        d = self.db.get("refresh", _h(refresh_token))
        return RefreshToken.model_validate({**d, "token": refresh_token}) if d and d["client_id"] == client.client_id else None

    async def exchange_refresh_token(self, client, refresh_token: RefreshToken, scopes: list[str]) -> OAuthToken:
        self.db.delete("refresh", _h(refresh_token.token))                  # rotation
        return self._issue(client.client_id, scopes or refresh_token.scopes, None)

    async def load_access_token(self, token: str) -> AccessToken | None:
        # Static operator token (mcp/.env MCP_TOKEN): internal network only, never via Caddy.
        if self.static_token and hmac.compare_digest(token, self.static_token):
            if VIA_PROXY.get():
                return None
            return AccessToken(token=token, client_id="static-operator", scopes=[SCOPE], expires_at=None)
        d = self.db.get("access", _h(token))
        if not d or (d.get("resource") and str(d["resource"]).rstrip("/") not in self.audiences):
            return None
        return AccessToken.model_validate({**d, "token": token})

    async def revoke_token(self, token: AccessToken | RefreshToken) -> None:
        self.db.delete("access", _h(token.token)); self.db.delete("refresh", _h(token.token))


# ---------------------------------------------------------------- login page
_FORM = """<!doctype html><html><head><meta charset="utf-8"><title>HTI data platform - sign in</title>
<style>body{{font-family:system-ui;background:#0f172a;color:#e2e8f0;display:flex;justify-content:center;padding-top:10vh}}
form{{background:#1e293b;padding:2rem;border-radius:12px;width:320px}}input{{width:100%;padding:.6rem;margin:.4rem 0 1rem;border-radius:6px;border:1px solid #334155;background:#0f172a;color:#e2e8f0}}
button{{width:100%;padding:.7rem;border:0;border-radius:6px;background:#38bdf8;color:#0f172a;font-weight:600}}p.err{{color:#f87171}}</style></head>
<body><form method="post"><h2>HTI KPI connector</h2><p>{client}</p><p>{target}</p>{err}
<input type="hidden" name="txn" value="{txn}"><label>User</label><input name="user" autocomplete="username" required>
<label>Password</label><input name="password" type="password" autocomplete="current-password" required><button>Sign in and allow</button></form></body></html>"""
# No framing (clickjacking), no scripts, no caching of the sign-in page.
_SEC = {"X-Frame-Options": "DENY", "Cache-Control": "no-store", "Referrer-Policy": "no-referrer",
        "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; frame-ancestors 'none'; base-uri 'none'"}

def _page(body: str, status: int = 200) -> HTMLResponse:
    return HTMLResponse(body, status_code=status, headers=_SEC)

def _form(txn: str, p: dict | None, c: dict | None, err: str = "") -> str:
    e = html.escape
    name = (c or {}).get("client_name") or (p or {}).get("client_id") or "an unknown client"
    host = urlparse(str((p or {}).get("redirect_uri", ""))).hostname or "?"
    return _FORM.format(txn=e(txn), err=err,
                        client=f"Allow <b>{e(str(name)[:60])}</b> to read HTI KPI aggregates?",
                        target=f"After sign-in you are sent to <b>{e(host)}</b>. Only continue if you started this from that client.")

def login_routes(provider: HtiOAuthProvider, user: str, password: str):
    async def login_get(request: Request) -> Response:
        txn = request.query_params.get("txn", "")
        p = provider.db.get("txn", txn)
        if not p: return _page("<h3>Login link expired - start again from your client.</h3>", 400)
        return _page(_form(txn, p, provider.db.get("client", p["client_id"])))

    async def login_post(request: Request) -> Response:
        form = await request.form()
        ip = (request.headers.get("x-forwarded-for", "").split(",")[0].strip() or (request.client.host if request.client else "?"))
        txn = str(form.get("txn", ""))
        if provider.db.locked(ip):
            return _page("<h3>Too many attempts - try again in 15 minutes.</h3>", 429)
        ok = hmac.compare_digest(str(form.get("user", "")), user) and hmac.compare_digest(str(form.get("password", "")), password)
        if not ok:
            provider.db.fail(ip)
            p = provider.db.get("txn", txn)
            return _page(_form(txn, p, provider.db.get("client", p["client_id"]) if p else None,
                               '<p class="err">Wrong user or password.</p>'), 401)
        provider.db.clear(ip)
        target = provider.complete_login(txn)
        if not target: return _page("<h3>Login link expired - start again from your client.</h3>", 400)
        return RedirectResponse(target, status_code=302)
    return login_get, login_post
