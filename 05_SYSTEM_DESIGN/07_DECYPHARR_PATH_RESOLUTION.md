# 🔧 07_DECYPHARR_PATH_RESOLUTION: Resolução de Erro de Caminho no Decypharr

## 📋 Metadados

| Atributo | Detalhe |
|----------|---------|
| **Código** | 07_DECYPHARR_PATH_RESOLUTION |
| **Status** | Implementado |
| **Data** | 12/04/2026 |
| **Autor** | MCP (Multi-Cognitive Processor) |
| **Revisor** | Marcel Trindade |

## 📝 Histórico de Alterações

| Data | Versão | Alteração | Autor |
|------|--------|-----------|-------|
| 12/04/2026 | 1.0 | Documentação do problema e solução para erro de caminho no Decypharr | MCP |

---

## 1. Introdução e Governança

Este documento detalha a análise e resolução do problema de caminho incorreto no sistema Decypharr, parte da stack de mídia do Nexus (PRIS). O erro ocorria ao tentar criar diretórios em caminhos inexistentes no container dumb-prod, impedindo o funcionamento correto do pipeline de downloads.

## 2. Especificações Técnicas

### 2.1 Arquitetura Envolvida

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Real-Debrid   │───▶│      Zurg        │───▶│   Dumb-prod     │───▶│     Jellyfin    │
│  (Torrents)     │    │ (Gerenciamento  │    │  (Radarr/Sonarr │    │   (Streaming)   │
└─────────────────┘    │  e Mount Rclone) │    │   Decypharr)    │    │                 │
                       └──────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │                       │
                                ▼                        ▼                       ▼
                       ┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐
                       │ /home/{{LINUX_USER}}/    │    │ /mnt/debrid/    │    │ /home/{{LINUX_USER}}/   │
                       │    media/zurg    │◀───│  decypharr_     │    │   media/movies  │
                       │    (symlink:     │    │   symlinks      │    │  /shows (via   │
                       │     /zurg)       │    │  /downloads)    │    │   Bazarr)       │
                       └──────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2.2 Caminhos Reais no Sistema

- **Host PRIS**: `/home/{{LINUX_USER}}/docker/dumb-prod/mnt/debrid/decypharr_downloads/`
- **Container dumb-prod**: `/mnt/debrid/decypharr_downloads/`
- **Caminho errado usado pelo Decypharr**: `/mnt/decypharr_downloads/`

## 3. Protocolos e Procedimentos

### 3.1 Identificação do Problema

O erro ocorria com a seguinte mensagem:
```
Error running post-download action error="failed to create directory: /mnt/decypharr_downloads/radarr:Default/[...]: mkdir /mnt/decypharr_downloads: permission denied"
```

### 3.2 Análise Detalhada

1. **Configuração do Decypharr** (correta no config.json):
   ```json
   "download_folder": "/mnt/debrid/decypharr_symlinks"
   ```

2. **Configuração incorreta no Sonarr e Radarr**:
   - **Remote Path**: `/mnt/decypharr_downloads/` (INCORRETO)
   - **Local Path**: `/mnt/debrid/decypharr_downloads/` (CORRETO)

### 3.3 Solução Implementada

Corrigir a configuração do download client no Sonarr e Radarr:

**Antes (INCORRETO):**
- Remote Path: `/mnt/decypharr_downloads/`
- Local Path: `/mnt/debrid/decypharr_downloads/`

**Depois (CORRETO):**
- Remote Path: `/mnt/debrid/decypharr_downloads/`
- Local Path: `/mnt/debrid/decypharr_downloads/`

## 4. Especificações Técnicas da Solução

### 4.1 Impacto da Correção

1. **Remoção do erro de permissão**: O Decypharr agora pode criar diretórios corretamente
2. **Funcionamento do pipeline**: Downloads são processados corretamente do Real-Debrid para o sistema de arquivos
3. **Integração completa**: O fluxo Real-Debrid → Zurg → Decypharr → Radarr/Sonarr → Jellyfin funciona sem interrupções

### 4.2 Componentes Afetados

- **Decypharr**: Recebe instruções corretas de onde criar diretórios temporários
- **Radarr**: Envia requisições de download para o caminho correto
- **Sonarr**: Envia requisições de download para o caminho correto
- **Jellyfin**: Continua recebendo conteúdo via symlinks corretamente

## 5. Troubleshooting

### 5.1 Sintomas de Problema Similar

- Erros de "permission denied" ao criar diretórios em `/mnt/decypharr_downloads`
- Falha na criação de diretórios temporários para downloads
- Interrupção do pipeline de download entre ARRs e Decypharr

### 5.2 Soluções Alternativas

1. **Criação de symlink** (solução paliativa):
   ```bash
   ln -s /mnt/debrid/decypharr_downloads /mnt/decypharr_downloads
   ```

2. **Verificação de permissões**: Garantir que o usuário ubuntu tenha permissões adequadas

### 5.3 Verificação de Funcionamento

Após a correção, verificar:
1. Logs do dumb-prod para ausência de erros de permissão
2. Criação de diretórios temporários em `/mnt/debrid/decypharr_downloads/{categoria}`
3. Processamento correto de downloads no pipeline completo

## 6. Considerações Finais

A resolução deste problema demonstra a importância de manter consistência nos caminhos de montagem entre os diferentes serviços da stack de mídia. A configuração inadequada do Remote Path no Sonarr e Radarr causava um erro de caminho no Decypharr, interrompendo o fluxo de trabalho automatizado de downloads.

*Assinado: MCP (Multi-Cognitive Processor), Agente de Documentação do Nexus*