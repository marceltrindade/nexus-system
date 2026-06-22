# 🚀 Buster Friendly ROY - Media Automation Stack

Sistema completo de automação de mídia implementado no ROY ({{LAN_IP_ROY}}) com configuração otimizada para baixa carga de sistema.

## 📋 Status do Projeto

### ✅ Fases Concluídas
1. **Fase 1**: RCLONE + ZURG (Real Debrid mount)
2. **Fase 2**: Prowlarr (Indexer management)  
3. **Fase 3**: Radarr + Sonarr (Media management)
4. **Fase 4**: Decypharr (Debrid client)
5. **Fase 5**: Bazarr + Jellyseerr (Subtitles + Frontend)

### ⏳ Próxima Fase
6. **Fase 6**: NFS ROY→PRIS para Jellyfin

## 🌐 Serviços em Execução

| Serviço | Porta | Host | Status | Descrição |
|---------|-------|------|---------|-----------|
| **Jellyseerr** | 5055 | PRIS | ✅ | Frontend de solicitações |
| **Prowlarr** | 9696 | ROY | ✅ | Gerenciamento de indexers |
| **Radarr** | 7878 | ROY | ✅ | Gerenciamento de filmes |
| **Sonarr** | 8989 | ROY | ✅ | Gerenciamento de séries |
| **Bazarr** | 6767 | ROY | ✅ | Legendas automáticas |
| **Decypharr** | 8282 | ROY | ✅ | Client Real Debrid |
| **Zurg** | 9999 | ROY | ✅ | WebDAV para Real Debrid |

## 📁 Documentação

### 📄 Documentos Principais
- **[AGENTS.md](./AGENTS.md)** - Protocolos operacionais e status do projeto
- **[BUSTER_FRIENDLY_SUMMARY.md](./BUSTER_FRIENDLY_SUMMARY.md)** - Visão geral completa do sistema
- **[BAZARR_IMPLEMENTATION.md](./BAZARR_IMPLEMENTATION.md)** - Detalhes da implementação do Bazarr

### 🔧 Documentos Técnicos
- **[DEBUG_SAFETY.md](./DEBUG_SAFETY.md)** - Protocolos de segurança e troubleshooting
- **[TOOL_CONTRACTS.md](./TOOL_CONTRACTS.md)** - Contratos de ferramentas e comandos
- **[Dossiê Técnico](./# 📄 DOSSIÊ TÉCNICO — BUSTER FRIENDLY (ROY NODE).md)** - Documentação técnica detalhada

### ⚙️ Configurações
- **[decypharr_config.json](./decypharr_config.json)** - Configuração do Decypharr

## 🚀 Quick Start

### Verificação Rápida
```bash
# Verificar todos os serviços
docker ps --filter "name=prowlarr|radarr|sonarr|bazarr"

# Verificar mount Zurg
ls /mnt/zurg

# Verificar estrutura media
ls -la /mnt/media/
```

### URLs de Acesso
- **Radarr**: http://{{LAN_IP_ROY}}:7878
- **Sonarr**: http://{{LAN_IP_ROY}}:8989  
- **Prowlarr**: http://{{LAN_IP_ROY}}:9696
- **Bazarr**: http://{{LAN_IP_ROY}}:6767

## ⚡ Configuração Otimizada

O sistema foi configurado com foco em **baixa carga de sistema**:
- **CPU Limitada**: 0.5-1.0 cores por container
- **RAM Limitada**: 512MB-1GB por container
- **Sync Moderado**: 6-24h entre sincronizações
- **Jobs Simultâneos**: 1-2 jobs máximo

## 🛡️ Segurança

### Protocolos Obrigatórios
1. ✅ Validar `/mnt/zurg` antes de qualquer ação
2. ✅ Parar containers antes de editar bancos .db
3. ✅ Backup prévio de bancos antes de modificações
4. ✅ Registrar tudo no log de implementação
5. ✅ Explicar plano e aguardar aprovação HITL

### Limites de Sistema
- **Load Average > 4.0**: Abortar operações I/O
- **Mount congelado**: Executar `sudo umount -l /mnt/zurg`

## 📊 Log de Implementação

Todo o histórico de implementação está documentado em:
`/mnt/almox/JD/00-09 System/05 Architecture/Nexus-Docs/04_IMPLEMENTATION_LOG.md`

## 🔗 Integração com Ecossistema

- **PRIS**: {{TAILSCALE_IP_PRIS}} (Media server original)
- **UBIK**: {{TAILSCALE_IP_UBIK}} (Workstation source) 
- **VALIS**: {{TAILSCALE_IP_VALIS}} (Infra e Forgejo)

---
**Última atualização**: 26/04/2026  
**Status**: Fase 5 COMPLETA ✅  
**Responsável**: Engenheiro Nexus Squad