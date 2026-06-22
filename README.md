<p align="center">
  <img src="_assets/inomeado_NEXUS.svg" alt="Nexus System" width="180"/>
</p>

<h1 align="center">Nexus System</h1>

<p align="center">Documentação de infraestrutura e configuração do meu ecossistema self-hosted.</p>

<p align="center">
  <img src="https://img.shields.io/badge/N%C3%B3s-5-ff69b4" alt="Nós"/>
  <img src="https://img.shields.io/badge/Containers-13-2ea44f" alt="Containers"/>
  <img src="https://img.shields.io/badge/SO-Ubuntu%20%7C%20Fedora%20%7C%20LibreELEC-blue" alt="SO"/>
  <img src="https://img.shields.io/badge/Mesh-Tailscale-623ce4" alt="Mesh"/>
  <img src="https://img.shields.io/badge/Status-Ativo-success" alt="Status"/>
</p>

<p align="center">
  <img src="_assets/inomeado_VALIS.svg" alt="VALIS" width="48" title="VALIS — Infraestrutura"/>
  <img src="_assets/inomeado_PRIS.svg" alt="PRIS" width="48" title="PRIS — Automação"/>
  <img src="_assets/inomeado_UBIK.svg" alt="UBIK" width="48" title="UBIK — Workstation"/>
  <img src="_assets/inomeado_DECKARD.svg" alt="DECKARD" width="48" title="DECKARD — Fallback"/>
</p>

---

## Sobre

Cinco máquinas ligadas por Tailscale mesh, rodando 13 containers entre Ubuntu, Fedora e LibreELEC. A stack cobre DNS, Git, automação, IA local, agente de mensagens, banco vetorial e media center.

Os nós têm nomes do Philip K. Dick — a taxonomia ajuda a identificar o papel de cada máquina sem depender de IP.

## Hardware

| Node | Máquina | CPU | RAM | Disco | Função |
|------|---------|-----|-----|-------|--------|
| VALIS | Lenovo ideapad 330 | i3-7020U | 4GB | SSD 914GB + HD 916GB | Infraestrutura |
| PRIS | Samsung 270E5K | i5-5200U | 8GB | SSD 223GB + HD 916GB | Automação |
| UBIK | PCWare A320G | Ryzen 3 3200G | 14GB | SSD 119GB + SSD 224GB + HD 932GB | Workstation |
| ROY | Dell Inspiron 5447 | i5-4210U | 4GB | HDD 915GB | Media Center |
| DECKARD | Compaq Presario CQ-17 | Celeron N3350 | 4GB | SSD 464GB | Fallback |

## Stack

**Sistemas:** Ubuntu 24.04, Fedora 44, LibreELEC 12.
**Orquestração:** Docker Compose + systemd.
**Rede:** Tailscale (WireGuard), Pi-hole + Unbound (DNS), Cloudflare Tunnel (exposição).
**Automação:** n8n, Home Assistant, Hermes Agent.
**IA:** Ollama + Open WebUI, Hermes Agent (GPU Vulkan).
**Dados:** PostgreSQL, Qdrant, SQLite.
**Git:** Forgejo (privado), GitHub (público).
**Sincronia:** Syncthing.

## Repositório

```
00_Nexus/
├── 01_INFRA/    → Docs por nó (valis.md, pris.md, ubik.md, roy.md, deckard.md)
├── 02_STORAGE/  → Armazenamento e bancos
├── 03_WORKFLOWS/ → Protocolos operacionais
├── 05_SYSTEM_DESIGN/ → Decisões arquiteturais
├── 04_IMPLEMENTATION_LOG.md → Histórico de alterações
└── AGENTS.md
```

Cada nó tem seu documento. Documentos de resumo (hardware, rede, portas) referenciam os nós em vez de repetir. Toda alteração é registrada antes de ser concluída.
