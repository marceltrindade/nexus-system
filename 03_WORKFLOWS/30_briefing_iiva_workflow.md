---
title: "Briefing Diário IIVA — n8n Workflow"
date: "2026-06-15"
author: "Joi"
status: "active"
tags: [n8n, workflow, iiva, briefing, automacao]
---

# Briefing Diário IIVA

## Visão Geral

Workflow do n8n que detecta automaticamente quais aulas precisam ser preparadas para o dia seguinte, cruzando dados do Google Calendar com a API IIVA no VALIS.

## Estrutura do Workflow

**ID:** `7ajpmk2XtFly4AL4`
**URL:** https://n8n.{{CLOUDFLARE_DOMAIN}}/workflow/7ajpmk2XtFly4AL4
**Projeto:** Marcel Trindade (personal — `nP2svnqA8TXZKj6m`)
**Schedule:** Todo dia às **21:15** (horário de Brasília)

### Nodes (8)

```
⏰ Agendamento (Schedule Trigger — 21:15)
   ↓
📅 Calendario Amanha (Google Calendar → getAll events)
   ↓
👥 Buscar Alunos (HTTP GET → VALIS /alunos)
   ↓
📚 Buscar Aulas (HTTP GET → VALIS /aulas?data=<amanhã>)
   ↓
⚙️ Processar Briefing (Code JS → cruza as 3 fontes)
   ↓
🗄️ Salvar Briefing (Data Table → upsert)
   ↓
💬 Agrupar Mensagem (Code JS → agrega em 1 notificação)
   ↓
📱 Notificar Marcel (Telegram → Marcel DM)
```

### Nodes em Detalhe

#### Calendario Amanha
- **Tipo:** `n8n-nodes-base.googleCalendar` v1.3
- **Operação:** `event.getAll`
- **Calendário:** `marcelrtrindade.ii@gmail.com` (ID do email, NÃO "primary")
- **timeMin:** `$now.setZone("America/Sao_Paulo").plus(1, "days").startOf("day")`
- **timeMax:** `$now.setZone("America/Sao_Paulo").plus(2, "days").startOf("day")`
- **Options:** `singleEvents: true`, `orderBy: startTime`, timeZone America/Sao_Paulo
- **Config extra:** `alwaysOutputData: true`
- **Credential:** Google Calendar account (`r7KtJzktMrSzBukw`)

#### Buscar Alunos
- **Tipo:** `httpRequest` v4.4
- **URL:** `http://{{TAILSCALE_IP_VALIS}}:8000/alunos`
- **Config:** `executeOnce: true`

#### Buscar Aulas
- **Tipo:** `httpRequest` v4.4
- **URL:** `http://{{TAILSCALE_IP_VALIS}}:8000/aulas?data={{ $now.setZone(...).plus(1, "days").format("yyyy-MM-dd") }}`
- **Config:** `executeOnce: true`

#### Processar Briefing (Code JS)
- **Tipo:** `code` v2
- **Modo:** `runOnceForAllItems`
- **Acessa dados de outros nodes com:** `await $("NomeDoNode").all()`
  - ✅ Funciona com `await`
  - `fetch()` NÃO está disponível no sandbox (ReferenceError)
- **Lógica:**
  1. Pega eventos do Google Calendar
  2. Pega alunos da API IIVA
  3. Pega aulas já existentes para amanhã da API IIVA
  4. Filtra eventos: ignora terapia/uniasselvi/prova/reunião/dentista/médico/aniversário
  5. Match por nome: extrai nome do evento ("Aula Nome" → "Nome") e busca no array de alunos
  6. Para cada match, verifica se já existe aula no DB
  7. Output: array de objetos padronizados

#### Salvar Briefing (Data Table)
- **Operação:** `upsert`
- **Tabela:** `briefing_iiva` (`MODamyCn5kmXZOwq`)
- **Match por:** `data` + `aluno_id` (allConditions)
- **⚠️ Lição aprendida:** Colunas tipo `date` NÃO aceitam string vazia `""`. Usar `null` para valores vazios.

#### Agrupar Mensagem
- **Tipo:** `code` v2, `runOnceForAllItems`
- **Função:** Agrega múltiplos itens da Data Table em UMA mensagem única
- **Output:** `{ message: "📋 Briefing IIVA\n\n..." }`

