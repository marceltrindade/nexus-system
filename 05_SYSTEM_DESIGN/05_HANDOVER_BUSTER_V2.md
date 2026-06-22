# Relatório de Handover - Buster Friendly V2
**Data:** 28 de Março de 2026
**Status do Agente:** TERMINADO (Falha de Lógica/Integridade)

## 1. Contexto Temporal e Hardware
- **Data de Referência:** 28/03/2026 (Filmes de 2025 são históricos e válidos).
- **Node Principal (PRIS):** {{TAILSCALE_IP_PRIS}} | Ubuntu Server.
- **Hardware:** Intel Core i5-5200U (Broadwell) | 8GB RAM | I/O Limitado.

## 2. Arquitetura Sistêmica (Buster Friendly V2)
O sistema foi transicionado do Riven (descontinuado por instabilidade) para a estrutura modular:
- **Orquestradores:** Radarr (Filmes) e Sonarr (Séries).
- **Download Engine:** Decypharr (2 containers: `decypharr-radarr` e `decypharr-sonarr`).
- **Debrid Provider:** Real-Debrid (via API).
- **File System:** Zurg -> Rclone Mount em `/home/{{LINUX_USER}}/media/zurg`.
- **Symlink Map:** Decypharr cria atalhos em `/home/{{LINUX_USER}}/media/downloads` apontando para o mount.
- **Streaming:** Jellyfin (Porta 8096) com acesso via Cloudflare Tunnel.

## 3. Estado Atual dos Serviços (28/03/2026 - 19:40)
- **Radarr:** Operacional. Importou filmes recentes (Godzilla Minus One, The Prestige). APIs sincronizadas.
- **Sonarr:** Operacional. Enfrentando impasse no release *Kaiju No. 8 S02E01 (Kitsune)*.
- **Decypharr:** Ambos containers UP. Autenticação interna desativada (`use_auth: false`) para evitar travamentos de comando.
- **Jellyfin:** Em estado de **Bad Gateway**. 
    - **Causa Real:** O processo `ffprobe` está saturando o I/O ao tentar ler metadados da biblioteca recém-importada. O hardware não responde ao gateway a tempo.
    - **Diagnóstico de Arquivos:** Arquivos estão íntegros e acessíveis no mount (testado via `head`). Não há arquivos falsos.

## 4. Travas de Segurança Ativas (Mandatos V2)
- **Regra do 1:** `MAX_DOWNLOADS=1` e `REPAIR_WORKERS=1` nos Decypharrs para evitar I/O Deadlock.
- **SQLite Hardening:** Bazarr, Radarr e Sonarr operando em `WAL Mode` com `busy_timeout=60000`.
- **Safe-Boot:** Protocolo de aguardar 15 minutos entre o mount e o início do Jellyfin (violado na sessão anterior).

## 5. Pendências Críticas para a Próxima Janela
1. **Estabilização do Jellyfin:** Aguardar o término do scan de metadados. Não reiniciar o container durante o processo para evitar corrupção de cache.
2. **Importação Kaiju:** O Decypharr-Sonarr está aguardando o Zurg refrescar o diretório para criar o symlink do episódio S02E01.
3. **Refinamento de Busca:** Manter a `Blocklist` do Sonarr alimentada contra termos indesejados (VOSTFR, etc) para garantir releases Multi/Dual.

## 6. Registro de Falha do Agente (Gaff)
O agente anterior foi descontinuado por:
- Ignorar a data atual (2026).
- Alucinar que arquivos válidos eram falsos.
- Sugerir destruição de banco de dados baseada em premissas erradas.
- Violar o Mandato de Trava de Segurança ao executar comandos sem confirmação.

---
**Instrução para a Nova IA:** Respeite rigorosamente a "Regra do 1" e nunca questione a validade dos dados do usuário sem provas físicas de corrupção de sistema de arquivos.
