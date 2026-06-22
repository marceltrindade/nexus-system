# AGENTS.md — Nexus Documentation Repository

> **Repository Type:** Pure documentation + knowledge management (Johnny.Decimal system)
> **Language:** Brazilian Portuguese (pt-BR)
> **Owner:** Marcel Trindade

---

## 1. Repository Overview

This is the **Nexus-Docs** repository — the single source of truth for the Nexus infrastructure ecosystem (VALIS, PRIS, UBIK). It contains operational manuals, agent personas, system design docs, and implementation logs. **There is no buildable application code.**

### Key Directories

| Path | Purpose |
| :--- | :--- |
| `00 Index/` | Johnny.Decimal index (JDex) |
| `01 Nodes/` | Per-node operational manuals |
| `05 Architecture/Nexus-Docs/` | Canonical documentation (infra, storage, workflows) |
| `05 Architecture/Nexus-Agents/` | AI squad persona definitions |
| `05 Architecture/Nexus-Docs/04_IMPLEMENTATION_LOG.md` | **Always update this** for any change |

---

## 2. Commands

### Shell Script (only executable code)
```bash
# Health check — run on UBIK
bash 05\ Architecture/Nexus-Docs/03_WORKFLOWS/scripts/nexus-doctor.sh
```

### Git Workflow
```bash
# Commits go to Forgejo on VALIS via Tailscale
git remote set-url origin ssh://git@{{TAILSCALE_IP_VALIS}}:222/marcel/Nexus-Docs.git
git add <file> && git commit -m "docs: <description>" && git push
```

### No build/lint/test pipeline
There are no test files, no linter configs, no CI/CD. Validation is manual via the `nexus-doctor.sh` script and peer review.

---

## 3. Code & Documentation Style

### 3.1 File Naming — Johnny.Decimal
- **All files/dirs** use JD numbering: `NN.CC_Name` or `NN_Name`
  - Examples: `00.00 JDex.md`, `01_INFRA/`, `05_nexus_squad_protocol.md`
- **Snake case** for multi-word names: `docker_stack.md`, `johnny_decimal.md`
- **ALL CAPS** for metadata files: `SYSTEMPROMPT.md`, `GEMINI.md`, `README.md`
- **Date-prefixed** for records: `2026-03-29-avaliacao-i-banco-de-dados.md`

### 3.2 Markdown Formatting
- **Headers:** H1 for title, H2 for sections, H3 for subsections, H4 for sub-subsections
- **Emoji section markers** are encouraged in headers (e.g., `## Hardware (Nexus Nodes)`)
- **Tables** for structured data (inventories, service mappings, IP tables)
- **Fenced code blocks** with language hints: `bash`, `yaml`, `sql`, `json`, `ini`
- **Blockquotes** (`> `) for warnings, mandates, and important notes
- **Horizontal rules** (`---`) as section dividers
- **Signatures:** Documents end with italicized attribution: `*Assinado: Gaff, Zelador de Infraestrutura.*`

### 3.3 Document Template
Every operational document follows this structure:
1. Title with emoji + system code
2. Metadata: Code, Status, Date, Author, Reviewer
3. Change History table (for ops manuals)
4. Introduction and Governance
5. Technical Specifications
6. Protocols/Procedures (numbered lists)
7. Troubleshooting tables
8. Signature line

### 3.4 Shell Script Style (nexus-doctor.sh)
- Shebang: `#!/bin/bash`
- Variables: `UPPER_SNAKE_CASE`
- No `set -e` — errors handled via explicit `if/else` checks
- Section headers: `echo -e "\n--- Section Name ---"`
- Indentation: 4 spaces inside blocks
- Comments: `#` prefix, section headers with `# ---`

### 3.5 SQL Conventions (from database_spec.md)
- Tables/columns: `snake_case`
- Primary keys: `INTEGER PRIMARY KEY AUTOINCREMENT`
- Foreign keys: explicit `ON DELETE CASCADE` or `ON DELETE SET NULL`
- Defaults: `DEFAULT CURRENT_TIMESTAMP`, `DEFAULT 'unknown'`

