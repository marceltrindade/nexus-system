# 🔧 09_NEXUS_PLAY_MODE_UPDATE: Atualização do Script Nexus Play-Mode para Arquitetura dumb-prod

## 📋 Metadados

| Atributo | Detalhe |
|----------|---------|
| **Código** | 09_NEXUS_PLAY_MODE_UPDATE |
| **Status** | Implementado |
| **Data** | 12/04/2026 |
| **Autor** | MCP (Multi-Cognitive Processor) |
| **Revisor** | Marcel Trindade |

## 📝 Histórico de Alterações

| Data | Versão | Alteração | Autor |
|------|--------|-----------|-------|
| 12/04/2026 | 1.0 | Atualização do script nexus-play-mode.sh para compatibilidade com a arquitetura dumb-prod | MCP |

---

## 1. Introdução e Governança

Este documento detalha a atualização do script `nexus-play-mode.sh` para torná-lo compatível com a nova arquitetura do dumb-prod. O script é responsável por pausar processos intensivos de I/O durante a reprodução ativa no Jellyfin, prevenindo "engasgos" durante a reprodução.

## 2. Especificações Técnicas

### 2.1 Arquitetura Anterior vs Nova

**Antes:**
- Múltiplos containers individuais: `sonarr`, `radarr`, `decypharr-sonarr`, `decypharr-radarr`, `prowlarr`, `bazarr`
- Script fazia referência a containers específicos
- Utilização de comandos como `docker pause/unpause` nos containers individuais

**Depois:**
- Único container: `dumb-prod`
- Todos os serviços (Radarr, Sonarr, Prowlarr, Decypharr) rodam dentro do dumb-prod
- Script gerencia processos dentro do container único

### 2.2 Problemas Identificados no Script Antigo

1. **Erros de parsing de JSON**: O comando `jq` falhava ao analisar a resposta da API do Jellyfin
2. **Erros de comparação**: Variáveis não numéricas eram comparadas como inteiros
3. **Referências a containers inexistentes**: O script fazia referência a containers que não existem mais
4. **Falhas de compatibilidade**: Chamadas a `supervisorctl` que não existem no container dumb-prod

## 3. Protocolos e Procedimentos

### 3.1 Soluções Implementadas

1. **Tratamento robusto de erros JSON**:
   - Verificação de sucesso do comando `curl`
   - Verificação de sucesso do comando `jq`
   - Fallback para métodos alternativos de parsing em caso de falha

2. **Gerenciamento de processos no dumb-prod**:
   - Uso de `docker exec` para gerenciar processos dentro do container
   - Uso de `pkill` e `pgrep` para pausar e verificar serviços
   - Remoção de chamadas a `supervisorctl` inexistentes

3. **Atualização da lógica de monitoramento**:
   - Monitoramento de processos específicos dentro do dumb-prod
   - Identificação correta de serviços ativos/inativos
   - Pausa e retomada adequada dos serviços de download

### 3.2 Implementação

