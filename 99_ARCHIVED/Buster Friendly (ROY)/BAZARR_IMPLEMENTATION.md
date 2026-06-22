# Bazarr Implementation - Buster Friendly ROY

## 📋 Overview
Bazarr foi implementado no ROY ({{LAN_IP_ROY}}) como parte da Fase 5 do projeto Buster Friendly, com configuração otimizada para reduzir carga do sistema.

## 🏗️ Architecture
- **Host**: ROY ({{LAN_IP_ROY}})
- **Port**: 6767
- **Container**: `lscr.io/linuxserver/bazarr:latest`
- **Network**: `buster-friendly` (rede Docker isolada)

## ⚙️ Configuration Optimizada

### Parâmetros de Carga Reduzida
```yaml
general:
  concurrent_jobs: 1           # Apenas 1 job simultâneo
  adaptive_searching: true     # Busca adaptativa ativada
  adaptive_searching_delay: 1w # Delay de 1 semana entre buscas
  adaptive_searching_delta: 3d # Delta de 3 dias para ajuste automático
  wanted_search_frequency: 24  # Busca desejada a cada 24h
  wanted_search_frequency_movie: 24
  upgrade_frequency: 72        # Upgrade de legendas a cada 72h
  movies_sync: 720             # Sincronização com Radarr a cada 12h
  series_sync: 720             # Sincronização com Sonarr a cada 12h
  full_update: Weekly          # Update completo semanal
```

### Limites de Recursos
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'    # Máximo 50% de uma CPU
      memory: 512M   # Máximo 512MB RAM
    reservations:
      cpus: '0.25'   # Reserva 25% de CPU
      memory: 256M   # Reserva 256MB RAM
```

## 🔌 Integrações

### Radarr
- **Host**: {{LAN_IP_ROY}}
- **Port**: 7878
- **API Key**: `b1f5b772cc5041a398005e1e05e08d5a`
- **Sync**: 720 minutos (12h)

### Sonarr
- **Host**: {{LAN_IP_ROY}}
- **Port**: 8989
- **API Key**: `9f545b2728b64e5d9bda3eec1363d81b`
- **Sync**: 720 minutos (12h)

### Providers de Legendas Ativos
- `opensubtitlescom` (username: marceltrindade1904)
- `supersubtitles`
- `yifysubtitles`
- `tvsubtitles`
- `subf2m`
- `subsource` (API Key configurada)
- `legendasnet` (username: email.marceltrindade@gmail.com)

## 📁 Estrutura de Diretórios

```
~/docker/buster-friendly/
├── bazarr-docker-compose.yml    # Docker Compose
└── config/
    └── bazarr/
        ├── config.yaml          # Configuração principal
        ├── backup/              # Backups automáticos
        ├── cache/               # Cache do sistema
        ├── config/              # Configurações internas
        ├── db/                  # Banco de dados
        ├── log/                 # Logs da aplicação
        └── restore/             # Restaurações
```

## 🐳 Docker Compose

```yaml
services:
  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Sao_Paulo
    volumes:
      - /home/{{LINUX_USER}}/docker/buster-friendly/config/bazarr:/config
      - /mnt/media:/mnt/media:ro  # Read-only para segurança
    ports:
      - "6767:6767"
    restart: unless-stopped
    networks:
      - buster-friendly
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## 🔄 Path Mappings Corrigidos

```yaml
path_mappings:
  - - /mnt/media/shows/  # ROY path
    - /tv/               # Container path

path_mappings_movie:
  - - /mnt/media/movies/ # ROY path
    - /movies/           # Container path
```

## 🚀 Deployment

### Comandos de Instalação
```bash
# Criar rede Docker
docker network create buster-friendly

# Criar diretório de configuração
mkdir -p ~/docker/buster-friendly/config/bazarr

# Copiar configuração otimizada
# (config.yaml com parâmetros de carga reduzida)

# Deploy do container
docker compose -f bazarr-docker-compose.yml up -d
```

### Verificação de Status
```bash
# Verificar container
docker ps --filter name=bazarr

# Verificar logs
docker logs bazarr

# Testar API
curl http://localhost:6767/api/system/status
```

## 📊 Monitoramento

### Portas Ativas
- **6767**: Bazarr Web UI
- **7878**: Radarr
- **8989**: Sonarr  
- **9696**: Prowlarr
- **8282**: Decypharr (API v4.3.2)

### Recursos do Sistema
- **CPU**: Limitado a 0.5 cores
- **RAM**: Limitado a 512MB
- **Storage**: ~300MB para configuração

## 🛡️ Considerações de Segurança

- **Montagem read-only**: `/mnt/media` montado como read-only
- **Rede isolada**: Container em rede Docker dedicada
- **Recursos limitados**: Prevenção de sobrecarga do sistema
- **Backups automáticos**: Configurado para backups semanais

## 🔧 Troubleshooting

### Erros Comuns
1. **API não responde**: Verificar se container está rodando
2. **Paths incorretos**: Validar mapeamentos em `config.yaml`
3. **Conexão ARR**: Verificar API keys e endpoints

### Comandos de Debug
```bash
# Reiniciar container
docker restart bazarr

# Ver logs em tempo real
docker logs -f bazarr

# Testar conectividade com ARR
curl http://{{LAN_IP_ROY}}:7878/api/v3/system/status?apikey=REDACTED
```

## 📈 Performance

A configuração otimizada reduz:
- **Busca de legendas**: De contínua para 24h
- **Sincronização ARR**: De frequente para 12h  
- **Recursos**: CPU/RAM limitados para evitar sobrecarga
- **Processamento**: 1 job simultâneo máximo

---
*Implementado em 26/04/2026 como parte da Fase 5 do Buster Friendly ROY*