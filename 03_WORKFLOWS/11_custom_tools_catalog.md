# 🛠️ Custom Tools do OpenCode — Catálogo Nexus

| Campo | Valor |
| :--- | :--- |
| **Código** | `03.11` |
| **Status** | Operacional |
| **Data** | 2026-04-01 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. O Que São Custom Tools

Custom Tools são funções executáveis que os agentes da Squad Nexus invocam diretamente durante conversas. Diferente dos MCPs (que são servidores externos), as tools são **scripts locais** com definições TypeScript que o LLM pode chamar como funções nativas.

### Diferença: Prompt vs Skill vs Tool vs MCP

| Tipo | Quando Carrega | Função |
|------|----------------|--------|
| **Prompt** | Sempre (ao iniciar sessão) | Define identidade e regras do agente |
| **Skill** | Sob demanda (agente decide) | Instruções especializadas para contexto |
| **Tool** | Sob demanda (agente invoca) | Executa ação real no sistema |
| **MCP** | Sempre (se habilitado) | Fornece ferramentas externas (APIs, bancos) |

---

## 2. Catálogo de Tools

### 2.1 `nexus_doctor`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Health check completo da malha Nexus (VALIS, PRIS, UBIK) |
| **Script** | `~/.config/opencode/tools/scripts/nexus-doctor.sh` |
| **Args** | `node` (opcional): "VALIS", "PRIS", "UBIK" ou omitir para todos |
| **Agentes** | Arquiteto, Engenheiro, Debugger, QA |
| **Verifica** | Ping, Tailscale, uptime, disco, memória, processos em estado D, containers Docker |
| **Detecção local** | Detecta automaticamente o nó local e executa sem SSH |

### 2.2 `nexus_newIssue`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Cria uma issue no repositório Forgejo do Nexus |
| **Script** | `~/.config/opencode/tools/scripts/nexus-new-issue.sh` |
| **Args** | `repo` (obrigatório), `title` (obrigatório), `body` (opcional), `labels` (opcional) |
| **Agentes** | Consultor, Arquiteto, Engenheiro, QA |
| **Features** | Resolve labels por nome → ID automaticamente via API Forgejo |

### 2.3 `nexus_newDoc`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Cria scaffold de documento Johnny.Decimal no Nexus-Docs |
| **Script** | `~/.config/opencode/tools/scripts/nexus-new-doc.sh` |
| **Args** | `category` (obrigatório), `subcategory` (obrigatório), `name` (obrigatório) |
| **Agentes** | Consultor, Arquiteto, QA |
| **Gera** | Template completo com metadata, seções padrão e histórico de mudanças |

### 2.4 `nexus_deploy`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Deploy e gestão de containers Docker na PRIS ou VALIS |
| **Script** | `~/.config/opencode/tools/scripts/nexus-deploy.sh` |
| **Args** | `node` (obrigatório), `action` (obrigatório), `container` (opcional) |
| **Agentes** | Arquiteto, Engenheiro, Debugger, QA |
| **Ações** | `status`, `restart`, `stop`, `start`, `logs`, `inspect`, `list` |

---

## 3. Matriz de Acesso por Agente

| Agente | doctor | newIssue | newDoc | deploy |
|--------|:-:|:-:|:-:|:-:|
| consultor | ❌ | ✅ | ✅ | ❌ |
| arquiteto | ✅ | ✅ | ✅ | ✅ |
| engenheiro | ✅ | ✅ | ❌ | ✅ |
| debugger | ✅ | ❌ | ❌ | ✅ |
| qa | ✅ | ✅ | ✅ | ✅ |
| iiva | ❌ | ❌ | ❌ | ❌ |
| mentor | ❌ | ❌ | ❌ | ❌ |
| escritor | ❌ | ❌ | ❌ | ❌ |

---

## 4. Localização dos Arquivos

### Tool Definitions (TypeScript)
```
~/.config/opencode/tools/
└── nexus.ts              # Definições das 4 tools
```

### Scripts (Shell)
```
~/.config/opencode/tools/scripts/
├── nexus-doctor.sh       # Health check dos 3 nós
├── nexus-new-issue.sh    # Cria issue no Forgejo
├── nexus-new-doc.sh      # Scaffold de documento JD
└── nexus-deploy.sh       # Deploy de containers
```

---

## 5. Configuração no opencode.json

### Globais (desabilitadas por padrão)
```jsonc
{
  "tools": {
    "nexus_*": false  // Desabilitadas globalmente
  }
}
```

### Por Agente (habilitadas seletivamente)
```jsonc
{
  "agent": {
    "debugger": {
      "tools": {
        "nexus_doctor": true,
        "nexus_deploy": true
      }
    }
  }
}
```

---

## 6. Como Adicionar uma Nova Tool

1. Criar o script em `~/.config/opencode/tools/scripts/<nome>.sh`
2. Adicionar definição em `~/.config/opencode/tools/nexus.ts` (ou novo arquivo `.ts`)
3. Adicionar `nexus_<nome>: false` no bloco `tools` global do `opencode.json`
4. Habilitar para agentes relevantes no bloco `agent`
5. Testar em dry-run: `bash ~/.config/opencode/tools/scripts/<nome>.sh`
6. Documentar neste catálogo
7. Commit + push

---

## 7. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-01 | Gaff | Catálogo inicial — 4 tools criadas e testadas |

---

*Assinado: Gaff, Arquiteto Chefe do Ecossistema Nexus.*
