---
tags:
  - node
  - fallback
created: 2026-06-22
updated: 2026-06-22
---

# ⚔️ DECKARD — Fallback Workstation

> Fonte única de verdade sobre o DECKARD.

---

## Identificação

| Campo | Valor |
|-------|-------|
| **Modelo** | Compaq Presario CQ-17 |
| **CPU** | Intel Celeron N3350 @ 1.10 GHz |
| **RAM** | 4 GB (3.6 GiB) |
| **Armazenamento** | SSD 464 GB — 6.8 GB usado (2%) |
| **OS** | Fedora 44 (Forty Four) — Sway spin |
| **Kernel** | Linux 6.19.10-300.fc44.x86_64 |
| **Sway** | 1.11 |
| **Uptime** | 18 dias |
| **Papel** | Fallback workstation, experimentação, retro |

---

## Rede

| Atributo | Valor |
|----------|-------|
| **IP Tailscale** | `{{TAILSCALE_IP_DECKARD}}` |
| **IP LAN** | `{{LAN_IP_DECKARD}}` |
| **Interface** | `wlp2s0` (Wi-Fi) |
| **Status** | ✅ Online (Tailscale ativo, ping/SSH respondendo) |

---

## Serviços

### Nativos (systemd)

| Serviço | Porta | Função |
|---------|-------|--------|
| **SSHD** | 22 | Acesso remoto |
| **Syncthing** | 22000 | Sincronização de arquivos |
| **NetworkManager** | — | Gerenciamento de rede |
| **firewalld** | — | Firewall |
| **sddm** | — | Display manager (Sway) |

> ⚠️ Sem Docker, sem containers, sem serviços web. Máquina enxuta.

---

## Armazenamento

Partição única `/dev/sda3` (btrfs) — 464 GB, 2% usado. Praticamente vazia.

---

## Particularidades

- **Sway puro:** Sem ambiente GNOME/KDE — configuração manual em `~/.config/sway/`
- **Sem Docker:** Ideal para experimentos que não devem contaminar a infraestrutura principal
- **Baixo consumo:** Celeron N3350 + 4GB — não roda LLMs locais nem cargas pesadas
- **Bateria:** Laptop antigo (2017) — normalmente conectado à tomada
- **Syncthing ativo:** Pode sincronizar dados com a malha Nexus se configurado

---

## Conexões

- [[00_Nexus/01_INFRA/hardware]] — Tabela resumo de hardware
- [[00_Nexus/01_INFRA/network]] — Topologia de rede
