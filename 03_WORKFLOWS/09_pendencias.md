# 📋 PENDÊNCIAS — Lista de Ações Pendentes

| Campo | Valor |
| :--- | :--- |
| **Status** | Ativa |
| **Criada em** | 2026-04-01 |
| **Última atualização** | 2026-04-01 |
| **Responsável** | Marcel Trindade |

---

## 🔴 Alta Prioridade

### ~~P1: Reconstruir Google Calendar MCP~~ ✅ FEITO
- **Status:** Reconstruído em JavaScript ESM com 4 tools. QA aprovado.

### ~~P2: Configurar Variáveis de Ambiente para Secrets~~ ✅ FEITO
- **Status:** 9 variáveis extraídas do `~/.gemini/settings.json` e injetadas no `~/.zshrc`.
- **Variáveis configuradas:** `FORGEJO_TOKEN`, `TODOIST_API_KEY`, `TRELLO_API_KEY`, `TRELLO_TOKEN`, `FIGMA_ACCESS_TOKEN`, `CONTEXT7_API_KEY`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REFRESH_TOKEN`.
- **Validação:** `source ~/.zshrc` confirma todas as 9 exportadas corretamente.

---

## 🟡 Média Prioridade

### ~~P3: Reconfigurar n8n-mcp para Tailscale~~ ✅ FEITO
- **Status:** IP alterado de `{{LAN_IP_VALIS}}` (LAN) para `{{TAILSCALE_IP_PRIS}}` (Tailscale/PRIS).

### ~~P4: Validar MCPs no Opencode (teste real em sessão)~~ ✅ FEITO
- **Status:** 13/13 MCPs validados em startup. 2 pacotes substituídos (wikipedia, figma-free — deletados do npm).
- **Substituições:**
  - `@modelcontextprotocol/server-wikipedia` → `wikipedia-mcp` (timjuenemann)
  - `@superdoccimo/figma-mcp-free` → `figma-developer-mcp` (Framelink)
- **Nota:** Validação funcional em sessão real do Opencode ainda pendente (requer teste manual).

### ~~P5: Validar Agentes no Opencode (teste real em sessão)~~ ✅ FEITO
- **Status:** Validação estrutural completa — todos os 8 agentes aprovados.
  - Frontmatter, prompt files, tool globs, modos — tudo verificado.
  - Teste funcional em sessão real do Opencode aprovado (interação com Marcel).

---

## 🟢 Baixa Prioridade

### ~~P6: Limpar MCPs do Gemini CLI~~ ❌ CANCELADA
- **Decisão:** Gemini CLI é agente fallback. Manter MCPs intactos no `settings.json` para disponibilidade imediata.

### ~~P7: Documentar n8n-mcp no Nexus-Docs~~ ✅ FEITO
- **Status:** Manual operacional criado em `01_INFRA/n8n_mcp.md` (código JD `01.03.01`).
- **Conteúdo:** Topologia, configuração, health checks, troubleshooting, backlog de integrações.

---

## 🔵 Futuro / Backlog

### P8: Configurar n8n na PRIS ⚠️ PARCIALMENTE CONCLUÍDA
- **Status:** Acesso público configurado ✅ (https://n8n.{{CLOUDFLARE_DOMAIN}}/). Usuário criado ✅. Endpoint MCP operacional ✅.
- **Pendente:** Configuração de workflows, autenticação e integrações.
- **Data acesso público:** 2026-04-01
- **Validação:** Marcel confirmou acesso público funcionando.

---

## 📊 Resumo

| Prioridade | Count | Status |
| :--- | :--- | :--- |
| 🔴 Alta | 0 | — |
| 🟡 Média | 0 | — |
| 🟢 Baixa | 0 | — |
| 🔵 Futuro | 1 | P8 (configuração workflows) |
| ✅ Feito | 8 | P1, P2, P3, P4, P5, P7 |
| ⚠️ Parcial | 1 | P8 (acesso público) |
| ❌ Cancelada | 1 | P6 |
| **Total** | **10** | |

---

*Lista criada em 2026-04-01 às 05:00. Última atualização: 2026-04-01 (n8n: acesso público configurado, workflows pendentes).*  
