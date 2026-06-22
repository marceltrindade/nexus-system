# 🌐 Network (Nexus Mesh)

> **DRY:** Este documento contém topologia de rede e rotas públicas. Detalhes por nó → doc específico de cada nó.

---

## IPs e Hostnames (Tailscale)

| Node | IP Tailscale | DNS Local | IP LAN | Papel | Doc |
|------|-------------|-----------|--------|-------|-----|
| **VALIS** | `{{TAILSCALE_IP_VALIS}}` | `valis.home` | `{{LAN_IP_VALIS}}` | DNS, Infra, Túneis | [[00_Nexus/01_INFRA/valis]] |
| **PRIS** | `{{TAILSCALE_IP_PRIS}}` | `pris.home` | `{{LAN_IP_PRIS}}` | Automação (n8n, HA, Hermes) | [[00_Nexus/01_INFRA/pris]] |
| **DECKARD** | `{{TAILSCALE_IP_DECKARD}}` | — | `{{LAN_IP_DECKARD}}` | Fallback workstation (Fedora 44) | [[00_Nexus/01_INFRA/deckard]] |
| **UBIK** | `{{TAILSCALE_IP_UBIK}}` | `ubik.home` | — | Workstation | [[00_Nexus/01_INFRA/ubik]] |
| **ROY** | ❌ Sem Tailscale | — | `{{LAN_IP_ROY}}` | Kodi Media Center (Wi-Fi, sem cabo) | [[00_Nexus/01_INFRA/roy]] |

---

## Cloudflare Tunnels

O conector `cloudflared-tunnel` roda no **VALIS**. Abaixo as rotas publicadas sob `{{CLOUDFLARE_DOMAIN}}`:

### ✅ Ativas

| Domínio | Serviço | Destino |
|---------|---------|---------|
| `vault.{{CLOUDFLARE_DOMAIN}}` | Vaultwarden | `{{TAILSCALE_IP_VALIS}}:8086` |
| `audiobook.{{CLOUDFLARE_DOMAIN}}` | Audiobookshelf | `{{TAILSCALE_IP_VALIS}}:13378` |
| `drive.{{CLOUDFLARE_DOMAIN}}` | File Browser | `{{TAILSCALE_IP_VALIS}}:8083` |
| `search.{{CLOUDFLARE_DOMAIN}}` | SearXNG | `{{TAILSCALE_IP_VALIS}}:8080` |
| `git.{{CLOUDFLARE_DOMAIN}}` | Forgejo | `{{TAILSCALE_IP_VALIS}}:3000` |
| `ha.{{CLOUDFLARE_DOMAIN}}` | Home Assistant | `{{TAILSCALE_IP_PRIS}}:8123` (PRIS) |
| `n8n.{{CLOUDFLARE_DOMAIN}}` | n8n | `n8n:5678` (PRIS) |

### ❌ A Remover (requer acesso ao dashboard Cloudflare)

Estas rotas serviam à extinta stack Buster Friendly (arr stack + Jellyfin). Os serviços não existem mais. Para remover: acessar `https://one.dash.cloudflare.com/` → Zero Trust → Networks → Tunnels → selecionar o túnel → editar rotas.

| Domínio | Serviço extinto |
|---------|----------------|
| `jellyfin.{{CLOUDFLARE_DOMAIN}}` | Jellyfin (media server) |
| `locadora.{{CLOUDFLARE_DOMAIN}}` | Jellyseerr (media requests) |
| `rss.{{CLOUDFLARE_DOMAIN}}` | FreshRSS (RSS reader) |
| `sonarr.{{CLOUDFLARE_DOMAIN}}` | Sonarr (TV series) |
| `radarr.{{CLOUDFLARE_DOMAIN}}` | Radarr (movies) |
| `prowlarr.{{CLOUDFLARE_DOMAIN}}` | Prowlarr (indexer) |
| `bazarr.{{CLOUDFLARE_DOMAIN}}` | Bazarr (subtitles) |
| `rdt.{{CLOUDFLARE_DOMAIN}}` | RDT client |
| `decypharr.{{CLOUDFLARE_DOMAIN}}` | Decypharr (debrid) |
| `budget.{{CLOUDFLARE_DOMAIN}}` | Ocular (finanças — substituído por hledger) |

---

## DNS

| Configuração | Detalhe |
|-------------|---------|
| **DNS Principal** | Pi-hole no VALIS (`{{LAN_IP_VALIS}}`) |
| **Upstream** | Unbound (VALIS) — DNS recursivo privado |
| **Sufixo local** | `.home` (substituiu `.nexus` por conflitos HSTS) |
| **Registros locais** | ✅ Configurados via `etc_dnsmasq_d = true` + `/etc/dnsmasq.d/nexus-hosts.conf` no Pi-hole. `valis.home`, `pris.home`, `ubik.home`, `roy.home`, `deckard.home`, `ha.home`, `n8n.home`, `git.home` resolvem. |

---

## Conexões

- [[00_Nexus/01_INFRA/valis]] — Detalhes do node de infraestrutura
- [[00_Nexus/01_INFRA/hardware]] — Tabela de hardware dos nós
