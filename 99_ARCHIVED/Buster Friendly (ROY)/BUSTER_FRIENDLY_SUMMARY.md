# 🚀 Buster Friendly ROY - Resumo Completo

## 📋 Visão Geral
Sistema completo de media automation implementado no ROY ({{LAN_IP_ROY}}) com configuração otimizada para baixa carga de sistema.

## 🏗️ Arquitetura do Sistema

### Nodes e Conectividade
- **ROY**: {{LAN_IP_ROY}} (Host principal)
- **PRIS**: {{TAILSCALE_IP_PRIS}} (Media server original)
- **UBIK**: {{TAILSCALE_IP_UBIK}} (Workstation source)
- **Conectividade**: SSH via chave, Tailscale

### Stack Tecnológico
```
RCLONE + ZURG (WebDAV) → Real Debrid
    ↓
Docker Containers (LinuxServer.io)
    ↓
Media Management (ARR Stack)
    ↓
Debrid Client (Decypharr)
```

## 📊 Serviços Implementados

### Fase 1 - RCLONE + ZURG ✅
- **Zurg**: v0.9.3-final (localhost:9999)
- **Rclone**: WebDAV → Zurg
- **Mount**: `/mnt/zurg` (Real Debrid)
- **Token RD**: XWIDIDXQQN2E5GVE5DA3REGJIYCY53RL6H5ZKH6YP7G2WLGVJA4Q

### Fase 2 - Prowlarr ✅
- **Porta**: 9696
- **API Key**: `8ed1dd73a2554d5bb09a21a0053e3526`
- **Função**: Indexer management

### Fase 3 - Radarr + Sonarr ✅
- **Radarr**: 7878 | API: `b1f5b772cc5041a398005e1e05e08d5a`
- **Sonarr**: 8989 | API: `9f545b2728b64e5d9bda3eec1363d81b`
- **Movies**: 1744 registros
- **Series**: 384 registros
- **Paths**: `/mnt/media/movies/` e `/mnt/media/tv/`

### Fase 4 - Decypharr ✅
- **Porta**: 8282
- **Versão**: v2.2 (API v4.3.2)
- **Modo**: WebDAV (sem mount)
- **Integração**: Download client para Radarr/Sonarr

### Fase 5 - Bazarr ✅
- **Porta**: 6767
- **API Key**: `965dae656248f369ad2f5f03f0b13465`
- **Config**: Otimizada para carga reduzida
- **Providers**: opensubtitlescom, legendasnet, subsource

### Fase 5 - Jellyseerr ✅
- **Status**: Integrado cross-node
- **Localização**: PRIS ({{TAILSCALE_IP_PRIS}}:5055)
- **Configuração**: Conectado aos ARR no ROY
- **Fluxo**: Jellyseerr → Prowlarr → Radarr/Sonarr → Decypharr

### Fase 6 - NFS para Jellyfin ⏳
- **Status**: Pendente
- **Objetivo**: Exportar `/mnt/media/` via NFS para PRIS
- **Destino**: Jellyfin acessar conteúdo do ROY

## 🔧 Configuração Otimizada

### Parâmetros de Performance
- **CPU Limit**: 0.5-1.0 cores por container
- **RAM Limit**: 512MB-1GB por container  
- **Sync Frequency**: 6-24h (em vez de contínuo)
- **Concurrent Jobs**: 1-2 jobs simultâneos

### Paths Corrigidos
```bash
# De:/media/movies/    Para:/mnt/media/movies/
# De:/media/shows/     Para:/mnt/media/tv/

# Comandos SQL executados:
UPDATE Movies SET path = REPLACE(path, '/media/movies', '/mnt/media/movies');
UPDATE Series SET path = REPLACE(path, '/media/shows', '/mnt/media/tv');
UPDATE RootFolders SET path = '/mnt/media/movies' WHERE path = '/media/movies';
UPDATE RootFolders SET path = '/mnt/media/tv' WHERE path = '/media/shows';
```

## 📁 Estrutura de Diretórios

