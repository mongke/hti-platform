# Log shipping to central Grafana/Loki (set up 2026-10-14)

This server (165.22.106.150, label `server="hti_platform"`) ships to the central monitoring
server 103.168.56.193 (Grafana at https://grafana.esukh.mn).

| What | Source | Labels |
| --- | --- | --- |
| MCP audit + server logs | `hti-mcp-kpi` via journald | `job="docker"`, `container_name`, `tool`, `outcome`, `manifest` |
| Caddy access logs (JSON) | `hti-caddy` via journald | `job="docker"`, `container_name="hti-caddy"` |
| Nightly backup chain | `/home/developer/dbbackup/logs/nightly_*.log` | `job="dbbackup"` |

Shipper: `hti-promtail` (this folder). No Docker socket, read-only mounts and root fs, no
capabilities. Pushes over HTTPS with basic auth to `https://grafana.esukh.mn/loki/api/v1/push`
(push-only nginx location; password in `loki_push_password`, 600, user `hti-platform`).

Grafana Explore examples:

    {server="hti_platform", container_name="hti-mcp-kpi"} |= "audit"
    {server="hti_platform", container_name="hti-mcp-kpi", outcome="error"}
    {server="hti_platform", container_name="hti-caddy"} | json | status >= 400
    {server="hti_platform", job="dbbackup"}

## Alerts (Loki ruler -> Alertmanager -> existing email route)

Rules file on the central server: `~/monitoring-stack/central-server/loki-rules/fake/hti-platform.yml`.
HtiMcpRefusedSpike, HtiMcpRateLimited, HtiMcpCrash, HtiMcpToolManifestChanged,
HtiMcpSignInBruteForce, HtiMcpLogsSilent, HtiNightlyBackupFailed, HtiNightlyBackupMissing.

## Central server changes made on 2026-10-14 (all with backups `*.bak-20261014`)

- Firewall: `/usr/local/sbin/hti-monitoring-firewall.sh` + `hti-monitoring-firewall.service`
  close Loki 3100, Prometheus 9090, Alertmanager 9093, cAdvisor 8081 to all but the agent
  servers, and Grafana's direct port 3030 entirely. Databases (same script): pg16 /
  smartpay_db 5433 to the known servers only; chirpstack Redis 9181 and Postgres 9182
  closed (only chirpstack's own containers use them, over the Docker network). Revert: `sudo systemctl disable --now
  hti-monitoring-firewall`. Add a new agent server's IP to `ALLOW` in the script, then
  `sudo systemctl restart hti-monitoring-firewall`.
- nginx: push-only Loki location in `sites-available/grafana.esukh.mn`; stray
  `sites-enabled/test.parkly.mn.save` (it broke every nginx reload) moved to
  `sites-available/test.parkly.mn.save.disabled-20261014`.
- Loki: `ruler:` block in `configs/loki.yml`, `./loki-rules` mounted in `docker-compose.yml`.
