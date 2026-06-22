# 🔌 08_MCP_MIGRATION_SPEC: Migração de MCP Servers para Opencode

| Campo | Valor |
| :--- | :--- |
| **Código** | `08` |
| **Status** | Google Calendar reconstruído (pendente validação) |
| **Data** | 2026-04-01 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Inventário Completo

### 1.1 MCPs Locais do Gemini CLI (11 servers)

| # | Nome | Tipo | Comando | Status |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `todoist` | local (npx) | `npx -y @doist/todoist-ai` | ✅ OK |
| 2 | `puppeteer` | local (npx) | `npx -y @modelcontextprotocol/server-puppeteer` | ✅ OK |
| 3 | `memory` | local (node) | `node server-memory/dist/index.js` | ✅ OK |
| 4 | `google-calendar` | local (node) | `node google-calendar/index.js` | ✅ RECONSTRUÍDO |
| 5 | `n8n-mcp` | local (HTTP bridge) | `npx supergateway --streamableHttp ...` | ⚠️ IP local |
| 6 | `context7` | local (npx) | `npx -y @upstash/context7-mcp` | ✅ OK |
| 7 | `trello` | local (uv/python) | `uv run main.py` | ✅ OK |
| 8 | `figma-free` | local (npx) | `npx -y @superdoccimo/figma-mcp-free` | ✅ OK |
| 9 | `homebutler` | local (binary) | `/usr/local/bin/homebutler mcp` | ✅ OK |
| 10 | `forgejo-nexus` | local (python) | `python3 forgejo-mcp/server.py` | ✅ OK |
| 11 | `MCP_DOCKER` | gateway | `docker mcp gateway run` | ✅ OK |

### 1.2 MCPs do Docker Toolkit (via gateway — 10 servers)

| # | Nome | Função |
| :--- | :--- | :--- |
| 1 | `ffmpeg` | Conversão de mídia |
| 2 | `gemini-api-docs` | Documentação API Gemini |
| 3 | `gmail-mcp` | Email (marcelrtrindade@gmail.com) |
| 4 | `linkedin-mcp-server` | LinkedIn |
| 5 | `mcp-reddit` | Reddit |
| 6 | `needle-mcp` | — |
| 7 | `obsidian` | Notas Obsidian |
| 8 | `openweather` | Clima |
| 9 | `sequentialthinking` | Raciocínio encadeado |
| 10 | `wikipedia-mcp` | Wikipedia |

---

## 2. Problemas Identificados

### P1: google-calendar — RECONSTRUÍDO ✅
- **Problema original:** Diretório `~/.config/opencode/google-calendar/` foi deletado.
- **Solução:** Projeto reconstruído do zero em JavaScript puro (ESM) com `@modelcontextprotocol/sdk` + `googleapis`.
- **Stack:** Node.js ESM, sem TypeScript (evita overhead de compilação).
- **Tools:** `list_events`, `create_event`, `update_event`, `delete_event`.
- **Credenciais:** Reutilizadas do `~/.gemini/settings.json` (Client ID, Secret, Refresh Token).
- **Status:** Servidor MCP inicia e opera corretamente. Configurado no `opencode.json` global com acesso para agente IIVA.

### P2: n8n-mcp — IP Local ({{LAN_IP_VALIS}})
- **Problema:** IP da rede local do VALIS, não Tailscale
- **Risco:** Se o VALIS mudar de IP na LAN, o MCP quebra
- **Ação:** Reconfigurar para usar IP Tailscale (`{{TAILSCALE_IP_VALIS}}`) ou domínio `n8n.{{CLOUDFLARE_DOMAIN}}`

### P3: Contexto Excessivo
- 21 MCP servers total consomem tokens de contexto significativos
- Nem todo agente precisa de todo MCP
- **Ação:** Restringir MCPs por agente (ver Seção 3)

---

## 3. Escopo de MCPs por Agente

### Consultor (brainstorming, exploração)
| MCP | Justificativa |
| :--- | :--- |
| `context7` | Pesquisa de documentação técnica |
| `sequentialthinking` | Raciocínio estruturado |
| `wikipedia-mcp` | Pesquisa contextual |
| `gemini-api-docs` | Referência técnica |

### Arquiteto (design, topologia)
| MCP | Justificativa |
| :--- | :--- |
| `forgejo-nexus` | Gestão de Issues, repositórios |
| `context7` | Referência de frameworks |
| `sequentialthinking` | Análise estruturada |
| `docker-gateway` | Verificar containers e infra |

### Engenheiro (implementação)
| MCP | Justificativa |
| :--- | :--- |
| `forgejo-nexus` | Git operations |
| `docker-gateway` | Docker operations |
| `context7` | Docs de bibliotecas |
| `sequentialthinking` | Debug de lógica |
| `puppeteer` | Teste web |

### Debugger (diagnóstico)
| MCP | Justificativa |
| :--- | :--- |
| `docker-gateway` | Inspeção de containers |
| `homebutler` | Diagnóstico de sistema |
| `forgejo-nexus` | Logs de CI/CD |
| `sequentialthinking` | Análise de causa raiz |

### QA (validação)
| MCP | Justificativa |
| :--- | :--- |
| `forgejo-nexus` | Verificar commits e issues |
| `docker-gateway` | Validar containers |
| `puppeteer` | Teste visual de interfaces |

### IIVA (pedagógico)
| MCP | Justificativa |
| :--- | :--- |
| `google-calendar` | Agenda de aulas |
| `todoist` | Tarefas pedagógicas |
| `trello` | Kanban de alunos |
| `memory` | Memória de progresso |

### Mentor (carreira)
| MCP | Justificativa |
| :--- | :--- |
| `context7` | Pesquisa de tecnologias |
| `sequentialthinking` | Planejamento de carreira |
| `wikipedia-mcp` | Contexto acadêmico |
| `gemini-api-docs` | Referência técnica |

### Escritor (narrativa)
| MCP | Justificativa |
| :--- | :--- |
| `context7` | Pesquisa de referências |
| `wikipedia-mcp` | Contexto histórico |
| `sequentialthinking` | Estrutura narrativa |

---

## 4. Configuração Opencode

### 4.1 MCPs Globais (disponíveis para todos)
```jsonc
{
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "environment": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      }
    },
    "sequentialthinking": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "wikipedia": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-wikipedia"]
    },
    "docker-gateway": {
      "type": "local",
      "command": ["docker", "mcp", "gateway", "run"]
    }
  }
}
```

### 4.2 MCPs por Agente (restrição via tools)
Cada agente terá apenas os MCPs que precisa habilitados via glob patterns.

---

## 6. Ações Pendentes

- [x] **P1:** Reconstruir google-calendar MCP (JavaScript ESM, 4 tools)
- [x] **P2:** Documentar n8n-mcp com IP local como risco
- [x] **P3:** Configurar 13 MCPs no opencode.json global (incluindo google-calendar)
- [x] **P4:** Configurar restrição de MCPs por agente via glob patterns
- [ ] **P5:** Reconfigurar n8n-mcp para Tailscale (`{{TAILSCALE_IP_VALIS}}` ou `n8n.{{CLOUDFLARE_DOMAIN}}`)
- [ ] **P6:** Validar funcionamento de cada MCP no Opencode
- [ ] **P7:** Configurar variáveis de ambiente para secrets (FORGEJO_TOKEN, TODOIST_API_KEY, etc.)
- [ ] **P8:** Remover MCPs do Gemini settings após validação completa

---

## 6. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-01 | Gaff | Spec inicial criada |

---

*Assinado: Gaff, Arquiteto Chefe do Ecossistema Nexus.*
