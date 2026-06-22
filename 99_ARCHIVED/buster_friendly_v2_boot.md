# 🪜 Protocolo de Higienização Buster Friendly (Boot Sequencial)

Este protocolo foi desenhado para evitar o **Deadlock de I/O** (Estado D) no sistema de arquivos Rclone/Zurg, garantindo que o Jellyfin não trave o servidor PRIS ao tentar ler metadados massivos simultaneamente a outros processos.

## 🚀 Ordem de Execução Obrigatória

### Nível 0: Infraestrutura Base (DB & Cache)
*   **Ação:** Subir Banco de Dados e Redis.
*   **Comando:** `docker compose up -d postgres redis` (ou serviços equivalentes).
*   **Objetivo:** Garantir que os orquestradores tenham onde salvar estados.

### Nível 1: O Motor de Dados (Zurg)
*   **Ação:** Iniciar o serviço lógico do Zurg.
*   **Comando:** `sudo systemctl start zurg-app.service`
*   **Objetivo:** Estabelecer a ponte WebDAV com o Real-Debrid.

### Nível 2: O Ponto de Montagem (Mount)
*   **Ação:** Montar o sistema de arquivos virtual.
*   **Comando:** `sudo systemctl start zurg.service`
*   **Objetivo:** Disponibilizar os arquivos para o sistema operacional (FUSE).

### Nível 3: Orquestradores (Symlink Engine)
*   **Ação:** Subir as aplicações de gestão de mídia.
*   **Comando:** `docker compose up -d zilean jellyseerr sonarr radarr`
*   **Objetivo:** Organizar a biblioteca e processar a fila de downloads.

### Nível 4: O "Last Shot" (Jellyfin)
*   **Ação:** Iniciar o Player de Mídia ISOLADAMENTE.
*   **Comando:** `docker compose up -d jellyfin`
*   **Regra de Ouro:** NUNCA subir o Jellyfin simultaneamente aos outros serviços. Aguarde a estabilização do I/O do Nível 3.

---
*Documento oficial v1.0 - Armazenado no Almox (Nexus-Docs).*
