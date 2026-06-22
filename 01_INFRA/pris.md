---
tags:
  - node
  - automacao
created: 2026-06-22
updated: 2026-06-22
---

# 🎬 PRIS — Node de Automação

> Fonte única de verdade sobre a PRIS.

---

## Identificação

| Campo | Valor |
|-------|-------|
| **Modelo** | Samsung 270E5K/270E5Q/271E5K/2570EK |
| **CPU** | Intel Core i5-5200U @ 2.20 GHz |
| **RAM** | 8 GB (7.7 GiB) |
| **Disco (sistema)** | SSD 223.6 GB — 102 GB usado (50%) |
| **Disco (armazenamento)** | HD 931.5 GB em `/mnt/storage` — 3.3 GB usado (1%) |
| **OS** | Ubuntu 24.04.4 LTS |
| **Kernel** | Linux 6.8.0-117-generic |
| **Uptime** | 29 dias |
| **Hardware Vendor** | SAMSUNG ELECTRONICS CO., LTD. |
| **Model Year** | 2016 (~10 anos) |
| **Papel** | Automação residencial, n8n, Hermes Gateway, Hindsight |

---

## Rede

| Atributo | Valor |
|----------|-------|
| **IP Tailscale** | `{{TAILSCALE_IP_PRIS}}` |
| **DNS local** | `pris.home` |
| **IP LAN** | `{{LAN_IP_PRIS}}` |
| **Status** | ✅ Ativo (conexão direta LAN) |

---

## Serviços

### 🟢 Docker

| Serviço | Porta | Status | Uptime | Config |
|---------|-------|--------|--------|--------|
| **n8n** | 5678 | up | 7 dias | `~/docker/docker-compose.yml` — stack principal |
| **Home Assistant** | 8123 (host) | up | 2 semanas | `~/docker/docker-compose.yml` — host network |
| **Syncthing** | 8384 (host) | healthy | 2 semanas | `~/docker/docker-compose.yml` — host network |
| **Open WebUI (JOI)** | 3000 | healthy | 2 semanas | `~/docker/open-webui/docker-compose.yml` — configurado como "JOI", URL `joi.{{CLOUDFLARE_DOMAIN}}` |

### 🟢 Processos Nativos (Python)

| Serviço | Porta | Função | Iniciado |
|---------|-------|--------|----------|
| **Hermes Gateway** | 9099 | MCP/Slack/Telegram gateway principal | 03/06 |
| **Hermes Dashboard** | 9119 | Interface web do Hermes | 03/06 |
| **PostgreSQL (Hindsight)** | 5432 | Banco de memória persistente do Hermes | 02/06 |

### 🔴 Removidos / Inativos

| Serviço | Status | Nota |
|---------|--------|------|
| **Odysseus** | Dados presentes em `~/docker/odysseus/` | Removido da malha — app.db + chroma ainda existem |
| **Buster Friendly (arr stack)** | Removido | Jellyfin, Radarr, Sonarr, Prowlarr, Bazarr, Decypharr — migrado p/ ROY (Kodi) |

---

## Armazenamento — `/mnt/storage` (916 GB, 1% usado)

| Caminho | Conteúdo |
|---------|----------|
| `JD/` | Johnny.Decimal root — dados sincronizados (00-09 System, 10-19 Life Admin, 20-29 Work) |
| `Media/`, `media/` | Mídia (remanescente Buster) |
| `docker/` | Volumes dos containers (n8n, HA, syncthing) |
| `nanobot/` | Nanobot (a investigar) |
| `docker/odysseus/` | App + chroma DB do Odysseus (inativo) |

---

## Conexões

- [[00_Nexus/01_INFRA/hardware]] — Tabela resumo de hardware
- [[00_Nexus/01_INFRA/network]] — Topologia de rede
- [[00_Nexus/01_INFRA/docker_stack]] — Mapa de portas
- [[00_Nexus/01_INFRA/valis]] — VALIS (infraestrutura complementar)
