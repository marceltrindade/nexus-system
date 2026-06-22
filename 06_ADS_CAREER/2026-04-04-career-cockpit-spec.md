# 🎯 Career Cockpit: Spec Completa do Dashboard de Candidaturas

| Campo | Valor |
| :--- | :--- |
| **Código** | `06_ADS_CAREER` |
| **Status** | Planejado |
| **Data** | 2026-04-04 |
| **Autor** | Consultor |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir a visão, a arquitetura, a morada canônica no Johnny.Decimal, as etapas de implementação e o fluxo de handoff entre agentes para o projeto **Career Cockpit**: um dashboard local/self-hosted para acelerar candidaturas de Marcel a estágios em tecnologia.

O sistema deve reduzir atrito operacional na busca de vagas, centralizar snippets reutilizáveis de candidatura e permitir ingestão futura de vagas via n8n.

---

## 2. Problema que o Projeto Resolve

Hoje, a candidatura para vagas depende de memória, improviso e repetição manual de blocos como:

- resumo profissional
- experiências adaptadas para TI
- habilidades técnicas e comportamentais
- respostas para campos de formulário
- links e versões de currículo

Isso gera:

- inconsistência entre LinkedIn, currículo e formulários
- lentidão para responder vagas novas
- retrabalho em plataformas como LinkedIn, Gupy e afins
- perda de contexto entre uma candidatura e outra

---

## 3. Tese do Produto

O **Career Cockpit** será um painel soberano de candidatura, rodando em Docker e persistindo dados em SQLite, com foco em:

1. armazenar a base-mestre de respostas e narrativas profissionais
2. pesquisar rapidamente qualquer trecho necessário
3. copiar textos com 1 clique durante o preenchimento de vagas
4. registrar vagas e candidaturas
5. receber vagas automaticamente via n8n em etapas futuras

---

## 4. Morada Canônica no JD

## 4.1 Projeto ativo

Morada final do projeto no Johnny.Decimal:

- `/mnt/almox/JD/30-39 Tech Development/39 Career Cockpit/`

## 4.2 Motivo da escolha

O projeto é:

- um produto técnico novo
- diretamente ligado à estratégia de candidatura
- mas implementado como software e dashboard operacional

Portanto, ele pertence mais a **Tech & Projects** do que à área genérica de carreira.

## 4.3 Documentação canônica

A documentação-mãe deve viver em:

- `/mnt/almox/JD/00-09 System/05 Architecture/Nexus-Docs/06_ADS_CAREER/`

Isso garante alinhamento com o roadmap de carreira já existente.

---

## 5. Escopo

## 5.1 Escopo MVP

O MVP deve incluir apenas o que acelera candidatura imediatamente:

### A. Biblioteca de Snippets
- resumo profissional
- apresentação curta
- objetivo
- respostas para perguntas frequentes
- versões curta/média/longa
- tags por contexto
- botão **copiar**

### B. Perfil Profissional Base
- headline
- about
- contatos
- links principais
- foco de vagas
- disponibilidade

### C. Experiências Traduzidas
- experiências profissionais adaptadas para TI
- versões curta e longa
- tags por competência

### D. Habilidades
- técnicas
- comportamentais
- ferramentas
- idiomas

### E. Busca Interna
- busca textual rápida
- filtros por categoria, tom e contexto

## 5.2 Escopo Fase 2

- cadastro de vagas manual
- status da candidatura
- notas por vaga
- vínculo entre vaga e snippets usados

## 5.3 Escopo Fase 3

- ingestão automática de vagas via n8n
- score de aderência por tags
- inbox de vagas recentes

## 5.4 Escopo Fase 4

- múltiplas versões de currículo
- geração assistida de resposta por vaga
- “pacote de candidatura” ideal por vaga

---

## 6. Fora de Escopo Inicial

Não entra no MVP:

- autenticação pública/multiusuário
- deploy público na internet
- IA generativa embutida no dashboard
- scraping direto dentro da aplicação
- analytics complexos
- sistema de mensagens para recrutadores

---

## 7. Requisitos Funcionais

## 7.1 Biblioteca de Snippets

O sistema deve permitir:

- criar snippet
- editar snippet
- arquivar snippet
- marcar snippet como favorito
- pesquisar snippet por texto
- filtrar snippet por categoria
- copiar snippet com 1 clique

## 7.2 Estrutura de classificação

Cada snippet deve ter, no mínimo:

- título
- categoria
- subtipo
- tom
- tamanho
- conteúdo
- tags
- ativo/inativo

