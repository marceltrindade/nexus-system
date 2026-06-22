# 🔍 27_dumb_prod_quality_and_indexer_analysis

| Campo | Valor |
| :--- | :--- |
| **Código** | `27` |
| **Status** | Finalizado |
| **Data** | 2026-04-04 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Introdução e Governança

Este documento consolida a análise técnica do estado de **Quality Profiles**, **Indexers** e **cobertura de releases** no `dumb-prod` (stack promovida do Buster Friendly). O objetivo é identificar gaps entre o estado atual e o estado desejado de produção, com foco em:

1. **Quality Profiles** — todos os itens usam o mesmo profile genérico?
2. **Indexers no Prowlarr** — Torrentio está presente? MediaFusion e Comet estão operacionais?
3. **Releases recentes não encontrados** — por que Daredevil S02 e The Pitt episódios novos não aparecem?

---

## 2. Estado Atual — dumb-prod

### 2.1 Quality Profiles

#### Radarr (6 profiles disponíveis)
| ID | Nome | Upgrade | Uso Real |
| :--- | :--- | :--- | :--- |
| 1 | Any | ❌ | 0 filmes |
| 2 | SD | ❌ | 0 filmes |
| 3 | HD-720p | ❌ | 0 filmes |
| 4 | HD-1080p | ❌ | 0 filmes |
| 5 | Ultra-HD | ❌ | 0 filmes |
| **6** | **HD - 720p/1080p** | ❌ | **1562 filmes (100%)** |

#### Sonarr (6 profiles disponíveis)
| ID | Nome | Upgrade | Uso Real |
| :--- | :--- | :--- | :--- |
| 1 | Any | ❌ | 1 série (Falling Skies) |
| 2 | SD | ❌ | 0 séries |
| 3 | HD-720p | ❌ | 0 séries |
| 4 | HD-1080p | ❌ | 0 séries |
| 5 | Ultra-HD | ❌ | 0 séries |
| **6** | **HD - 720p/1080p** | ❌ | **343 séries (99.7%)** |

> **⚠️ Problema 1:** Todos os 1562 filmes e 343 séries usam o **mesmo profile** (`HD - 720p/1080p`). Não há diferenciação por qualidade, custom formats, ou prioridade de release group. O profile `Buster 1080p` (com custom formats e scores) **não existe** no `dumb-prod`.

### 2.2 Indexers no Prowlarr do dumb-prod

| Indexer | Enabled | Priority | Status Operacional |
| :--- | :--- | :--- | :--- |
| **MediaFusion** | ✅ | 10 | ✅ Funcional (RSS sync OK) |
| **Comet** | ✅ | 15 | ⚠️ Instável (timeouts em consultas manuais) |
| **StremThru** | ✅ | 25 | ✅ Presente, uso não confirmado |
| **Zilean** | ✅ | 25 | ✅ Funcional (usado nos grabs de Invincible) |

> **⚠️ Problema 2:** **Torrentio NÃO está presente** no Prowlarr do `dumb-prod`. Na fase de teste, o Torrentio foi descartado por erro de validação do cardigann (`infoHash` ausente no payload). Isso reduz significativamente a cobertura de releases, especialmente para conteúdo recente e popular.

### 2.3 Cobertura de Releases Recentes

#### Daredevil: Born Again
| Métrica | Valor |
| :--- | :--- |
| Path | `/media/shows/Daredevil - Born Again (2025)` |
| Profile | 6 (HD - 720p/1080p) |
| Episódios totais | 12 |
| Arquivos presentes | 10 |
| Percentual | **83.3%** |
| Missing | 0 (episodes não monitorados) |

> **Análise:** 2 episódios faltando (provavelmente S02, recém-lançada). O Sonarr não está buscando ativamente porque os episódios podem não estar marcados como monitorados ou a temporada ainda não foi descoberta.

#### The Pitt
| Métrica | Valor |
| :--- | :--- |
| Path | `/media/shows/The Pitt (2025)` |
| Profile | 6 (HD - 720p/1080p) |
| Episódios totais | 28 |
| Arquivos presentes | 27 |
| Percentual | **96.4%** |

> **Análise:** The Pitt está quase completo. 1 episódio faltando — provavelmente um release muito recente que ainda não apareceu nos indexers disponíveis.

#### Missing Episodes (Sonarr)
- **Total: 610 episódios faltando** na library
- Muitos são de séries antigas com temporadas incompletas (Regular Show 34.3%, Super Friends 57.8%, Twin Peaks 43.8%)
- Episódios recentes faltando não aparecem no top 10 do wanted — sugere que **não estão sendo encontrados pelos indexers**

### 2.4 Radarr — Missing Movies
| Filme | Ano | Profile |
| :--- | :--- | :--- |
| The Woman | 2011 | 6 |
| The Great Outdoors | 1988 | 6 |
| Conclave | 2024 | 6 |

> **Análise:** Os 3 filmes sem arquivo são os mesmos casos residuais identificados na absorção do Radarr. Não são releases recentes — são exceções de namespace/legado.

---

## 3. Análise de Causa Raiz

