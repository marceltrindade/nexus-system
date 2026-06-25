# Nexus Docs — Índice

> Documentação de infraestrutura, sistema e arquitetura do ecossistema Nexus.
> **DRY:** Cada nó tem seu documento dedicado como fonte única. Documentos de resumo referenciam, nunca duplicam.

---

## 01_INFRA — Infraestrutura

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/01_INFRA/valis]] | **VALIS** — Node de infraestrutura (hardware, serviços, armazenamento, rede) |
| [[00_Nexus/01_INFRA/pris]] | **PRIS** — Node de automação (n8n, HA, Hermes Gateway) |
| [[00_Nexus/01_INFRA/deckard]] | **DECKARD** — Fallback workstation (Fedora 44 Sway, Presario CQ17) |
| [[00_Nexus/01_INFRA/ubik]] | **UBIK** — Workstation principal (PCWare A320G, Ryzen 3 3200G) |
| [[00_Nexus/01_INFRA/roy]] | **ROY** — Kodi Media Center (LibreELEC, Dell Inspiron 5447) |
| [[00_Nexus/01_INFRA/hardware]] | Tabela resumo de hardware (referencia docs dos nós) |
| [[00_Nexus/01_INFRA/network]] | Topologia de rede, IPs, DNS, Cloudflare Tunnels |
| [[00_Nexus/01_INFRA/docker_stack]] | Mapa de portas em uso no ecossistema |
| [[00_Nexus/01_INFRA/n8n]] | n8n: setup, workflows, API keys |
| [[00_Nexus/01_INFRA/n8n_mcp]] | n8n MCP: configuração do Model Context Protocol |
| [[00_Nexus/01_INFRA/hermes_profiles]] | **Hermes Agent** — perfis do ecossistema Nexus |

## 02_STORAGE — Armazenamento

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/02_STORAGE/database_spec]] | Especificação de bancos de dados do ecossistema |
| [[00_Nexus/02_STORAGE/johnny_decimal]] | Sistema Johnny Decimal para organização de diretórios |

## 03_WORKFLOWS — Workflows e Processos

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/03_WORKFLOWS/05_nexus_squad_protocol]] | Protocolo do Nexus Squad |
| [[00_Nexus/03_WORKFLOWS/09_mempalace_usage_guide]] | Guia de uso do Memory Palace |
| [[00_Nexus/03_WORKFLOWS/10_skills_catalog]] | Catálogo de skills |
| [[00_Nexus/03_WORKFLOWS/30_briefing_iiva_workflow]] | Briefing IIVA — workflow n8n |
| [[00_Nexus/03_WORKFLOWS/git_standard]] | Padrão Git do ecossistema |
| [[00_Nexus/03_WORKFLOWS/maintenance]] | Manutenção de rotina |

## 04_IDENTITY — Identidade

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/04_IDENTITY/user_profile]] | Perfil do usuário (Marcel) |
| [[00_Nexus/04_IDENTITY/personas/00_consultor]] | Persona: Consultor |
| [[00_Nexus/04_IDENTITY/personas/07_escritor]] | Persona: Escritor |

## 05_SYSTEM_DESIGN — Design de Sistema

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/05_SYSTEM_DESIGN/01_IIVA_MATURATION]] | Maturidade do sistema IIVA |
| [[00_Nexus/05_SYSTEM_DESIGN/09_NEXUS_PLAY_MODE_UPDATE]] | Modo Play do Nexus |
| [[00_Nexus/05_SYSTEM_DESIGN/11_MEMPALACE_INTEGRATION]] | Integração Memory Palace |

## 06_ADS_CAREER — Carreira ADS

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/06_ADS_CAREER/2026-03-29-avaliacao-i-banco-de-dados]] | Avaliação Banco de Dados |
| [[00_Nexus/06_ADS_CAREER/2026-04-04-career-cockpit-spec]] | Especificação Career Cockpit |

## 07_FUTURE_PROJECTS — Projetos Futuros

| Nota | Descrição |
|------|-----------|
| [[00_Nexus/07_FUTURE_PROJECTS/BusterFriendlyV3/ROADMAP]] | Buster Friendly V3 — Roadmap |
| [[00_Nexus/07_FUTURE_PROJECTS/BusterFriendlyV3/SPECIFICATION]] | Buster Friendly V3 — Especificação |

## 99_ARCHIVED — Arquivado

Projetos concluídos ou obsoletos (Buster Friendly, DUMB migration plans).

---

## AGENTS.md

O arquivo [[00_Nexus/AGENTS.md|AGENTS.md]] contém o contexto do projeto Nexus Docs para a Joi.

---

## Conexões no Second Brain

- [[AGENTS.md]] — AGENTS.md do Second Brain (regras para Joi)
- [[40_Areas/IIVA/_Mapeamento IIVA]] — Mapeamento de acoplamentos do IIVA
- [[40_Life/Finanças/_Base Financeira]] — Base financeira (referência Nexus via infra)
- [[30_Projects/SB-Nexus/SB-Nexus]] — Projeto de transformar SB em DB + API
- [[40_Life/Dividas Tecnicas/2026-06-12 VALIS - Diagnostico]] — Diagnóstico VALIS (arquivado — plano IIVA)
- [[30_Projects/API IIVA - Roteiro de Estudo]] — Roteiro de estudo da API IIVA
