---
tags:
  - node
  - infra
created: 2026-06-22
updated: 2026-06-22
---

# 🖥️ VALIS — Node de Infraestrutura

> Fonte única de verdade sobre o VALIS. Qualquer outra referência deve apontar para este documento.

---

## Identificação

| Campo | Valor |
|-------|-------|
| **Modelo** | Lenovo ideapad 330-15IKB |
| **CPU** | Intel Core i3-7020U |
| **RAM** | 4 GB (3.7 GiB disponíveis) |
| **GPU** | Intel HD Graphics 620 |
| **OS** | Ubuntu 24.04.4 LTS |
| **Kernel** | Linux 6.8.0-100-generic |
| **Uptime** | 116+ dias (extremamente estável) |
| **Papel** | Infraestrutura de rede, DNS, serviços persistentes, armazenamento |

---

## Armazenamento

| Disco | Tipo | Tamanho | Uso | Montagem |
|-------|------|---------|-----|----------|
| `sda` | SSD interno (LVM) | 914 GB | 209 GB (24%) | `/` |
| `sdb` | HD externo | 916 GB | 650 GB (75%) | `/home/{{LINUX_USER}}/mnt_externo` |

### HD externo — `/home/{{LINUX_USER}}/mnt_externo`

| Conteúdo | Descrição |
|----------|-----------|
| `backups/`, `Backups/`, `Backup_Recuperados_Ubik/` | Backups de sistema e vaults |
| `bkp_imagens/` | Backup de imagens |
| `downloads/` | Downloads diversos |
| `media/`, `Media/` | Mídia (Buster Friendly, acervo) |
| `timeshift/` | Snapshots Timeshift |

---

## Rede

### Tailscale Mesh

| Atributo | Valor |
|----------|-------|
| **IP Tailscale** | `{{TAILSCALE_IP_VALIS}}` |
| **DNS local** | `valis.home` |
| **IP LAN** | `{{LAN_IP_VALIS}}` |
| **Status** | ✅ Ativo (conexão direta) |

> ⚠️ `valis.home` não resolve do UBIK — pendente configurar Pi-hole como DNS.

---

## Serviços Docker

### 🟢 Rodando

| Serviço | Porta | Status | Uptime | Função |
|---------|-------|--------|--------|--------|
| **pihole** | 53, 8082 | healthy | 7 dias | DNS Master + Ad-blocking |
| **unbound** | — | up | 4 semanas | DNS recursivo (upstream do Pi-hole) |
| **cloudflared-tunnel** | — | up | 3 dias | Cloudflare Zero Trust Tunnel |
| **vaultwarden** | 8086 | healthy | 7 semanas | Gerenciador de senhas |
| **forgejo** | 3000, 222 | healthy | 2 meses | Servidor Git privado (Tailscale) |
| **it-tools** | 8084 | healthy | 2 meses | Canivete de ferramentas dev |
| **audiobookshelf** | 13378 | up | 3 semanas | Biblioteca de audiobooks |
| **transmission** | 9091, 51413 | up | 12 dias | Cliente BitTorrent (audiobooks) |
| **filebrowser** | 8083 | healthy | 9 dias | Acesso remoto a arquivos |
| **searxng** | 8080 | up | 31 horas | Motor de busca privado |
| **hledger** | 5000 | healthy | 3 horas | Contabilidade financeira |
| **hoarder (Karakeep)** | 3100 | healthy | 3 dias | Bookmark manager (3 containers: web, chrome, meilisearch) |
| **qdrant** | 6333 | up | 3 dias | Vector DB (SB RAG — busca semântica) |

### 🔴 Removidos / Parados

| Serviço | Status | Motivo |
|---------|--------|--------|
| **NPM** (Nginx Proxy Manager) | Exited (22h) | Parado — sem uso atual |
| **Ocular** | Removido | Substituído pelo hledger |
| **Watchtower** | Removido | Atualização manual preferida |

### 📁 Stacks Docker

| Stack | Caminho | Serviços |
|-------|---------|----------|
| `infrastructure` | `~/docker/stacks/infrastructure/` | pihole, unbound, it-tools |
| `knowledge` | `~/docker/stacks/knowledge/` | searxng, qdrant |
| `files` | `~/docker/stacks/files/` | filebrowser |
| `cloudflared` | `~/docker/cloudflared/` | cloudflared-tunnel |
| `forgejo` | `~/docker/forgejo/` | forgejo |
| `hledger` | `~/docker/hledger/` | hledger |
| `hoarder` | `~/docker/hoarder/` | hoarder (web + chrome + meilisearch) |
| `vaultwarden` | `~/.homebutler/apps/vaultwarden/` | vaultwarden |
| `audiobooks-stack` | `~/.homebutler/apps/audiobooks-stack/` | audiobookshelf, transmission |

### Serviços Systemd

| Serviço | Status | Função |
|---------|--------|--------|
| `docker.service` | ✅ ativo | Docker Engine |
| `syncthing@marcel.service` | ✅ ativo | SyncThing (porta 8384) |

---

## Cloudflare Tunnels

Túneis ativos sob o domínio `{{CLOUDFLARE_DOMAIN}}` — todas as rotas apontam para o VALIS exceto onde indicado.

| Domínio | Serviço | Destino |
|---------|---------|---------|
| `vault.{{CLOUDFLARE_DOMAIN}}` | Vaultwarden | `{{TAILSCALE_IP_VALIS}}:8086` |
| `audiobook.{{CLOUDFLARE_DOMAIN}}` | Audiobookshelf | `{{TAILSCALE_IP_VALIS}}:13378` |
| `drive.{{CLOUDFLARE_DOMAIN}}` | File Browser | `{{TAILSCALE_IP_VALIS}}:8083` |
| `search.{{CLOUDFLARE_DOMAIN}}` | SearXNG | `{{TAILSCALE_IP_VALIS}}:8080` |
| `git.{{CLOUDFLARE_DOMAIN}}` | Forgejo | `{{TAILSCALE_IP_VALIS}}:3000` |
| `budget.{{CLOUDFLARE_DOMAIN}}` | ~~Ocular~~ ❌ (removido) | Trocar por hledger ou remover |
| `ha.{{CLOUDFLARE_DOMAIN}}` | Home Assistant | `{{TAILSCALE_IP_PRIS}}:8123` (PRIS) |
| `n8n.{{CLOUDFLARE_DOMAIN}}` | n8n | `n8n:5678` (PRIS) |

> **Rotas removidas (pendente limpeza no Cloudflare):** sonarr, radarr, prowlarr, bazarr, rdt, decypharr, jellyfin, locadora, rss — serviços da extinta stack Buster Friendly que não existem mais.

---

## Conexões

- [[00_Nexus/01_INFRA/hardware]] — Tabela resumo de hardware de todos os nós
- [[00_Nexus/01_INFRA/network]] — Topologia de rede Nexus
- [[00_Nexus/01_INFRA/docker_stack]] — Mapa de portas e serviços entre nós
- [[40_Life/Dividas Tecnicas/2026-06-12 VALIS - Diagnostico]] — Diagnóstico original (arquivado)