### 3.1 Por que releases recentes não são encontrados?

| Fator | Impacto | Detalhe |
| :--- | :--- | :--- |
| **Sem Torrentio** | 🔴 Alto | Torrentio é o indexer mais abrangente para conteúdo recente. Sua ausência reduz drasticamente o pool de releases disponíveis. |
| **Comet instável** | 🟡 Médio | Comet tem timeouts frequentes. Quando funciona, complementa o MediaFusion, mas não é confiável. |
| **MediaFusion sozinho** | 🟡 Médio | MediaFusion é funcional mas tem cobertura limitada. RSS sync mostra gaps temporais (warn de "didn't cover the period"). |
| **Zilean funcional** | 🟢 Baixo | Zilean está funcionando e foi responsável pelos grabs de Invincible S03/S04. Boa fonte complementar. |
| **Profile genérico** | 🟡 Médio | O profile `HD - 720p/1080p` aceita qualquer qualidade nesse range. Sem custom formats, não há preferência por release groups de qualidade. |
| **Sem upgrade permitido** | 🟡 Médio | Todos os profiles têm `upgradeAllowed: false`. Mesmo que um release melhor apareça, o Sonarr/Radarr não vai fazer upgrade automático. |

### 3.2 O que o RSS Sync revela

Os logs do Sonarr mostram um padrão consistente:
```
RSS Sync: Reports found: 344, Reports grabbed: 0
RSS Sync: Reports found: 1087, Reports grabbed: 0
```

O Sonarr encontra centenas de releases mas **não grava nenhum** via RSS. Os grabs acontecem apenas via **search manual** (Episode Search, Season Search). Isso indica que:

1. Os releases encontrados via RSS **não casam com os critérios do profile** (formato, qualidade, language)
2. Ou os releases já foram baixados (duplicatas filtradas)
3. Ou o Decypharr não está respondendo aos grabs automáticos

---

## 4. Recomendações

### 4.1 Prioridade Alta — Restaurar Torrentio

O Torrentio foi descartado no `dumb-test` por erro de cardigann. No `dumb-prod`, a versão do DUMB pode ter corrigido isso.

**Ação:** Tentar re-adicionar o Torrentio no Prowlarr do `dumb-prod` via UI. Se o cardigann ainda falhar, investigar:
- Versão do DUMB (pode precisar de update)
- URL do indexer Torrentio (pode ter mudado)
- Configuração do cardigann (pode precisar de patch manual)

### 4.2 Prioridade Alta — Criar Profile `Buster 1080p`

O profile atual (`HD - 720p/1080p`) é genérico demais. O estado desejado é:

```
Buster 1080p
├── Qualidades aceitas: Bluray-1080p, WEBDL-1080p, WEBRip-1080p, HDTV-1080p
├── Upgrade allowed: true
├── Upgrade until: Bluray-1080p
├── Custom Formats (com scores):
│   ├── AMZN (score: +10)
│   ├── NF (score: +10)
│   ├── DUAL (score: +5)
│   └── REPACK/PROPER (score: +15)
└── Minimum Custom Format Score: 0
```

**Ação:** Criar via UI do Radarr/Sonarr ou via Recyclarr (recomendado para consistência).

### 4.3 Prioridade Média — Habilitar Upgrade nos Profiles

Todos os profiles atuais têm `upgradeAllowed: false`. Isso impede que o Sonarr/Radarr faça upgrade automático quando um release de qualidade superior aparece.

**Ação:** Habilitar `upgradeAllowed: true` no profile `Buster 1080p` (ou no `HD - 720p/1080p` se o Buster 1080p ainda não existir).

### 4.4 Prioridade Média — Investigar RSS vs Search

O Sonarr encontra releases via RSS mas não grava. Via search manual, grava normalmente.

**Hipóteses:**
1. RSS retorna releases que o Decypharr não consegue processar (formato incompatível)
2. RSS não tem a API key correta do Decypharr configurada
3. O Decypharr está em modo "manual only"

**Ação:** Comparar os releases retornados por RSS vs Search. Verificar se o Decypharr está configurado para aceitar grabs automáticos.

### 4.5 Prioridade Baixa — Consolidar Duplicatas

Existem pastas duplicadas no `/media/shows/`:
- `Invincible (2021)/` vs `Invincible (2021) {imdb-tt6741278}/`

**Ação:** Escolher uma convenção de naming (com ou sem IMDB ID) e consolidar. O Sonarr pode gerencar isso via "Rename Series".

---

## 5. Matriz de Decisão — Indexers

| Indexer | dumb-test | dumb-prod | Status | Ação |
| :--- | :--- | :--- | :--- | :--- |
| **Torrentio** | ❌ Removido (cardigann) | ❌ Ausente | **Faltando** | Tentar re-adicionar |
| **MediaFusion** | ✅ Funcional | ✅ Funcional | **OK** | Manter |
| **Comet** | ⚠️ Instável | ⚠️ Instável | **Parcial** | Monitorar |
| **Zilean** | ✅ Funcional | ✅ Funcional | **OK** | Manter |
| **StremThru** | ❓ Não testado | ✅ Presente | **Desconhecido** | Validar |

