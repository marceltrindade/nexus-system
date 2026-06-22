# 📸 10_BUSTER_FRIENDLY_STABLE_SNAPSHOT_UPDATED: Estado Atual do Ecossistema Buster Friendly Após Atualizações

## 📋 Metadados

| Atributo | Detalhe |
|----------|---------|
| **Código** | 10_BUSTER_FRIENDLY_STABLE_SNAPSHOT_UPDATED |
| **Status** | Estável |
| **Data** | 12/04/2026 |
| **Autor** | MCP (Multi-Cognitive Processor) |
| **Revisor** | Marcel Trindade |

## 📝 Histórico de Alterações

| Data | Versão | Alteração | Autor |
|------|--------|-----------|-------|
| 12/04/2026 | 1.0 | Documentação do estado estável após atualização do nexus-play-mode | MCP |

---

## 1. Introdução e Governança

Este documento captura o estado atual do ecossistema Buster Friendly na PRIS, após a resolução do problema de caminho no Decypharr e a atualização do script do Nexus Play-Mode. O sistema está operando de forma estável com os serviços principais ativos e funcionando corretamente.

## 2. Especificações Técnicas

### 2.1 Nó PRIS (Media Server)

- **IP Tailscale**: `{{TAILSCALE_IP_PRIS}}`
- **Hardware**: i5-5200U (hardware limitado, operações serializadas)
- **Sistema**: Ubuntu 26.04 LTS

### 2.2 Serviços Críticos Ativos

#### 2.2.1 Stack de Mídia (dumb-prod)
- **Container**: `dumb-prod` (iampuid0/dumb:latest)
- **Status**: Healthy, uptime 1 hora+
- **Portas expostas**:
  - 3006:3005 (Profilarr)
  - 7880:7878 (Radarr)
  - 8001:8000 (Decypharr)
  - 8991:8989 (Sonarr)
  - 9698:9697 (Prowlarr)

#### 2.2.2 Serviços Adicionais
- **Jellyfin**: Ativo, uptime 1 hora+ (porta 8096)
- **Cloudflared-tunnel**: Ativo, uptime 1 hora+
- **n8n**: Ativo, uptime 1 hora+ (automação)
- **Syncthing**: Ativo, healthy (sincronização de arquivos)
- **Home Assistant**: Ativo, uptime 1 hora+

#### 2.2.3 Serviços do Sistema
- **zurg-app.service**: Ativo (gerenciamento Real-Debrid)
- **zurg.service**: Ativo (mount rclone)
- **nexus-play-mode.service**: Ativo (gerenciamento de downloads durante playback) - **ATUALIZADO**

### 2.3 Serviços Inativos
- **jellyseerr**: Inativo (legado)
- **bazarr**: Inativo (legado)

## 3. Estado de Saúde Atual

### 3.1 Carga do Sistema
- **Load Average**: Em níveis normais considerando o hardware
- **Tempo de atividade**: 1 hora+ desde o último reboot
- **Usuários ativos**: 3

### 3.2 Processos em Estado D
- **Processos em estado D**: Quantidade aceitável, relacionados a operações de mídia

### 3.3 Integração Funcional
- **Pipeline Real-Debrid → Zurg → Decypharr → Radarr/Sonarr → Jellyfin**: Funcional
- **Download de conteúdo**: Operando corretamente após correção de caminho
- **Streaming via Jellyfin**: Funcional
- **Controle de I/O**: Funcional com o novo script do Nexus Play-Mode

## 4. Considerações de Operação

### 4.1 Limitações de Hardware
- Hardware i5-5200U de 5ª geração com limitações de I/O
- Operações paralelas evitadas para prevenir travamentos
- Workers e transfers limitados a 1 para proteger o I/O

### 4.2 Protocolos de Operação
- **Ordem de boot**: zurg-app → zurg → (15 min quarentena) → decypharr-radarr/sonarr → jellyfin
- **Play-Mode**: Ativo, pausa downloads durante streaming - **ATUALIZADO**
- **Quarentena de I/O**: Respeitada após reinicialização de mount

### 4.3 Estrutura de Caminhos
- **Montagem Zurg**: `/home/{{LINUX_USER}}/media/zurg` (symlink: `/zurg`)
- **Downloads**: `/mnt/debrid/decypharr_downloads/`
- **Symlinks**: `/mnt/debrid/decypharr_symlinks/`

## 5. Atualizações Importantes

### 5.1 Atualização do Nexus Play-Mode
- **Antes**: Script com erros de parsing JSON e referências a containers antigos
- **Depois**: Script adaptado para a arquitetura dumb-prod, gerenciando processos internos
- **Benefício**: Eliminação de "engasgos" durante reprodução no Jellyfin
- **Persistência**: Serviço systemd configurado para sobreviver a reinícios

### 5.2 Correção do Decypharr
- **Problema**: Erro de caminho ao criar diretórios temporários
- **Solução**: Correção das configurações de Remote Path no Sonarr e Radarr
- **Resultado**: Pipeline de download completamente funcional

## 6. Status dos Componentes

| Componente | Status | Observações |
|------------|--------|-------------|
| Zurg App | ✅ Ativo | Gerencia torrents e links Real-Debrid |
| Zurg Mount | ✅ Ativo | Monta sistema de arquivos rclone |
| Decypharr | ✅ Funcional | Após correção de caminho remoto |
| Radarr | ✅ Ativo | Acessando caminhos corretos |
| Sonarr | ✅ Ativo | Acessando caminhos corretos |
| Jellyfin | ✅ Ativo | Streaming funcional |
| Prowlarr | ✅ Ativo | Indexadores configurados |
| Nexus Play-Mode | ✅ Ativo | Após atualização para dumb-prod |
| Bazarr | ❌ Inativo | Legado, não em uso |
| Jellyseerr | ❌ Inativo | Legado, não em uso |

## 7. Considerações Finais

O ecossistema Buster Friendly está em estado estável após as atualizações críticas. A integração entre todos os serviços está funcionando corretamente, com o pipeline de download e streaming operando como esperado. O script Nexus Play-Mode foi atualizado com sucesso para a nova arquitetura dumb-prod, eliminando os problemas de "engasgos" durante reprodução no Jellyfin.

A correção das configurações de caminho remoto/local no Radarr e Sonarr resolveu o problema de permissão que impedia a criação de diretórios temporários pelo Decypharr, restaurando o funcionamento completo do pipeline de mídia.

O sistema está preparado para operação contínua com os protocolos de quarentena de I/O sendo respeitados e o novo script do Nexus Play-Mode gerenciando adequadamente os downloads durante a reprodução.

*Assinado: MCP (Multi-Cognitive Processor), Agente de Documentação do Nexus*