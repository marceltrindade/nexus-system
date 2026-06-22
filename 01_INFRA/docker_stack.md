# 📦 Docker Stack — Mapa de Portas

> **DRY:** Este documento é o registro único de **portas em uso** em todo o ecossistema Nexus.
> Detalhes de cada serviço (configuração, health check, volumes) → no documento do nó.

---

## 🗄️ VALIS

| Porta | Serviço | Container |
|-------|---------|-----------|
| 53 | Pi-hole (DNS) | `pihole` |
| 222 | Forgejo (SSH Git) | `forgejo` |
| 3000 | Forgejo (Web) | `forgejo` |
| 3100 | Hoarder | `hoarder-web-1` |
| 5000 | hledger | `hledger` |
| 6333 | Qdrant | `qdrant` |
| 8080 | SearXNG | `searxng` |
| 8082 | Pi-hole (Admin) | `pihole` |
| 8083 | File Browser | `filebrowser` |
| 8084 | IT Tools | `it-tools` |
| 8086 | Vaultwarden | `vaultwarden` |
| 9091 | Transmission | `transmission` |
| 13378 | Audiobookshelf | `audiobookshelf` |
| 51413 | Transmission (TCP+UDP) | `transmission` |

> Doc completo: [[00_Nexus/01_INFRA/valis]]

---

## 🎬 PRIS

| Porta | Serviço | Container |
|-------|---------|-----------|
| 3000 | Open WebUI (JOI) | `open-webui` |
| 5678 | n8n | `n8n` |
| 8123 | Home Assistant | `homeassistant` (host) |
| 8384 | Syncthing | `syncthing` (host) |

### Nativos (Python)

| Porta | Serviço | Processo |
|-------|---------|----------|
| 5432 | PostgreSQL (Hindsight) | `postgres` |
| 9099 | Hermes Gateway | `hermes gateway run` |
| 9119 | Hermes Dashboard | `hermes dashboard` |

> Doc completo: [[00_Nexus/01_INFRA/pris]]

---

## 🖥️ UBIK

| Porta | Serviço | Tipo |
|-------|---------|------|
| 8384 | Syncthing | Nativo (systemd) |
| 11434 | Ollama | Nativo (host) |
| 3000 | Open WebUI | Docker (`open-webui`) |
| 27124 | Obsidian REST API (IIVA) | Plugin |
| 27125 | Obsidian REST API (Second Brain) | Plugin |

> Doc: [[00_Nexus/01_INFRA/ubik]] (a criar)

---

## ⚠️ Serviços Nativos (Non-Docker)

| Nó | Serviço | Porta | Motivo |
|----|---------|-------|--------|
| UBIK | Ollama | 11434 | Acesso total à GPU |
| VALIS | Syncthing | 8384 | Systemd service |
| VALIS | Docker Engine | — | Systemd service |

---

## Referência cruzada

| Nó | Doc principal | Serviços contados |
|----|---------------|-------------------|
| VALIS | [[00_Nexus/01_INFRA/valis]] | 13 containers |
| PRIS | [[00_Nexus/01_INFRA/pris]] | 4 containers + 3 nativos |
| DECKARD | [[00_Nexus/01_INFRA/deckard]] | 0 containers (Fedora puro, sem Docker) |
| UBIK | [[00_Nexus/01_INFRA/ubik]] | 1 container + 2 nativos |
| ROY | [[00_Nexus/01_INFRA/roy]] | 0 containers (LibreELEC/Kodi) |

---

## Histórico de portas liberadas / removidas

| Porta | Antigo serviço | Nó | Data |
|-------|---------------|----|------|
| 3030 | Ocular | VALIS | Removido — substituído por hledger (:5000) |
| 8000 | IIVA API (antiga) | VALIS | Liberada — projeto migrado |