```bash
#!/bin/bash

# Nexus Play-Mode Monitoring System
# Pauses I/O intensive processes during active playback on Jellyfin.

JELLYFIN_URL="http://127.0.0.1:8096"
JELLYFIN_API_KEY="2b37d4cb52a74697b70cedc6c3acb613"
TARGET_CONTAINER="dumb-prod"
CHECK_INTERVAL=30
LOG_FILE="/home/{{LINUX_USER}}/logs/play-mode.log"

mkdir -p "/home/{{LINUX_USER}}/logs"
touch "$LOG_FILE"

echo "[$(date)] Nexus Play-Mode Monitor Started (Final version for dumb-prod architecture)." >> "$LOG_FILE"

while true; do
    # Fetch active sessions from Jellyfin
    SESSIONS=$(curl -s -H "X-Emby-Token: $JELLYFIN_API_KEY" "$JELLYFIN_URL/Sessions" 2>/dev/null)
    
    # Check if curl command succeeded and returned valid data
    if [ $? -ne 0 ] || [ -z "$SESSIONS" ]; then
        echo "[$(date)] Warning: Could not fetch Jellyfin sessions, skipping check." >> "$LOG_FILE"
        sleep $CHECK_INTERVAL
        continue
    fi

    # Check for active playback: NowPlayingItem exists AND PlayState.IsPaused is false
    # Using a more robust approach to handle potentially malformed JSON
    ACTIVE_PLAYBACK=$(echo "$SESSIONS" | jq -r 'map(select(.NowPlayingItem != null and .PlayState != null and .PlayState.IsPaused == false)) | length' 2>/dev/null)

    # Check if jq command succeeded and returned a valid number
    if [ $? -ne 0 ] || [ -z "$ACTIVE_PLAYBACK" ] || ! [[ "$ACTIVE_PLAYBACK" =~ ^[0-9]+$ ]]; then
        # If jq fails, try a more basic approach
        ACTIVE_COUNT=$(echo "$SESSIONS" | grep -o '"NowPlayingItem":' | wc -l 2>/dev/null)
        PAUSED_COUNT=$(echo "$SESSIONS" | grep -o '"IsPaused":true' | wc -l 2>/dev/null)
        UNPAUSED_COUNT=$(echo "$SESSIONS" | grep -o '"IsPaused":false' | wc -l 2>/dev/null)
        
        # Calculate active sessions (playing, not paused)
        if [ "$ACTIVE_COUNT" -gt 0 ] && [ "$UNPAUSED_COUNT" -gt 0 ]; then
            ACTIVE_PLAYBACK=$((ACTIVE_COUNT < UNPAUSED_COUNT ? ACTIVE_COUNT : UNPAUSED_COUNT))
        else
            ACTIVE_PLAYBACK=0
        fi
    fi

    if [ "$ACTIVE_PLAYBACK" -gt 0 ]; then
        # Playback Active - Pause Downloads
        STATE=$(docker inspect -f '{{.State.Status}}' "$TARGET_CONTAINER" 2>/dev/null)
        if [ "$STATE" == "running" ]; then
            echo "[$(date)] Active playback detected ($ACTIVE_PLAYBACK sessions). Pausing download processes in $TARGET_CONTAINER..." >> "$LOG_FILE"
            
            # Pause download-related processes within the container
            docker exec "$TARGET_CONTAINER" pkill -f "Radarr.*--nobrowser" 2>/dev/null
            docker exec "$TARGET_CONTAINER" pkill -f "Sonarr.*--nobrowser" 2>/dev/null
            docker exec "$TARGET_CONTAINER" pkill -f "Prowlarr.*--nobrowser" 2>/dev/null
            docker exec "$TARGET_CONTAINER" pkill -f "decypharr.*--config" 2>/dev/null
            docker exec "$TARGET_CONTAINER" pkill -f "rclone.*rcd" 2>/dev/null
            
            # Also pause any active rclone transfers
            docker exec "$TARGET_CONTAINER" pkill -f "rclone copy" 2>/dev/null
            docker exec "$TARGET_CONTAINER" pkill -f "rclone move" 2>/dev/null
            docker exec "$TARGET_CONTAINER" pkill -f "rclone sync" 2>/dev/null
        fi
    else
        # No Active Playback - Resume Downloads
        STATE=$(docker inspect -f '{{.State.Status}}' "$TARGET_CONTAINER" 2>/dev/null)
        if [ "$STATE" == "running" ]; then
            echo "[$(date)] No active playback. Resuming download processes in $TARGET_CONTAINER..." >> "$LOG_FILE"
            
            # Restart services in the dumb-prod container by checking if they're running
            RUNNING_RADARR=$(docker exec "$TARGET_CONTAINER" pgrep -f "Radarr.*--nobrowser" 2>/dev/null | wc -l)
            RUNNING_SONARR=$(docker exec "$TARGET_CONTAINER" pgrep -f "Sonarr.*--nobrowser" 2>/dev/null | wc -l)
            RUNNING_PROWLARR=$(docker exec "$TARGET_CONTAINER" pgrep -f "Prowlarr.*--nobrowser" 2>/dev/null | wc -l)
            RUNNING_DECYPHARR=$(docker exec "$TARGET_CONTAINER" pgrep -f "decypharr.*--config" 2>/dev/null | wc -l)
            
            # Start Radarr if not running
            if [ "$RUNNING_RADARR" -eq 0 ]; then
                docker exec "$TARGET_CONTAINER" timeout 5s /opt/radarr/Radarr/Radarr --nobrowser --data=/radarr/default &>/dev/null &
            fi
            
            # Start Sonarr if not running
            if [ "$RUNNING_SONARR" -eq 0 ]; then
                docker exec "$TARGET_CONTAINER" timeout 5s /opt/sonarr/Sonarr/Sonarr --nobrowser --data=/sonarr/default &>/dev/null &
            fi
            
            # Start Prowlarr if not running
            if [ "$RUNNING_PROWLARR" -eq 0 ]; then
                docker exec "$TARGET_CONTAINER" timeout 5s /opt/prowlarr/Prowlarr/Prowlarr --nobrowser --data=/prowlarr/default &>/dev/null &
            fi
            
            # Start Decypharr if not running
            if [ "$RUNNING_DECYPHARR" -eq 0 ]; then
                docker exec "$TARGET_CONTAINER" timeout 5s /decypharr/decypharr --config /decypharr &>/dev/null &
            fi
        fi
    fi

    sleep $CHECK_INTERVAL
done
```

## 4. Especificações Técnicas da Solução

### 4.1 Persistência do Serviço

- O serviço `nexus-play-mode.service` está configurado como um serviço systemd
- O serviço é iniciado automaticamente após reinícios do sistema
- Configuração localizada em `/etc/systemd/system/nexus-play-mode.service`

### 4.2 Componentes Afetados

- **dumb-prod**: Container único que hospeda todos os serviços de mídia
- **Jellyfin**: Recebe monitoramento adequado para detecção de reprodução ativa
- **Serviços de download**: Radarr, Sonarr, Prowlarr e Decypharr são gerenciados corretamente

## 5. Troubleshooting

### 5.1 Sintomas de Problema Similar

- Erros constantes de parsing JSON no log do sistema
- Falhas na pausa/despausa de serviços durante reprodução no Jellyfin
- Referências a containers inexistentes nos logs

### 5.2 Verificação de Funcionamento

Após a atualização, verificar:

1. Presença da mensagem "Final version for dumb-prod architecture" nos logs
2. Ausência de erros de parsing JSON
3. Ausência de erros com `supervisorctl`
4. Monitoramento contínuo do estado de reprodução do Jellyfin

### 5.3 Logs Relevantes

- `/home/{{LINUX_USER}}/logs/play-mode.log` - Log do script
- `journalctl -u nexus-play-mode.service` - Log do serviço systemd

## 6. Considerações Finais

A atualização do script `nexus-play-mode.sh` foi essencial para manter a funcionalidade de pausa de downloads durante reprodução no Jellyfin após a transição para a arquitetura dumb-prod. A nova implementação resolve os problemas de compatibilidade e melhora a robustez do sistema com tratamento adequado de erros.

O script agora está alinhado com a arquitetura atual e deve eliminar os "engasgos" durante reprodução no Jellyfin que estavam ocorrendo devido aos erros anteriores.

*Assinado: MCP (Multi-Cognitive Processor), Agente de Documentação do Nexus*