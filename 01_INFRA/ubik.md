---
tags:
  - node
  - workstation
created: 2026-06-22
updated: 2026-06-22
---

# 🖥️ UBIK — Workstation Principal

> Fonte única de verdade sobre o UBIK.

---

## Identificação

| Campo | Valor |
|-------|-------|
| **Modelo** | PCWare APM-A320G (Desktop) |
| **CPU** | AMD Ryzen 3 3200G com Radeon Vega Graphics |
| **RAM** | 14 GB (13 GB utilizáveis — Vega 8 reserva ~1 GB) |
| **GPUs** | RX 550 (dedicada) + Vega 8 (integrada) — Vulkan |
| **OS** | Ubuntu 24.04.4 LTS (Noble) |
| **Kernel** | Linux 6.17.0-35-generic |
| **Sway** | 1.9 (Gruvbox theme) |
| **Uptime** | 12 dias |
| **Papel** | Workstation principal, source of truth do Second Brain, Ollama local |

---

## Armazenamento

| Disco | Tipo | Tamanho | Uso | Montagem |
|-------|------|---------|-----|----------|
| `sda` | SSD Sistema | 119 GB | 87 GB (79%) | `/` |
| `sdc` | SSD Home | 224 GB | 173 GB (84%) | `/home` |
| `sdb` | HDD Almox | 932 GB | 447 GB (52%) | `/mnt/almox` |
| `zram0` | Swap comprimido | 10.2 GB | — | swap |

### `/home/marcel` — maiores diretórios

| Caminho | Tamanho | Conteúdo |
|---------|---------|----------|
| `~/ai/` | 2.2 GB | Modelos e dados de IA |
| `~/repos/` | 644 MB | Repositórios clonados |
| `~/dev/` | 496 MB | Desenvolvimento ativo |
| `~/Projects/` | 138 MB | Projetos pessoais |
| `~/go/` | 200 MB | Go toolchain/cache |

### `/mnt/almox` — Johnny.Decimal Root (916 GB, 423 GB livres)

| Prefixo | Área |
|---------|------|
| `00-09` | System |
| `10-19 Life Admin` | Vida pessoal e Second Brain |
| `20-29 Work` | Trabalho (IIVA Classes) |
| `30-39 Tech` | Tecnologia e projetos |
| `40-49 Learning Archive` | Arquivo de aprendizado |
| `50-59 Hobby & Soul` | Hobbies |

> Outros: `Media/` (mídia), `SteamLibrary/` (jogos), `LutrisGames/`, `AI_Models/`, `SmartArchive/`

---

## Rede

| Atributo | Valor |
|----------|-------|
| **IP Tailscale** | `{{TAILSCALE_IP_UBIK}}` |
| **DNS local** | `ubik.home` |
| **IP LAN** | `{{LAN_IP_UBIK}}` |
| **Interface** | `enp7s0` (ethernet) |

---

## Serviços

### 🟢 Docker

| Serviço | Porta | Status | Uptime |
|---------|-------|--------|--------|
| **Open WebUI** | 3000 | healthy | 12 dias |

### 🟢 Nativos

| Serviço | Porta | Tipo | Função |
|---------|-------|------|--------|
| **Ollama** | 11434 | Nativo (systemd) | LLM local com GPU Vulkan — 5 modelos |
| **Syncthing** | 8384 | Nativo (systemd) | Sincronização de arquivos |
| **Obsidian REST API (SB)** | 27125 | Plugin | API do Second Brain vault |
| **Obsidian REST API (IIVA)** | 27124 | Plugin | API do IIVA Classes vault |

### 🔴 Inativos

---

## Periféricos

| Periférico | Modelo | Conexão |
|------------|--------|---------|
| **Áudio** | Interface Behringer UM2 + BM800 | USB (Burr-Brown USB Audio CODEC) |
| **Teclado** | Leadership Gamer | USB (controlado via Streamdeckish) |
| **Monitor principal** | TV 1080p | HDMI |
| **Monitor secundário** | Samsung SyncMaster | (retrato) |

---

## Conexões

- [[00_Nexus/01_INFRA/hardware]] — Tabela resumo de hardware
- [[00_Nexus/01_INFRA/network]] — Topologia de rede
- [[00_Nexus/01_INFRA/docker_stack]] — Mapa de portas
