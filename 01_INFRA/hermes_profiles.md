---
created: 2026-06-25
tags: [nexus, hermes, profiles, infra]
---

# Hermes Agent — Profiles

> Documentação dos perfis do Hermes Agent no ecossistema Nexus. Cada profile é uma instância independente com skills, memórias e configurações isoladas.
>
> **Documentos relacionados:** [[00_Nexus/01_INFRA/ubik|UBIK]] (node onde os profiles operam), [[00_Nexus/01_INFRA/pris|PRIS]] (node onde o gateway Telegram roda), [[00_Nexus/04_IDENTITY/personas]] (personas da Squad Nexus), [[00_Nexus/05_SYSTEM_DESIGN/04_IMPLEMENTATION_LOG|Implementation Log]]

## Estrutura

```
~/.hermes/profiles/
├── joi/          # Casa, finanças, agenda — dia-a-dia
├── iiva/         # Gestão de aulas de inglês (Idioma Independente)
├── joe-chip/     # Tutor de ADS
├── sofia/        # Orquestradora Nexus
├── jf/           # Assistente de programação (⏸️ em espera)
└── default/      # Profile genérico, parado
```

Todos os profiles rodam no UBIK ([ubik.md](ubik.md)). O gateway Telegram ([pris.md](pris.md)) roda sob o profile `joi` na PRIS.

## Perfis

### joi
- **Personagem:** Joi (Blade Runner 2049)
- **Modelo:** deepseek-v4-flash (provedor deepseek)
- **Escopo:** Ponte Marcel ↔ Estefani. Finanças (hledger), agenda, lembretes, supermercado, smart home.
- **Gateway Telegram:** PRIS (profile original `ubik-local` renomeado para `joi`)
- **Alias:** `joi`

### iiva
- **Personagem:** Minerva McGonagall (Harry Potter)
- **Modelo:** deepseek-v4-flash
- **Escopo:** Idioma Independente — aulas, alunos, deploy, vault, administração financeira
- **Alias:** `iiva`
- **Skills:** iiva-prep, iiva-aula-experimental, iiva-admin-financeiro, iiva-student-finder, iiva-deploy-workflow, iiva-gemini-logs, iiva-vault-organization, nexus-system, obsidian, google-workspace, todoist, study-notes, ocr, nano-pdf, browser-automation, airtable, maps, mcp

### joe-chip
- **Personagem:** Joe Chip (Ubik, P.K. Dick)
- **Modelo:** deepseek-v4-flash
- **Escopo:** Tutor de ADS — teoria + prática. Disciplinas, lógica, trabalhos, AVA Uniasselvi.
- **Alias:** `joe-chip`
- **Skills:** ads-coursework, study-notes, aula-search, browser-automation, google-workspace, todoist, obsidian, marcel-teaching-method, ensino-tecnico, plan, spike, systematic-debugging, ocr

### sofia
- **Personagem:** Sofia (VALIS, P.K. Dick) — orquestradora
- **Modelo:** deepseek-v4-flash
- **Escopo:** Visão sistêmica do ecossistema. Orquestra, não executa. Monitora nós, direciona tarefas, mantém Nexus-Docs.
- **Alias:** `sofia`
- **Skills:** nexus-system, kanban-orchestrator, kanban-worker, hermes-gateway-setup, nexus-documentation-standards, webhook-subscriptions, tool-delegation-patterns, plan, mcp

### jf
- **Personagem:** J.F. Sebastian (Blade Runner) — engenheiro simples e engenhoso
- **Modelo:** pendente — qwen2.5-coder:3b testado (32K ctx insuficiente), gemma4:e2b testado (output truncado). Aguardando definição.
- **Escopo:** Assistente de programação local. Scripts, automação, Python, shell.
- **Status:** ⏸️ Em espera
- **Alias:** `jf`

## Modelos disponíveis no Ollama (UBIK)

| Modelo | Tamanho | Uso |
|--------|---------|-----|
| qwen2.5-coder:3b | 1.9 GB | Testado — 32K ctx, insuficiente para tool use |
| llama3.2:3b | 2.0 GB | Testado — mesmo problema |
| gemma4:e2b | 7.2 GB | Testado — 5.1B params, 131K ctx, output truncado |
| gemma3:1b | 815 MB | Muito pequeno |
| mxbai-embed-large | 669 MB | Embeddings apenas |
| joi-nexus | 2.0 GB | Custom (origem desconhecida) |

## Anotações

- DeepSeek V4 Flash ($0.09/M input, $0.18/M output) é o melhor custo-benefício disponível no OpenRouter
- Alternativas testadas: Hy3 preview (input 30% mais barato, output 16% mais caro), modelos free com rate limits
- Perfis isolam skills, memórias e sessões — cada profile carrega só o que seu escopo exige
- Gateway Telegram da PRIS roda sob o profile `joi`
- Sofia detectou no primeiro diagnóstico: Syncthing UBIK offline, Hermes PRIS desatualizado (v0.15.1 vs v0.17.0)