## 7.3 Vagas

Cada vaga deve permitir registrar:

- empresa
- cargo
- link
- origem
- localização
- descrição resumida
- status
- aderência
- observações

## 7.4 Candidaturas

Cada candidatura deve registrar:

- vaga associada
- data da aplicação
- currículo usado
- snippets usados
- status atual
- notas livres

## 7.5 UX de cópia rápida

Todo bloco textual reutilizável deve possuir botão visível de **copiar**.

Essa é uma feature central, não cosmética.

---

## 8. Requisitos Não Funcionais

## 8.1 Arquitetura operacional

- rodar localmente em Docker
- persistir em SQLite
- inicialização simples via Docker Compose
- sem dependência obrigatória de nuvem

## 8.2 Performance

- abertura rápida
- busca instantânea em base pequena/média
- experiência fluida em desktop

## 8.3 Segurança

- aplicação local por padrão
- sem exposição pública no MVP
- sem segredos hardcoded no repositório

## 8.4 Backup

- banco SQLite em volume persistente
- backups simples e previsíveis

---

## 9. Stack Recomendada

## 9.1 Decisão arquitetural inicial

Stack recomendada para o MVP:

- **Frontend:** SvelteKit
- **Backend/API:** FastAPI
- **Banco:** SQLite
- **Busca textual:** SQLite FTS5
- **Empacotamento:** Docker Compose
- **Ingestão futura:** n8n

## 9.2 Motivos

### SvelteKit
- excelente para dashboard leve
- UI rápida
- fácil construir botão de copiar e filtros

### FastAPI
- alta velocidade de implementação
- boa modelagem para CRUD e APIs internas
- confortável para evoluir integrações futuras

### SQLite
- suficiente para uso pessoal
- simples de versionar, migrar e backupar
- encaixa no escopo local-first

---

## 10. Modelo de Dados Inicial

## 10.1 Tabela `profile`

```sql
CREATE TABLE profile (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    headline TEXT,
    about TEXT,
    city TEXT,
    email TEXT,
    phone TEXT,
    linkedin_url TEXT,
    github_url TEXT,
    availability TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 10.2 Tabela `snippets`

```sql
CREATE TABLE snippets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    subtype TEXT,
    tone TEXT DEFAULT 'neutral',
    length TEXT DEFAULT 'medium',
    content TEXT NOT NULL,
    tags TEXT,
    active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 10.3 Tabela `experiences`

```sql
CREATE TABLE experiences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    organization TEXT,
    start_date TEXT,
    end_date TEXT,
    is_current INTEGER DEFAULT 0,
    short_version TEXT,
    long_version TEXT,
    tags TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 10.4 Tabela `skills`

```sql
CREATE TABLE skills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    kind TEXT NOT NULL,
    priority INTEGER DEFAULT 3,
    notes TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 10.5 Tabela `jobs`

