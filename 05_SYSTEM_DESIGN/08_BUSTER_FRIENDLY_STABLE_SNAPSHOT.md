# 📸 08_BUSTER_FRIENDLY_STABLE_SNAPSHOT: Estado Atual do Ecossistema Buster Friendly

## 📋 Metadados

| Atributo | Detalhe |
|----------|---------|
| **Código** | 08_BUSTER_FRIENDLY_STABLE_SNAPSHOT |
| **Status** | Estável |
| **Data** | 12/04/2026 |
| **Autor** | MCP (Multi-Cognitive Processor) |
| **Revisor** | Marcel Trindade |

## 📝 Histórico de Alterações

| Data | Versão | Alteração | Autor |
|------|--------|-----------|-------|
| 12/04/2026 | 1.0 | Documentação do estado estável do ecossistema Buster Friendly | MCP |

---

## 1. Introdução e Governança

Este documento captura o estado atual do ecossistema Buster Friendly na PRIS, após a resolução do problema de caminho no Decypharr. O sistema está operando de forma estável com os serviços principais ativos e funcionando corretamente.

## 2. Especificações Técnicas

### 2.1 Nó PRIS (Media Server)

- **IP Tailscale**: `{{TAILSCALE_IP_PRIS}}`
- **Hardware**: i5-5200U (hardware limitado, operações serializadas)
- **Sistema**: Ubuntu 26.04 LTS

### 2.2 Serviços Críticos Ativos

#### 2.2.1 Stack de Mídia (dumb-prod)
- **Container**: `dumb-prod` (iampuid0/dumb:latest)
- **Status**: Healthy, uptime 31 minutos
- **Portas expostas**:
  - 3006:3005 (Profilarr)
  - 7880:7878 (Radarr)
  - 8001:8000 (Decypharr)
  - 8991:8989 (Sonarr)
  - 9698:9697 (Prowlarr)

#### 2.2.2 Serviços Adicionais
- **Jellyfin**: Ativo, uptime 39 minutos (porta 8096)
- **Cloudflared-tunnel**: Ativo, uptime 39 minutos
- **n8n**: Ativo, uptime 39 minutos (automação)
- **Syncthing**: Ativo, healthy (sincronização de arquivos)
- **Home Assistant**: Ativo, uptime 39 minutos

#### 2.2.3 Serviços do Sistema
- **zurg-app.service**: Ativo (gerenciamento Real-Debrid)
- **zurg.service**: Ativo (mount rclone)
- **nexus-play-mode.service**: Ativo (gerenciamento de downloads durante playback)

### 2.3 Serviços Inativos
- **jellyseerr**: Inativo (desligado)
- **bazarr**: Inativo (desligado, legado)

## 3. Estado de Saúde Atual

### 3.1 Carga do Sistema
- **Load Average**: 3.87, 3.55, 3.43 (alto, mas dentro do esperado para o hardware)
- **Tempo de atividade**: 40 minutos desde o último reboot
- **Usuários ativos**: 3

### 3.2 Processos em Estado D
- **Processos em estado D**: 2 (relacionados ao ffprobe do Sonarr)
- **Observação**: Número aceitável considerando as operações de mídia

### 3.3 Integração Funcional
- **Pipeline Real-Debrid → Zurg → Decypharr → Radarr/Sonarr → Jellyfin**: Funcional
- **Download de conteúdo**: Operando corretamente após correção de caminho
- **Streaming via Jellyfin**: Funcional

## 4. Considerações de Operação

### 4.1 Limitações de Hardware
- Hardware i5-5200U de 5ª geração com limitações de I/O
- Operações paralelas evitadas para prevenir travamentos
- Workers e transfers limitados a 1 para proteger o I/O

### 4.2 Protocolos de Operação
- **Ordem de boot**: zurg-app → zurg → (15 min quarentena) → decypharr-radarr/sonarr → jellyfin
- **Play-Mode**: Ativo, pausa downloads durante streaming
- **Quarentena de I/O**: Respeitada após reinicialização de mount

### 4.3 Estrutura de Caminhos
- **Montagem Zurg**: `/home/{{LINUX_USER}}/media/zurg` (symlink: `/zurg`)
- **Downloads**: `/mnt/debrid/decypharr_downloads/`
- **Symlinks**: `/mnt/debrid/decypharr_symlinks/`

## 5. Status dos Componentes

| Componente | Status | Observações |
|------------|--------|-------------|
| Zurg App | ✅ Ativo | Gerencia torrents e links Real-Debrid |
| Zurg Mount | ✅ Ativo | Monta sistema de arquivos rclone |
| Decypharr | ✅ Funcional | Após correção de caminho remoto |
| Radarr | ✅ Ativo | Acessando caminhos corretos |
| Sonarr | ✅ Ativo | Acessando caminhos corretos |
| Jellyfin | ✅ Ativo | Streaming funcional |
| Prowlarr | ✅ Ativo | Indexadores configurados |
| Bazarr | ❌ Inativo | Legado, não em uso |
| Jellyseerr | ❌ Inativo | Legado, não em uso |

## 6. Considerações Finais

O ecossistema Buster Friendly está em estado estável após a resolução do problema de caminho no Decypharr. A integração entre todos os serviços está funcionando corretamente, com o pipeline de download e streaming operando como esperado. O sistema está preparado para operação contínua com os protocolos de quarentena de I/O sendo respeitados.

A correção das configurações de caminho remoto/local no Radarr e Sonarr resolveu o problema de permissão que impedia a criação de diretórios temporários pelo Decypharr, restaurando o funcionamento completo do pipeline de mídia.

*Assinado: MCP (Multi-Cognitive Processor), Agente de Documentação do Nexus*