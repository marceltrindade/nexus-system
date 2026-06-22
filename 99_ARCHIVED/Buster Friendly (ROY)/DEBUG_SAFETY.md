# 🛡️ DEBUG_SAFETY.md - Protocolos de Confiabilidade BUSTER FRIENDLY ROY

## 🚨 PROTOCOLO 1: BACKUP E ROLLBACK DE BANCOS (FASE 2)

### REGRA MANDATÓRIA:
**Toda operação de escrita em arquivos .db exige backup prévio com timestamp**

### COMANDOS DE BACKUP:
```bash
# Backup pré-operacional com timestamp
cp /caminho/para/banco.db /caminho/para/banco.db.bak_$(date +%Y%m%d_%H%M%S)

# Para múltiplos bancos (Prowlarr, Radarr, Sonarr):
for db_file in prowlarr.db radarr.db sonarr.db; do
    cp "$db_file" "${db_file}.bak_$(date +%Y%m%d_%H%M%S)"
done
```

### PROTOCOLO DE ROLLBACK IMEDIATO:
```bash
# Se integridade do banco falhar após edição:
sqlite3 banco.db "PRAGMA integrity_check;" | grep -q "ok" || \
cp banco.db.bak_latest banco.db

# Restauração manual confirmada:
sqlite3 banco.corrompido.db .dump | sqlite3 banco.restaurado.db
```

### VALIDAÇÃO DE INTEGRIDADE:
```bash
# Check obrigatório pós-edicao
sqlite3 banco.db "PRAGMA integrity_check;" | grep "ok" || \
echo "ERRO CRÍTICO: Banco corrompido - Acionar rollback"
```

---

## ⚡ PROTOCOLO 2: CIRCUIT BREAKER DE HARDWARE (ROY i5)

### LIMITE DE CARGA DEFINIDO:
**Load Average > 4.0 = ABORTAR OPERAÇÕES DE VARREDURA**

### MONITORAMENTO CONTÍNUO:
```bash
# Check de carga antes de operações I/O intensivas
load_avg=$(cat /proc/loadavg | cut -d' ' -f1)
if (( $(echo "$load_avg > 4.0" | bc -l) )); then
    echo "🚨 LOAD CRÍTICO: $load_avg - Abortando varredura"
    exit 1
fi
```

### COMANDOS BLOQUEADOS SOBRE CARGA 4.0:
- `find /mnt -type f`
- `ls -R /mnt`  
- `du -sh /mnt/*`
- Qualquer operação recursiva em `/mnt`

### ESCALONAMENTO POR CARGA:
```bash
load_avg=$(cat /proc/loadavg | cut -d' ' -f1)

if (( $(echo "$load_avg > 6.0" | bc -l) )); then
    echo "🔴 EMERGÊNCIA: Load $load_avg - Notificar ARQUITETO"
elif (( $(echo "$load_avg > 4.0" | bc -l) )); then
    echo "🟡 ALERTA: Load $load_avg - Operações I/O limitadas"
elif (( $(echo "$load_avg > 2.0" | bc -l) )); then
    echo "🟢 NORMAL: Load $load_avg - Operações permitidas"
fi
```

---

## 🌀 PROTOCOLO 3: GESTÃO DE FALHA DE MOUNT (FUSE/ZURG)

### COMANDO DE EMERGÊNCIA:
**Para congestionamentos do sistema de arquivos:**
```bash
sudo umount -l /mnt/zurg  # lazy unmount forçado
```

### PRÉ-REQUISITO PARA REMONTAGEM:
**Consultar logs FUSE antes de qualquer tentativa:**
```bash
journalctl -u zurg --since "5 minutes ago" --no-pager
journalctl -u rclone --since "5 minutes ago" --no-pager
dmesg | tail -20 | grep -i fuse
```

### SEQUÊNCIA DE RECUPERAÇÃO:
```bash
# 1. Diagnosticar causa raiz nos logs
journalctl -u zurg --since "1 hour ago" --no-pager | grep -i error

# 2. Forçar unmount se necessário  
sudo umount -l /mnt/zurg

# 3. Aguardar estabilização do sistema
sleep 30

# 4. Remontar apenas se logs indicarem resolução
docker restart zurg-container
```

### INDICADORES DE FALHA CRÍTICA:
```bash
# Se estes patterns aparecerem nos logs, NÃO remontar:
- "I/O error"
- "connection reset"
- "permission denied" persistent
- "no such file or directory" em paths existentes
```

---

## 🚨 PROTOCOLO DE ESCALONAMENTO

### HIERARQUIA DE FALHAS:

| Nível | Sintoma | Ação |
|-------|---------|------|
| **1** | Load > 4.0 | Abortar I/O, monitorar |
| **2** | Banco corrompido | Rollback automático |
| **3** | Mount congelado | Unmount lazy, analisar logs |
| **4** | Múltiplas falhas | ESCALAR PARA DEBUGGER |
| **5** | Sistema instável | ESCALAR PARA ARQUITETO |

### CONTATOS CRÍTICOS:
- **Debugger**: Análise de logs e causa raiz
- **Arquiteto**: Decisões arquiteturais e failover
- **QA**: Validação pós-recuperação

---

*Protocolos ratificados pelo Engenheiro de Confiabilidade - BUSTER FRIENDLY ROY*