# 🎬 Buster Friendly v2 (Media Engine - PRIS)

Este documento detalha a arquitetura de mídia de alta performance e estabilidade implementada na PRIS em Março/2026, substituindo o antigo orquestrador Riven.

## 🧬 A Nova Stack (*Arrs & Decypharr)

A stack foi migrada para o modelo **Decypharr Proxy**, que intercepta as chamadas dos *Arrs e simula um servidor de arquivos local, traduzindo as buscas para o Real-Debrid.

| Componente | Função | Configuração Chave |
| :--- | :--- | :--- |
| **Sonarr/Radarr** | Gestão de Biblioteca | `1080p Only`, `Max 9GB`, `Naming: IMDB ID included`. |
| **Decypharr** | Proxy de Busca/Filtro | `Timeout: 300s`, Workers: `1`. |
| **Prowlarr** | Indexadores | Comet (Feels Legal), Torrentio, MediaFusion. |
| **Zurg (Native)** | Mount Rclone | `repair_symlinks: true`, `check_vfs: true`. |
| **Jellyfin** | Streaming | Mapeamento direto via `/home/{{LINUX_USER}}/media/`. |

---

## 🩺 Protocolo de Transplante (Adoção de Biblioteca)

Para evitar re-downloads massivos, utilizamos scripts de migração "Safe" que movem os arquivos da era Riven para as pastas geridas pelos *Arrs.

### Fluxo de Adoção:
1.  **Origem:** `/home/{{LINUX_USER}}/media/shows_legacy` (Arquivos criados pelo Riven).
2.  **Destino:** `/home/{{LINUX_USER}}/media/shows` (Estrutura limpa dos *Arrs).
3.  **Matching:** O script `migrate_sonarr_safe.sh` realiza o cruzamento de nomes e **IMDB IDs** para garantir que os arquivos caiam na pasta correta, mesmo com nomes de release diferentes.

### Status de Março/2026:
*   **Filmes:** 100% migrados e indexados.
*   **Séries:** Processamento intensivo em andamento (~20k episódios).
*   **Bazarr:** Mantido em "Standby" (Exited) até a conclusão total do scan do Jellyfin para evitar contenção de I/O.

---

## ⚠️ Mandatos de Sobrevivência (PRIS)

1.  **CPU/IO Wait:** Durante o Scan de Biblioteca, não reiniciar o container do Jellyfin sob nenhuma circunstância para evitar corrupção do `library.db`.
2.  **Scraping Workers:** NUNCA aumentar o limite de scraping do Decypharr além de **1**. O Real-Debrid aplica Rate Limit (Erro 429) se detectado uso agressivo.
3.  **Ordem de Boot:**
    - (1) `zurg.service` (Systemd)
    - (2) `docker-compose up -d postgres redis`
    - (3) `docker-compose up -d sonarr radarr decypharr`
    - (4) `docker-compose up -d jellyfin` (Somente após mount estável).