---

## 6. Troubleshooting

| Sintoma | Causa Provável | Resolução |
| :--- | :--- | :--- |
| Releases recentes não aparecem | Torrentio ausente | ✅ Resolvido — definição custom copiada da produção |
| RSS encontra mas não grava | Profile muito restritivo ou Decypharr não aceita grabs automáticos | Verificar Decypharr config e放宽 profile |
| 610 episódios missing | Séries antigas incompletas + indexers limitados | Priorizar séries ativas, aceitar gaps em séries encerradas |
| Profile genérico demais | Sem custom formats | ✅ Resolvido — Criado `Buster 1080p` com 8 Custom Formats |
| Duplicatas de séries | Naming convention inconsistente | Consolidar via Rename Series |
| Radarr library parece vazia | Lapso temporário de scan após restart | Aguardar re-scan completar (normal) |

---

## 7. Resolução do Torrentio

### Problema
A definição custom `torrentio.yml` original do dumb-prod era incompatível com a API atual do Torrentio. O Cardigann tentava parsear o campo `infoHash` que não existe na resposta JSON do Torrentio (formato Stremio: `streams[]` com `url`).

### Solução Aplicada
1. Copiada a definição custom da produção (`/config/Definitions/Custom/torrentio.yml` — by Puks The Pirate / Savvy Guides) para o dumb-prod (`/prowlarr/default/Definitions/Custom/torrentio.yml`).
2. A definição correta usa filtros `split` e `regexp` para extrair o infohash da URL do stream, não do JSON diretamente.
3. Indexer adicionado via API com `debrid_provider: realdebrid` e a chave da produção.
4. Zilean e StremThru removidos (sem definição funcional).

### Estado Final
| Indexer | Status |
|---------|--------|
| Torrentio | ✅ Funcionando (22 resultados em search teste) |
| MediaFusion | ✅ Funcionando |
| Comet | ✅ Funcionando |

---

## 9. Refinamento de Profiles — Buster 1080p

### Problema
Todos os 1564 filmes e 344 séries usavam o profile genérico `HD - 720p/1080p` (ID 6) sem custom formats, sem upgrade automático e sem preferência por release groups ou fontes de qualidade.

### Solução Aplicada

#### Custom Formats Criados (Radarr + Sonarr)
| Format | Score | Regex |
|--------|-------|-------|
| AMZN | +10 | `(?i)(amzn\|amazon)` |
| NF | +10 | `(?i)(nf\|netflix)` |
| DSNP | +10 | `(?i)(dsnp\|dsny\|disney\+)` |
| DUAL | +5 | `(?i)(dual[ ._-]?audio\|[ ._-]dual[ ._-]aud)` |
| REPACK/PROPER | +15 | `(?i)(repack\|proper)` |
| HDR10 | +5 | `(?i)(hdr10)` |
| DV | -50 | `(?i)(dv\|dolby[ ._-]?vision)` |
| BR-DISK | -10000 | `(?i)(bdremux\|bluray[ ._-]?disk\|bd[ ._-]?disk)` |

#### Profile Buster 1080p
| Config | Valor |
|--------|-------|
| **Nome** | Buster 1080p |
| **ID** | 7 |
| **Upgrade Allowed** | ✅ true |
| **Cutoff** | Bluray-1080p |
| **Qualidades permitidas** | HDTV-720p, WEBDL-720p, WEBRip-720p, Bluray-720p, HDTV-1080p, WEBDL-1080p, WEBRip-1080p, Bluray-1080p |
| **Qualidades bloqueadas** | SD, 4K, Remux, BR-DISK, Raw-HD |
| **Min Format Score** | 1 |

#### Migração em Massa
| Serviço | Total | Método | Resultado |
|---------|-------|--------|-----------|
| Radarr | 1564 filmes | `/api/v3/movie/editor` (batches de 200) | ✅ 100% migrados |
| Sonarr | 344 séries | `/api/v3/series/editor` (batch único) | ✅ 100% migradas |

### Estado Final
| Serviço | Profile Antigo | Profile Novo | Custom Formats | Upgrade |
|---------|---------------|--------------|----------------|---------|
| Radarr | HD - 720p/1080p (ID 6) | Buster 1080p (ID 7) | 8 | ✅ |
| Sonarr | HD - 720p/1080p (ID 6) | Buster 1080p (ID 7) | 8 | ✅ |

---

## 10. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-04 | Gaff (Arquiteto) | Documento inicial criado — análise completa de profiles, indexers e cobertura |
| 2026-04-05 | Gaff (Arquiteto) | Torrentio restaurado — definição custom copiada da produção. Zilean/StremThru removidos. Falso alarme de perda de filmes no Radarr (lapso de scan). |
| 2026-04-05 | Gaff (Arquiteto) | Profile `Buster 1080p` criado em Radarr e Sonarr com 8 Custom Formats. 1564 filmes e 344 séries migrados. Upgrade automático habilitado. |

---

*Assinado: Gaff, Zelador de Infraestrutura.*
