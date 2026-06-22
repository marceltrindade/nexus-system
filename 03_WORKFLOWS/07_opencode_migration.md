# 🔄 07_OPENCODE_MIGRATION: Migração Gemini CLI → Opencode

| Campo | Valor |
| :--- | :--- |
| **Código** | `07` |
| **Status** | Em Progresso |
| **Data** | 2026-04-01 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Contexto e Motivação

A Squad Nexus operava anteriormente no **Gemini CLI**, que apresentava limitações estruturais para o ecossistema:

- Sandbox temporário (`~/.gemini/tmp/[hash]`) — sem endereço fixo para agentes
- Configuração de personas dependia de hacks no prompt do sistema
- Lock-in com ecossistema Google — incompatível com a filosofia de soberania do Nexus
- Dificuldade em manter 8 personas distintas com configurações independentes

O **Opencode** foi selecionado como substituto por oferecer:
- Agentes como cidadãos de primeira classe (configuração declarativa via `opencode.json` + markdown)
- Endereços fixos em `~/.config/opencode/agents/`
- Projeto open-source, alinhado com soberania de dados
- Suporte nativo a múltiplos agentes primários e subagentes

---

## 2. O Que Foi Migrado

### 2.1 Agentes (8 personas)

| Agente | Modo | Temperatura | Cor | Arquivo |
| :--- | :--- | :--- | :--- | :--- |
| `consultor` | all | 0.8 | `#f59e0b` | `~/.config/opencode/agents/consultor.md` |
| `arquiteto` | primary | 0.3 | `#6366f1` | `~/.config/opencode/agents/arquiteto.md` |
| `engenheiro` | primary | 0.1 | `#10b981` | `~/.config/opencode/agents/engenheiro.md` |
| `debugger` | subagent | 0.1 | `#ef4444` | `~/.config/opencode/agents/debugger.md` |
| `qa` | subagent | 0.1 | `#f97316` | `~/.config/opencode/agents/qa.md` |
| `iiva` | all | 0.6 | `#8b5cf6` | `~/.config/opencode/agents/iiva.md` |
| `mentor` | all | 0.8 | `#06b6d4` | `~/.config/opencode/agents/mentor.md` |
| `escritor` | all | 0.9 | `#ec4899` | `~/.config/opencode/agents/escritor.md` |

### 2.2 Arquivos de Configuração

| Arquivo | Escopo | Função |
| :--- | :--- | :--- |
| `~/.config/opencode/opencode.json` | Global | 8 agentes + instruções Nexus |
| `~/.config/opencode/agents/*.md` | Global | Personas (disponíveis em qualquer projeto) |
| `Nexus-Docs/opencode.json` | Projeto | Override local com prompts apontando para `.opencode/agents/` |
| `Nexus-Docs/.opencode/agents/*.md` | Projeto | Cópias dos agentes para uso no repositório |

### 2.3 Instruções Globais Carregadas

- `AGENTS.md` — convenções do repositório, squad protocol, infra reference
- `03_WORKFLOWS/05_nexus_squad_protocol.md` — constituição da Squad

---

## 3. O Que Mudou

### 3.1 Ganho

| Antes (Gemini CLI) | Depois (Opencode) |
| :--- | :--- |
| Sandbox temporário sem endereço fixo | `~/.config/opencode/agents/` como endereço permanente |
| Personas injetadas via prompt hack | Configuração declarativa em JSON + markdown |
| 1 agente por sessão | Múltiplos agentes primários (Tab) + subagentes (@) |
| Lock-in Google | Open-source, sem vendor lock-in |
| Sem controle de temperatura por agente | Temperatura configurável por persona |
| Sem cores visuais | Cores customizadas por agente no TUI |

### 3.2 Perda / Limitação

| Recurso | Status | Mitigação |
| :--- | :--- | :--- |
| Histórico de conversas do Gemini | ❌ Perdido | Reforçar leitura do `04_IMPLEMENTATION_LOG.md` no início de cada sessão |
| MCP tools do Gemini CLI | ⚠️ A validar | Verificar suporte MCP do Opencode e reconfigurar se disponível |
| Grafo de memória | ❌ Não disponível | Substituir por leitura obrigatória do `GLOBAL_STATE.log` + `IMPLEMENTATION_LOG.md` |
| Integração com ferramentas Google | ❌ Perdida | Não era usado ativamente pelo Nexus |

---

## 4. Riscos Identificados

### R1: Fragmentação de Agentes
**Se** alguns agentes rodarem no Opencode e outros no Gemini, **então** o protocolo de Handover quebra.
**Mitigação:** Migrar todos os 8 agentes de uma vez. Não operar em modo híbrido.

### R2: Perda de Contexto Histórico
**Se** o Opencode não herdar o histórico de incidentes e correções, **então** agentes podem repetir erros passados.
**Mitigação:** O `04_IMPLEMENTATION_LOG.md` é a memória de longo prazo. Mandato de leitura obrigatória no início de cada sessão.

### R3: Maturidade do Opencode
**Se** o Opencode não entregar acesso a ferramentas MCP ou bash confiável, **então** agentes ficam limitados a texto.
**Mitigação:** Manter Gemini CLI como fallback até validação completa pelo QA.

---

## 5. Fallback e Rollback

### Fallback Imediato
O Gemini CLI permanece instalado. Se o Opencode falhar em qualquer tarefa crítica:
1. Reverter para o Gemini CLI
2. Reportar a falha no `04_IMPLEMENTATION_LOG.md`
3. Investigar com o Debugger

### Rollback Completo
```bash
# Remover config global do Opencode
rm -rf ~/.config/opencode/

# Restaurar uso exclusivo do Gemini CLI
# (nenhuma ação adicional necessária — o Gemini CLI já está configurado)
```

---

## 6. Checklist de Validação (QA)

- [ ] Todos os 8 agentes aparecem no TUI (Tab para primários, @ para subagentes)
- [ ] Temperaturas estão corretas por agente
- [ ] Cores visuais estão aplicadas
- [ ] Instruções globais (AGENTS.md, squad protocol) são carregadas
- [ ] Acesso bash funciona (comandos rodam no host)
- [ ] Leitura de arquivos em `/mnt/almox` funciona
- [ ] Git commit/push funciona via ferramentas do agente
- [ ] Subagentes podem ser invocados via @mention
- [ ] Config local do projeto (Nexus-Docs/opencode.json) sobrescreve corretamente a global

---

## 7. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-01 | Gaff | Documento inicial criado |

---

*Assinado: Gaff, Arquiteto Chefe do Ecossistema Nexus.*
