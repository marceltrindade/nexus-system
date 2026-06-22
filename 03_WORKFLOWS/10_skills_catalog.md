# 🎓 Skills do OpenCode — Catálogo Nexus

| Campo | Valor |
| :--- | :--- |
| **Código** | `03.10` |
| **Status** | Operacional |
| **Data** | 2026-04-01 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. O Que São Skills

Skills são instruções especializadas que os agentes da Squad Nexus carregam **sob demanda** via a ferramenta nativa `skill`. Diferente dos prompts de agente (que são sempre carregados), skills são **opcionais e contextuais** — o agente decide carregar quando a situação exige.

### Diferença: Prompt vs Skill vs MCP

| Tipo | Quando Carrega | Função |
|------|----------------|--------|
| **Prompt** | Sempre (ao iniciar sessão) | Define a identidade e regras do agente |
| **Skill** | Sob demanda (agente decide) | Fornece instruções especializadas para uma tarefa |
| **MCP** | Sempre (se habilitado) | Fornece ferramentas externas (APIs, bancos, etc) |

---

## 2. Catálogo de Skills

### 2.1 `buster-friendly`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Protocolos de operação segura da PRIS (Buster Friendly Stack) |
| **Agentes** | Arquiteto, Engenheiro, Debugger |
| **Conteúdo** | Ordem de boot, quarentena de I/O (15 min), Play-Mode, Regra do 1, health checks, recuperação de emergência |
| **Gatilho** | Qualquer operação na PRIS (restart, config, diagnóstico) |

### 2.2 `johnny-decimal`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Sistema Johnny.Decimal de organização de arquivos e documentação |
| **Agentes** | Todos os 8 agentes |
| **Conteúdo** | Regras de naming, estrutura de pastas, symlinks, template de documentos, hierarquia da verdade |
| **Gatilho** | Criar, mover, renomear ou referenciar qualquer arquivo |

### 2.3 `forgejo-workflow`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Git flow soberano do Nexus — commits, pushes, issues no Forgejo |
| **Agentes** | Consultor, Arquiteto, Engenheiro, Debugger, QA |
| **Conteúdo** | Conventional commits, URLs SSH, labels, milestones, checklist pré-commit, regras de branch |
| **Gatilho** | Qualquer operação Git no ecossistema |

### 2.4 `iiva-prep`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Preparação de aulas da Idioma Independente — formato, paths, protocolos |
| **Agentes** | IIVA |
| **Conteúdo** | Template de plano de aula (YAML + Markdown), paths no Almox, gestão de alunos, resumo expandido |
| **Gatilho** | Preparar aulas, criar materiais, gerenciar dados de alunos |

### 2.5 `human-in-the-loop`

| Atributo | Valor |
|----------|-------|
| **Descrição** | Regras de aprovação — classificação read-only vs write, quando exigir aprovação de Marcel |
| **Agentes** | Todos os 8 agentes |
| **Conteúdo** | Matriz de operações, protocolo de aprovação, matriz de tools Nexus, exceções |
| **Gatilho** | Antes de qualquer operação que modifique estado do sistema |

---

## 3. Matriz de Acesso por Agente

| Agente | buster-friendly | johnny-decimal | forgejo-workflow | iiva-prep |
|--------|:-:|:-:|:-:|:-:|
| consultor | ❌ | ✅ | ✅ | ❌ | ✅ |
| arquiteto | ✅ | ✅ | ✅ | ❌ | ✅ |
| engenheiro | ✅ | ✅ | ✅ | ❌ | ✅ |
| debugger | ✅ | ❌ | ✅ | ❌ | ✅ |
| qa | ❌ | ✅ | ✅ | ❌ | ✅ |
| iiva | ❌ | ✅ | ❌ | ✅ | ✅ |
| mentor | ❌ | ✅ | ❌ | ❌ | ✅ |
| escritor | ❌ | ✅ | ❌ | ❌ | ✅ |

---

## 4. Localização dos Arquivos

### Global (todos os projetos)
```
~/.config/opencode/skills/
├── buster-friendly/SKILL.md
├── johnny-decimal/SKILL.md
├── forgejo-workflow/SKILL.md
└── iiva-prep/SKILL.md
```

### Project-local (Nexus-Docs)
```
Nexus-Docs/.opencode/skills/
├── buster-friendly/SKILL.md
├── johnny-decimal/SKILL.md
├── forgejo-workflow/SKILL.md
└── iiva-prep/SKILL.md
```

---

## 5. Configuração de Permissões

As permissões são definidas no `opencode.json`:

```jsonc
{
  "permission": {
    "skill": {
      "*": "allow"  // Default: todas as skills permitidas
    }
  },
  "agent": {
    "debugger": {
      "permission": {
        "skill": {
          "buster-friendly": "allow",
          "forgejo-workflow": "allow"
        }
      }
    }
  }
}
```

### Valores de Permissão

| Valor | Comportamento |
|-------|---------------|
| `allow` | Skill carrega imediatamente |
| `deny` | Skill oculta do agente, acesso rejeitado |
| `ask` | Usuário é perguntado antes de carregar |

---

## 6. Como Adicionar uma Nova Skill

1. Criar diretório: `~/.config/opencode/skills/<nome>/SKILL.md`
2. Nome: lowercase, hyphens, 1-64 chars (regex: `^[a-z0-9]+(-[a-z0-9]+)*$`)
3. Frontmatter obrigatório: `name` + `description` (1-1024 chars)
4. Adicionar permissão no `opencode.json` para os agentes relevantes
5. Copiar para `.opencode/skills/` no Nexus-Docs (project-local)
6. Documentar neste catálogo
7. Commit + push

---

## 7. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-01 | Gaff | Catálogo inicial — 4 skills criadas |

---

*Assinado: Gaff, Arquiteto Chefe do Ecossistema Nexus.*