#### Notificar Marcel
- **Tipo:** `telegram` v1.2
- **Chat ID:** `8787236902` (Marcel DM)
- **Parse mode:** Markdown
- **Credential:** Joy Nexus Bot Telegram (`HCI8MJRM9O8hr4J7`)

## Data Table: `briefing_iiva`

**ID:** `MODamyCn5kmXZOwq`
**Projeto:** `nP2svnqA8TXZKj6m`

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `data` | date | Data da aula (YYYY-MM-DD) |
| `aluno_nome` | string | Nome do aluno |
| `aluno_id` | number | ID do aluno na API IIVA |
| `horario` | string | Horário completo ISO |
| `nivel` | string | Nível do aluno |
| `status_aluno` | string | Status no sistema |
| `frequencia` | string | Frequência do aluno |
| `ultima_aula_numero` | number | Número da última aula no DB |
| `ultima_aula_data` | date | Data da última aula (nullable) |
| `tem_aula_calendario` | boolean | Tem evento no Google Calendar |
| `tem_aula_banco` | boolean | Já tem aula registrada no DB |
| `precisa_criar` | boolean | Precisa criar plano de aula |
| `status` | string | pendente / aprovado / criado / sem_aulas |
| `briefing_json` | string | JSON completo do evento + aluno |

## Ciclo Operacional

```
21:15 — n8n roda workflow
         → detecta aulas de amanhã
         → salva na Data Table
         → envia Telegram: "Briefing salvo"
           
[Usuário ativa]  "Joi, processa o briefing"
         → Joi lê Data Table via MCP
         → pergunta no Telegram: "Crio essas aulas?"
           
[Usuário aprova]  "Sim" / "Faz"
         → Joi cria arquivos .md no vault
         → Joi atualiza status na Data Table
         → "Tudo certo ✓"
```

## Google Calendar — Configuração

### Credencial OAuth2
- **Tipo:** `googleCalendarOAuth2Api`
- **ID:** `r7KtJzktMrSzBukw`
- **Nome:** Google Calendar account
- **Calendar ID:** `marcelrtrindade.ii@gmail.com` (email do Google, NÃO a palavra "primary")

### Token CLI (expirado)
- O token local em `~/.hermes/google_token.json` expirou em 30/05/2026
- Refresh token retorna `invalid_grant: Bad Request`
- Precisa reautorização manual para usar scripts CLI
- O n8n usa credencial OAuth2 separada (funcionando)

## Arquitetura

```
┌──────────┐     ┌─────────────────────┐     ┌──────────┐
│  UBIK    │     │  PRIS (n8n)         │     │  VALIS   │
│ (Joi)    │     │                      │     │          │
│          │     │  Schedule Trigger ───┼──→  │ IIVA API │
│  MCP ────┼──→  │  Google Calendar     │     │ :8000    │
│  tools   │     │  Data Table          │     │          │
│          │     │  Telegram            │     │ Watcher  │
│ SyncThing│     │                      │     │ Vault    │
└──────────┘     └─────────────────────┘     └──────────┘
```

## Limitações / Lições Aprendidas

1. **`fetch()` não disponível** — No Code node v2 (task runner), `fetch()` gera `ReferenceError`. Usar nós HTTP Request para chamadas externas ou `$("NodeName")` para acessar dados de outros nodes.
2. **`await $("NodeName")` funciona** — Para acessar dados de nodes anteriores, usar `await $("NodeName").all()`.
3. **Colunas `date` não aceitam `""`** — Valores vazios em colunas tipo `date` causam erro. Usar `null`.
4. **Google Calendar node precisa do email como calendar ID** — `"primary"` não funciona via SDK; usar o email da conta Google.
5. **Telegram envia 1 msg por item** — Se não agregar, cada linha da Data Table vira 1 notificação.
6. **`alwaysOutputData: true`** — Necessário no Google Calendar node para garantir que o workflow continue mesmo sem eventos no dia.

## Histórico

| Data | Mudança |
|------|---------|
| 2026-06-14 | Primeira versão do workflow criada (SDK) — falhou por calendar ID inválido |
| 2026-06-15 | Reconstruído do zero com `update_workflow`, IF node para empty case |
| 2026-06-15 | Simplificado: removido IF, código usa `await $()` + agregação de mensagem |
| 2026-06-15 | Workflow publicado e testado com dados reais (4 aulas detectadas) |
