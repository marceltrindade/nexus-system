# 🛠️ TOOL_CONTRACTS.md - Contratos de Ferramentas BUSTER FRIENDLY ROY

## 📋 CONTRATO 1: WHITELIST DE COMANDOS AUTORIZADOS

### 🟢 COMANDOS PERMITIDOS (AUTOMÁTICO):
```bash
# Operações de Sistema
ls, cat, grep, find, cp, mv, rm, mkdir, mount, umount
systemctl, journalctl, dmesg, top, htop, uptime

# Banco de Dados  
sqlite3

# Containerização
docker, docker-compose, docker ps, docker logs

# Storage e Network
rclone, df, du, ping, ip, ss

# Monitoramento
cat /proc/loadavg, cat /proc/meminfo
```

### 🟡 COMANDOS CONDICIONAIS (REQUER JUSTIFICATIVA):
```bash
# Modificação de Sistema
chmod, chown, apt, snap, reboot, shutdown

# Operações Destrutivas
dd, fdisk, mkfs, rm -rf

# Rede Avançada
iptables, ufw, tcpdump
```

### 🔴 REGRA DE SEGURANÇA:
**Qualquer comando fora da whitelist exige:**
1. Justificativa técnica detalhada
2. Análise de impacto no sistema
3. Aprovação via protocolo HITL
4. Backup pré-operacional

---

## 📝 CONTRATO 2: ESQUEMA DE OUTPUT (IMPLEMENTATION LOG)

### FORMATO PADRÃO PARA `../04_IMPLEMENTATION_LOG.md`:
```markdown
## 📅 YYYY-MM-DD HH:MM — [CONTEXTO DA OPERAÇÃO]

### ✅ AÇÕES REALIZADAS:
1. **Comando Executado:** `comando --com --parâmetros`
2. **Resultado:** Sucesso/Falha
3. **Saída de Erro (se aplicável):** 
```erro detalhado```

### 📊 ESTADO DO SISTEMA PÓS-EXECUÇÃO:
- **Load Average:** 1.23, 1.45, 1.67
- **Mount Zurg:** ✅ Acessível
- **Serviços ARR:** 🟢 Operacionais  
- **Uso Disco:** 45%

### 📂 ARQUIVOS ALTERADOS:
- caminho/do/arquivo

### 📋 PRÓXIMO PASSO:
[Descrição da pró ação]
```

### EXEMPLO DE ENTRADA VÁLIDA:
```markdown
## 📅 2026-04-25 14:30 — Correção de paths no Radarr

### ✅ AÇÕES REALIZADAS:
1. **Comando Executado:** `sqlite3 radarr.db "UPDATE Table SET Path = '/mnt/media/movies' WHERE Path LIKE '/zurg%'"`
2. **Resultado:** Sucesso (32 registros atualizados)
3. **Saída de Erro:** Nenhum

### 📊 ESTADO DO SISTEMA PÓS-EXECUÇÃO:
- **Load Average:** 0.89, 1.12, 1.34
- **Mount Zurg:** ✅ Acessível
- **Serviços ARR:** 🔴 Parados (para manutenção)
- **Uso Disco:** 38%

### 📂 ARQUIVOS ALTERADOS:
- ~/docker/buster-friendly/config/radarr/radarr.db

### 📋 PRÓXIMO PASSO:
Validar integridade do banco com PRAGMA integrity_check
```

---

## 🔍 CONTRATO 3: PROTOCOLO DE VALIDAÇÃO DE PATH

### REGRA MANDATÓRIA:
**Antes de qualquer comando envolvendo caminhos, validar:**
```bash
# Padrões autorizados:
^/mnt/(zurg|media)/.*
^/home/[^/]+/docker/buster-friendly/.*
^/tmp/.*
```

### SCRIPT DE VALIDAÇÃO OBRIGATÓRIO:
```bash
validate_path() {
    local path="$1"
    if [[ "$path" =~ ^/mnt/(zurg|media)/ ]] || \
       [[ "$path" =~ ^/home/[^/]+/docker/buster-friendly/ ]] || \
       [[ "$path" =~ ^/tmp/ ]]; then
        return 0  # Path válido
    else
        echo "🚨 PATH NÃO AUTORIZADO: $path"
        echo "Paths permitidos: /mnt/zurg/, /mnt/media/, ~/docker/buster-friendly/, /tmp/"
        return 1  # Path inválido
    fi
}

# Uso:
validate_path "/mnt/media/movies" || exit 1
```

### PATHS CRÍTICOS BLOQUEADOS:
```bash
# ❌ NUNCA permitidos:
/root/
/etc/
/var/lib/docker/
/boot/
/dev/
/proc/
/sys/
```

### EXCEÇÕES TEMPORÁRIAS:
**Paths fora dos padrões exigem:**
1. Justificativa arquitetural
2. Revisão por Arquiteto
3. Registro explícito no Implementation Log
4. Plano de rollback

---

## ⚖️ CONTRATO 4: HIERARQUIA DE DECISÃO

### AUTONOMIA POR NÍVEL:

| Nível | Tipo de Comando | Aprovação Requerida |
|-------|-----------------|---------------------|
| **1** | Whitelist básica | ✅ Automático |
| **2** | Whitelist condicional | 🔍 Justificativa técnica |
| **3** | Fora da whitelist | ⚠️ HITL + Arquiteto |
| **4** | Path não padrão | 🚨 Revisão arquitetural |

### MATRIZ DE RISCO:
```bash
# Avaliação obrigatória pré-execução:
RISCO = (Complexidade × Impacto) / Reversibilidade

# Se RISCO > 2.0 → Exige aprovação HITL
# Se RISCO > 5.0 → Exige revisão arquitetural
```

---

*Contratos ratificados pelo Arquiteto de Sistemas - BUSTER FRIENDLY ROY*
*Validade: Até revisão arquitetural ou mudança de escopo*