```sql
CREATE TABLE jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source TEXT,
    title TEXT NOT NULL,
    company TEXT,
    location TEXT,
    url TEXT,
    summary TEXT,
    fit_score INTEGER DEFAULT 0,
    status TEXT DEFAULT 'new',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 10.6 Tabela `applications`

```sql
CREATE TABLE applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id INTEGER NOT NULL,
    applied_at DATETIME,
    resume_version TEXT,
    snippet_bundle TEXT,
    notes TEXT,
    status TEXT DEFAULT 'draft',
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);
```

---

## 11. Fluxos Principais do Usuário

## 11.1 Fluxo A — Preencher uma vaga manualmente

1. abrir o dashboard
2. pesquisar “resumo profissional”
3. copiar snippet com 1 clique
4. abrir “experiências”
5. copiar experiência curta relevante
6. concluir formulário da vaga

## 11.2 Fluxo B — Registrar uma vaga

1. colar link da vaga
2. registrar empresa, cargo e status
3. adicionar notas rápidas
4. marcar quais snippets foram usados

## 11.3 Fluxo C — Receber vagas do n8n

1. n8n busca vagas novas
2. n8n envia payload para API do Career Cockpit
3. dashboard mostra novas vagas em inbox
4. Marcel tria e muda o status

---

## 12. Roadmap por Etapas

## Etapa 0 — Documentação e Preparação

### Objetivo
Congelar escopo, morada JD, stack e modelo de handoff.

### Entregáveis
- spec aprovada
- diretório canônico criado
- estrutura inicial decidida

## Etapa 1 — Fundação Técnica

### Objetivo
Subir esqueleto do projeto com Docker, backend, frontend e banco.

### Entregáveis
- Docker Compose inicial
- app SvelteKit inicial
- API FastAPI inicial
- SQLite montado em volume persistente

## Etapa 2 — Biblioteca de Snippets

### Objetivo
Entregar o coração do MVP.

### Entregáveis
- CRUD de snippets
- filtros por categoria/tom/tamanho
- busca textual
- botão copiar

## Etapa 3 — Perfil, Experiências e Skills

### Objetivo
Completar a base-mestre de candidatura.

### Entregáveis
- telas de perfil
- cadastro de experiências
- cadastro de skills
- seed inicial com dados do Marcel

## Etapa 4 — Vagas e Candidaturas

### Objetivo
Permitir tracking mínimo do pipeline.

### Entregáveis
- cadastro de vagas
- status
- cadastro de candidaturas
- vínculo com currículo/snippets

## Etapa 5 — Integração com n8n

### Objetivo
Automatizar a chegada de vagas novas.

### Entregáveis
- endpoint de ingestão
- workflow n8n inicial
- marcação de origem e data

## Etapa 6 — Polimento e Evolução

### Objetivo
Melhorar usabilidade e preparar case de portfólio.

### Entregáveis
- UX refinada
- melhoria visual
- documentação de arquitetura
- narrativa de case

---

## 13. Matriz de Agentes e Handoffs

| Etapa | Agente Líder | Responsabilidade Principal | Handoff |
| :--- | :--- | :--- | :--- |
| 0 | **Consultor** | Refino do problema, escopo, naming e tese do produto | Passa spec ao Arquiteto |
| 1 | **Arquiteto** | Topologia, estrutura de pastas, stack, API e modelo de dados | Passa blueprint ao Engenheiro |
| 2-4 | **Engenheiro** | Implementação do dashboard, banco, API, frontend e Docker | Passa build e notas ao Debugger |
| 2-5 | **Debugger** | Diagnóstico de bugs, falhas de persistência, integrações e ajustes | Passa sistema estabilizado ao QA |
| 2-6 | **QA** | Validar usabilidade, copy flow, aderência do MVP ao problema real | Passa checklist ao Consultor/Marcel |
| 5 | **Arquiteto + Engenheiro** | Desenho e implementação da integração n8n | Passam integração ao QA |
| 6 | **Escritor** | Transformar o projeto em narrativa de portfólio/case | Passa texto ao Marcel |
| transversal | **Mentor** | Garantir aderência à estratégia de estágio e valor de carreira | Retroalimenta Consultor |

## 13.1 Regras de bastão

### Consultor → Arquiteto
- problema validado
- MVP fechado
- nome e morada aprovados

### Arquiteto → Engenheiro
- schema definido
- fluxos principais mapeados
- stack congelada para a etapa

### Engenheiro → Debugger
- build funcional
- instruções de execução
- bugs conhecidos documentados

### Debugger → QA
- causa raiz dos problemas já registrada
- sistema estável o suficiente para uso real

### QA → Marcel
- checklist com GO / NO-GO

---

## 14. Critérios de Aceite do MVP

O MVP será considerado pronto quando:

1. subir via Docker Compose sem ambiguidade
2. persistir dados em SQLite
3. permitir CRUD de snippets
4. pesquisar snippets por texto
5. copiar snippets com 1 clique
6. permitir editar perfil, experiências e skills
7. servir como ferramenta real em pelo menos 3 candidaturas

---

## 15. Riscos

## 15.1 Overengineering precoce

Risco: tentar construir o sistema final antes de validar o MVP.

### Mitigação
Congelar a Etapa 2 como meta operacional mínima.

## 15.2 Dependência excessiva de automação

Risco: n8n virar foco cedo demais e atrasar a utilidade prática.

### Mitigação
Ingestão automática só entra após snippets e tracking básico estarem funcionais.

## 15.3 UX complexa demais

Risco: o painel ficar bonito, mas lento para uso real durante candidatura.

### Mitigação
Priorizar velocidade de busca e cópia acima de ornamento.

---

## 16. Próximos Passos Imediatos

1. Aprovar esta spec como fonte de verdade.
2. Criar a pasta canônica do projeto no JD.
3. Criar o README inicial do projeto em `39 Career Cockpit`.
4. Iniciar a Etapa 1 com o agente **Arquiteto**.

---
*Assinado: Consultor, parceiro de estratégia e estruturação do Career Cockpit.*
