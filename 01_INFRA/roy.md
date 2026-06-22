---
tags:
  - node
  - media
created: 2026-06-22
updated: 2026-06-22
---

# 🤖 ROY — Kodi Media Center

> Fonte única de verdade sobre o ROY.

---

## Identificação

| Campo | Valor |
|-------|-------|
| **Modelo** | Dell Inspiron 5447 |
| **CPU** | Intel Core i5-4210U @ 1.70 GHz |
| **RAM** | 4 GB (3.6 GiB) |
| **Armazenamento** | HDD interno 914.8 GB — 3.5 GB usado (0%) |
| **OS** | LibreELEC 12.2.1 (official) |
| **Kernel** | Linux 6.16.12 |
| **Uptime** | 2 dias |
| **Kodi** | 21.x Omega |
| **Skin** | Arctic Zephyr 2 Resurrection Mod |
| **Papel** | Media center na TV (HDMI) |

---

## Rede

| Atributo | Valor |
|----------|-------|
| **IP LAN** | `{{LAN_IP_ROY}}` |
| **Interface** | `wlan0` (Wi-Fi) |
| **Tailscale** | ❌ Não instalado |
| **Conexão** | Wi-Fi apenas — cabo ethernet (`eth0`) desconectado |

> ⚠️ Wake-on-LAN ativado via `eth0` mas não funciona no Wi-Fi. Requer cabo ethernet.

---

## Armazenamento — `/storage` (914.8 GB)

Montado em `/dev/sda2` (label: "Storage"), formato ext4. Praticamente vazio — 3.5 GB usados de 914.8 GB.

| Caminho | Conteúdo |
|---------|----------|
| `backup/` | Backups do sistema |
| `downloads/` | Downloads diversos |
| `music/` | Música |
| `pictures/` | Imagens |
| `recordings/` | Gravações |
| `tvshows/`, `videos/` | Mídia organizada |
| `emulators/` | Emuladores (retro gaming) |
| `swapfile` | Arquivo de swap (2 GB) |

---

## Kodi — Addons Instalados

### Debrid

| Addon | Versão | Função |
|-------|--------|--------|
| **POV** | 6.05.12 | Debrid primário (Torbox) |
| **Umbrella** | 6.7.75 | Debrid fallback (Torbox) |

### Mídia

| Addon | Função |
|-------|--------|
| **YouTube** | Navegação YouTube |
| **Otaku** | Anime |
| **TMDB Helper** | Metadados TheMovieDB |

### Serviços

| Addon | Função |
|-------|--------|
| **Trakt** | Sincronização de histórico |
| **OpenSubtitles** | Legendas automáticas pt-BR |
| **SponsorBlock** | Pular patrocínios/intervalos |

### Metadata

| Addon | Função |
|-------|--------|
| `metadata.themoviedb.org.python` | Metadados filmes TMDB |
| `metadata.tvshows.themoviedb.org.python` | Metadados séries TMDB |
| `metadata.common.fanart.tv` | Fanart |
| `metadata.artists.universal` | Metadados artistas |
| `metadata.album.universal` | Metadados álbuns |

### Skins

| Addon | Versão |
|-------|--------|
| **Arctic Zephyr 2 Resurrection Mod** | Skin ativa |
| **Arctic Zephyr Mod** | Instalada |

### Repositórios

| Repo | Fornecedor |
|------|-----------|
| `repository.kodifitzwell` | Kodi Fitzwell |
| `repository.otaku` | Otaku |
| `repository.umbrellaplug.github.io` | Umbrella |

---

## Particularidades

- **Wi-Fi apenas:** Não está conectado por cabo ethernet — WoL não funciona
- **Sem Tailscale:** Acesso apenas via LAN local
- **Muito espaço livre:** 911 GB disponíveis — pode armazenar mídia local se necessário
- **LibreELEC:** Sistema appliance — sem Docker, sem arr stack, sem NFS
- **Conteúdo servido diretamente via Kodi na TV (HDMI)**

---

## Conexões

- [[00_Nexus/01_INFRA/hardware]] — Tabela resumo de hardware
- [[00_Nexus/01_INFRA/network]] — Topologia de rede
