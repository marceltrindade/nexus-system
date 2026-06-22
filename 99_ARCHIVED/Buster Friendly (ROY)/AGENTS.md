# BUSTER FRIENDLY ROY - AGENTS.md

**Referências ao Nexus-Docs**
../AGENTS.md (protocolos gerais da squad)
../01_INFRA/docker_stack.md (stack services)
../04_IMPLEMENTATION_LOG.md (histórico e lições)
../03_WORKFLOWS/05_nexus_squad_protocol.md (fluxo de handoff)
../.opencode/skills/buster-friendly/SKILL.md (proto base)
../01_INFRA/hardware.md (node specs)
../03_WORKFLOWS/10_skills_catalog.md (catalog com ROY)

**Status do Projeto**
- Fase atual: Fase 5 - CONCLUÍDA (Bazarr + Jellyseerr integrados)
- IP Local: {{LAN_IP_ROY}} (SSH OK, autenticação por chave)
- Integração PRIS: Parcial (Jellyseerr → ROY ✅, NFS → Pendente)
- Próxima fase: Fase 6 - NFS ROY→PRIS PARA JELLYFIN

**API Keys Atualizadas**
- Prowlarr: `8ed1dd73a2554d5bb09a21a0053e3526`
- Radarr: `b1f5b772cc5041a398005e1e05e08d5a`
- Sonarr: `9f545b2728b64e5d9bda3eec1363d81b`
- Decypharr: rodando v2.2 (API v4.3.2)

**Regras Operacionais CRITICAS**
🚫 PROIBIÇÕES:
- Subir containers sem validação Zurg mount
- Executar fases fora de ordem definida
- Editar bancos com containers rodando
- Pular validações entre fases
- Executar ações sem explicar e aguardar aprovação

✅ REQUISITOS OBRIGATÓRIOS:
1. VALIDAR PRIMEIRO: `ls /mnt/zurg` antes de qualquer ação
2. EXECUTAR ESTREITAMENTE 6 fases do dossiê
3. REGISTRAR IMEDIATAMENTE no ../04_IMPLEMENTATION_LOG.md
4. OBTER PROTOCOLO HITL PARA OPERAÇÕES WRITE
5. SEMPRE explicar o que será feito e aguardar aprovação antes de executar

**COMANDOS E VALIDACOES**
🛠️ CHECKS OBRIGATÓRIOS:
```bash
ls /mnt/zurg            # Valida mount Zurg
ls -la /mnt/media/      # Verifica estrutura diretório
docker ps --filter "name=prowlarr|radarr|sonarr|bazarr"  # Status servicos
```

**PROTOCOLO DE COMUNICAÇÃO OBRIGATÓRIO:**
- ❌ NUNCA executar ação sem primeiro explicar o que será feito
- ❌ NUNCA assumir aprovação implícita
- ❌ NUNCA começar uma sessão sem leitura completa da documentação
- ❌ NUNCA executar ações sem solicitar aprovação explícita
- ✅ SEMPRE apresentar plano detalhado da próxima ação
- ✅ SEMPRE aguardar aprovação explícita antes de executar
- ✅ SEMBRE reportar cada etapa concluída antes de prosseguir

✅ CHECKLIST PRE-EXEC:
- [ ] Zurg mount OK
- [ ] Paths corrigidos nos .db
- [ ] Estrutura /mnt validada
- [ ] HITL aprovada
- [ ] Log implementação consultado
- [ ] Plano de ação explicado e aprovado

**FLUXOS E HANDOFF**
🔄 Transição:
```
[PROJETO] BUSTER FRIENDLY ROY - Fase X
- Última ação: [descricao]
- Proxima ação: [descricao]
- Validações pendentes: [lista]
- Riscos: [lista]
```

📊 Monitoramento:
- Logs observáveis obrigatórios
- Métricas montagem NFS ROY->PRIS
- Latência NFS verificada

🚨 Escalonamento:
- Problemas mount => DEBUGGER
- Issues Banco => Engenheiro+DEBUGGER
- Performance => ARQUITETO
- Validacao Final => QA

**REFERENCIAS TECNICAS**
- Correção de bancos: consultar dossiê §7, §9.2 (documento técnico separado)
- Comandos SQLite de migracao: documentação técnica reservada
- Prowlarr container: usar bind mount só do .db (não /config inteiro) para evitar reinitialize

**BUG CONHECIDO**
- Docker linuxserver.io reinitialize Prowlarr database na primeira criação do container
- Solução: stop → clean dir → copy backup → docker create → docker start
- NÃO usar docker run (ele sempre reinitialize se /config/prowlarr.db não existir)
- Config NFS ROY->PRIS: protocolo específico identificado

🛠️ CONTRATOS DE FERRAMENTAS
- `TOOL_CONTRACTS.md` - Whitelist de comandos e protocolos de execução

# 🛡️ SEGURANÇA E DEBUG

**Protocolo de Segurança Obrigatório:**
Em caso de erro inesperado, interrompa a execução e consulte imediatamente:
- `DEBUG_SAFETY.md` - Protocolos de confiabilidade e recuperação

**Regras de Ouro:**
1. Load Average > 4.0 = ABORTAR operações I/O
2. SEMPRE backup prévio de bancos .db antes de edição
3. Mount congelado = `sudo umount -l /mnt/zurg` + análise de logs

**Escalonamento Imediato:**
- Falhas múltiplas → Debugger
- Sistema instável → Arquiteto