---

## 4. Agent Squad Protocol

This repo defines 8 AI personas (Consultor, Arquiteto/Gaff, Engenheiro, Debugger, QA, IIVA, Mentor, Escritor). Each has:
- `SYSTEMPROMPT.md` — full operational protocol
- `GEMINI.md` — redirect to canonical docs

### Core Mandates (all agents)
1. **KNOWLEDGE FIRST:** Read `Nexus-Docs` before any action
2. **TRUTH HIERARCHY:** Local docs > MCP data > user prompt > LLM training = NULL
3. **DRY RUN:** Validate before any destructive command
4. **LOG EVERYTHING:** Update `04_IMPLEMENTATION_LOG.md` after any change
5. **GIT SOVEREIGNTY:** Commit and push to Forgejo (VALIS) after every change
6. **DOCUMENT AS YOU GO:** Após cada mudança significativa (instalação, alteração de config, remoção de serviço, atualização de doc), faça uma pausa e registre no `04_IMPLEMENTATION_LOG.md` antes de prosseguir. O ciclo é: **fazer → documentar → commitar → continuar**. Nunca acumule múltiplas mudanças não documentadas.

---

## 5. Infrastructure Reference

> **DRY:** Cada nó tem seu documento dedicado. A tabela abaixo é resumo rápido.

### Nodes (Tailscale)
| Node | IP | Role | Doc |
| :--- | :--- | :--- | :--- |
| VALIS | `{{TAILSCALE_IP_VALIS}}` | Infra, DNS, Forgejo | [[00_Nexus/01_INFRA/valis]] |
| PRIS | `{{TAILSCALE_IP_PRIS}}` | Automação (n8n, HA, Hermes) | [[00_Nexus/01_INFRA/pris]] |
| DECKARD | `{{TAILSCALE_IP_DECKARD}}` | Fallback workstation (Fedora 44) | [[00_Nexus/01_INFRA/deckard]] |
| UBIK | `{{TAILSCALE_IP_UBIK}}` | Workstation, source of truth | [[00_Nexus/01_INFRA/ubik]] |

### Storage Tiers
- **Tier 1:** SSD System (OS only, stateless)
- **Tier 2:** SSD Home (active projects, dotfiles)
- **Tier 3:** HDD Almox (`/mnt/almox`) — **final destination** for all JD data

### Docker
- Use **Docker Engine native** (context `default`) for containers accessing `/mnt/almox`
- Docker Desktop VM cannot mount `/mnt/almox` paths

---

## 6. Git Standards

- **Server:** Forgejo (VALIS) — private repos
- **SSH:** `ssh://git@{{TAILSCALE_IP_VALIS}}:222/marcel/<repo>.git` (Tailscale only)
- **Issue labels:** `kind/bug`, `kind/task`, `kind/feature`, `kind/enhancement`
- **Milestones:** `[PROJETO] Sprint XX: Descricao`
- **Commit messages:** Conventional — `docs:`, `meta:`, `fix:`, `feat:`

---

## 7. Critical Rules

1. **🔴 NEXUS DOCS FIRST — REGRA INQUEBRÁVEL:** A documentação Nexus deve estar **sempre atualizada**. Toda alteração de infraestrutura (criação/remoção de serviço, mudança de config, alteração de hardware, mudança de IP/rota) deve ser documentada no doc do nó correspondente e registrada no `04_IMPLEMENTATION_LOG.md` **antes de prosseguir para a próxima ação**. Se a documentação estiver desatualizada, **pare e corrija** antes de qualquer outra ação.
2. **Never** use volatile device names (`/dev/sda`) — always use mount points (`/mnt/almox`, `/mnt/storage`)
3. **Never** modify docs without updating `04_IMPLEMENTATION_LOG.md`
4. **Never** push to GitHub — Forgejo (VALIS) is the source of truth
5. **Always** use symlinks (`ln -s`) for Tier 3 files needed on Tier 2
6. **Always** write in Brazilian Portuguese
7. **Never** fill out logs before the actual occurrence of events (e.g., never create lesson logs before classes happen)