```
~/docker/buster-friendly/
├── config/
│   ├── prowlarr/
│   ├── radarr/
│   ├── sonarr/
│   ├── bazarr/
│   └── decypharr/
├── backups/                 # Backups dos bancos .db
├── bazarr-docker-compose.yml
└── (outros compose files)

/mnt/
├── zurg/                   # Real Debrid mount
└── media/                  # Estrutura organizada
    ├── movies/            # Symlinks para conteúdo
    └── tv/                # Symlinks para conteúdo
```

## 🌐 Portas e Endpoints

| Serviço       | Porta | Host | API Key | Status |
|---------------|-------|------|---------|---------|
| **Jellyseerr** | 5055  | PRIS | (Web UI) | ✅ |
| **Prowlarr**  | 9696  | ROY | `8ed1d...` | ✅ |
| **Radarr**    | 7878  | ROY | `b1f5b...` | ✅ |
| **Sonarr**    | 8989  | ROY | `9f545...` | ✅ |
| **Bazarr**    | 6767  | ROY | `965da...` | ✅ |
| **Decypharr** | 8282  | ROY | (API v2) | ✅ |
| **Zurg**      | 9999  | ROY | (WebDAV) | ✅ |

## 🚀 Comandos de Verificação

### Check Básico
```bash
# Verificar mount Zurg
ls /mnt/zurg

# Verificar estrutura media
ls -la /mnt/media/

# Verificar todos os containers
docker ps --filter "name=prowlarr|radarr|sonarr|bazarr"

# Testar APIs
curl http://localhost:7878/api/v3/system/status?apikey=REDACTED
curl http://localhost:8989/api/v3/system/status?apikey=REDACTED
curl http://localhost:9696/api/v1/system/status?apikey=REDACTED
curl http://localhost:6767/api/system/status
curl http://localhost:8282/api/v2/app/version
```

### Monitoramento de Recursos
```bash
# CPU/Memory usage
docker stats --no-stream

# Logs em tempo real
docker logs -f radarr
docker logs -f sonarr

# Network status
ss -tlnp | grep -E '(7878|8989|9696|6767|8282)'
```

## 🛡️ Protocolos de Segurança

### Regras Obrigatórias
1. ✅ Sempre validar `/mnt/zurg` antes de ações
2. ✅ Parar containers antes de editar bancos .db  
3. ✅ Backup prévio de bancos antes de modificações
4. ✅ Registrar tudo no `04_IMPLEMENTATION_LOG.md`
5. ✅ Explicar plano e aguardar aprovação HITL

### Limites de Sistema
- **Load Average > 4.0**: Abortar operações I/O
- **Mount congelado**: `sudo umount -l /mnt/zurg` + análise
- **Erros múltiplos**: Escalar para Debugger

## 📈 Métricas de Performance

### Antes (PRIS)
- Carga CPU: Alta (containers não otimizados)
- Sync: Contínuo/agressivo
- Recursos: Sem limites
- Paths: `/media/` (hardcoded)

### Depois (ROY)
- Carga CPU: Baixa (containers limitados)
- Sync: Moderado (6-24h)
- Recursos: CPU 0.5, RAM 512MB
- Paths: `/mnt/media/` (corrigidos)

## 🔄 Fluxo Completo

```
Usuário → Jellyseerr (PRIS) → Solicitação
    ↓
Prowlarr (ROY) → Encontra indexers
    ↓
Radarr/Sonarr (ROY) → Adiciona à queue
    ↓
Decypharr (ROY) → Processa pelo Real Debrid
    ↓
Zurg (ROY) → Disponibiliza via /mnt/zurg
    ↓
Bazarr (ROY) → Legendas automáticas
    ↓
Conteúdo disponível em /mnt/media/
```

## 🎯 Próximos Passos

### Fase 6 - Jellyseerr
- Manter na PRIS inicialmente
- Configurar integração cross-node
- Documentar fluxo completo

### Otimizações Futuras
- Monitoramento Prometheus/Grafana
- Alertas de saúde do sistema
- Backup automatizado de configurações
- Documentação de troubleshooting

---
**Status**: Fase 5 COMPLETA ✅
**Data**: 26/04/2026
**Implementado por**: Engenheiro Nexus Squad