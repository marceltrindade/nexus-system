# 🔧 28_buster_1080p_profile_configuration

| Campo | Valor |
| :--- | :--- |
| **Código** | `28` |
| **Status** | Finalizado |
| **Data** | 2026-04-05 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Introdução e Governança

Este documento registra a configuração completa do profile **Buster 1080p** aplicado ao Radarr e Sonarr do `dumb-prod` (stack Buster Friendly na PRIS). O objetivo era substituir o profile genérico `HD - 720p/1080p` por um profile com custom formats, upgrade automático e preferência por releases de qualidade.

**Escopo:**
- Radarr (1564 filmes)
- Sonarr (344 séries)
- dumb-prod container na PRIS (`{{TAILSCALE_IP_PRIS}}`)

---

## 2. Estado Anterior

### Problema Identificado
Todos os itens da library usavam o mesmo profile genérico:

| Serviço | Profile | ID | Upgrade | Custom Formats |
|---------|---------|----|---------|----------------|
| Radarr | HD - 720p/1080p | 6 | ❌ false | 0 |
| Sonarr | HD - 720p/1080p | 6 | ❌ false | 0 |

**Consequências:**
- Sem preferência por fonte (AMZN, NF, DSNP)
- Sem preferência por áudio dual (PT-BR)
- Sem preferência por REPACK/PROPER
- Sem penalização para Dolby Vision (incompatível com TVs SDR)
- Sem bloqueio de BR-DISK (arquivos enormes, não utilizáveis)
- Sem upgrade automático quando release melhor aparece

---

## 3. Custom Formats

### 3.1 Tabela de Scores

| Format | Score | Regex | Descrição |
|--------|-------|-------|-----------|
| **AMZN** | +10 | `(?i)(amzn\|amazon)` | Amazon Prime — boa qualidade de encode |
| **NF** | +10 | `(?i)(nf\|netflix)` | Netflix — boa qualidade de encode |
| **DSNP** | +10 | `(?i)(dsnp\|dsny\|disney\+)` | Disney+ — boa qualidade de encode |
| **DUAL** | +5 | `(?i)(dual[ ._-]?audio\|[ ._-]dual[ ._-]aud)` | Áudio dual (PT-BR + EN) |
| **REPACK/PROPER** | +15 | `(?i)(repack\|proper)` | Versão corrigida de release com defeito |
| **HDR10** | +5 | `(?i)(hdr10)` | HDR10 — preferível para TVs HDR |
| **DV** | -50 | `(?i)(dv\|dolby[ ._-]?vision)` | Dolby Vision — indesejável para TVs SDR |
| **BR-DISK** | -10000 | `(?i)(bdremux\|bluray[ ._-]?disk\|bd[ ._-]?disk)` | Bluray Disk — muito grande, não utilizável |

### 3.2 Payloads de Criação (Radarr)

Cada custom format foi criado via `POST /api/v3/customformat`:

```json
{
  "name": "AMZN",
  "includeCustomFormatWhenRenaming": false,
  "specifications": [{
    "name": "AMZN",
    "implementation": "ReleaseTitleSpecification",
    "negate": false,
    "required": true,
    "fields": [{"name": "value", "value": "(?i)(amzn|amazon)"}]
  }]
}
```

> **Nota:** O campo `fields` deve ser um **array de objetos**, não um objeto direto. Este foi o erro mais comum durante a criação.

### 3.3 IDs Atribuídos

| Format | Radarr ID | Sonarr ID |
|--------|-----------|-----------|
| AMZN | 1 | 1 |
| NF | 2 | 2 |
| DSNP | 3 | 3 |
| DUAL | 4 | 4 |
| REPACK/PROPER | 5 | 5 |
| HDR10 | 6 | 6 |
| DV | 7 | 7 |
| BR-DISK | 8 | 8 |

---

## 4. Profile Buster 1080p

### 4.1 Configuração

| Config | Valor |
|--------|-------|
| **Nome** | Buster 1080p |
| **ID** | 7 (Radarr e Sonarr) |
| **Upgrade Allowed** | `true` |
| **Cutoff** | Bluray-1080p |
| **Min Format Score** | 1 |
| **Cutoff Format Score** | 0 |

### 4.2 Qualidades Permitidas

| Qualidade | ID | Allowed |
|-----------|----|---------|
| HDTV-720p | 15 | ✅ |
| WEBDL-720p | 16 | ✅ |
| WEBRip-720p | 17 | ✅ |
| Bluray-720p | 18 | ✅ |
| HDTV-1080p | 19 | ✅ |
| WEBDL-1080p | 20 | ✅ |
| WEBRip-1080p | 21 | ✅ |
| Bluray-1080p | 22 | ✅ |

### 4.3 Qualidades Bloqueadas

| Qualidade | ID | Motivo |
|-----------|----|--------|
| Unknown | 1 | Sem qualidade |
| WORKPRINT | 2 | Versão de produção |
| CAM | 3 | Qualidade de câmera |
| TELESYNC | 4 | Qualidade de câmera |
| TELECINE | 5 | Qualidade de câmera |
| REGIONAL | 6 | Release regional |
| DVDSCR | 7 | Screener |
| SDTV | 8 | SD |
| DVD | 9 | SD |
| DVD-R | 10 | SD |
| WEBDL-480p | 11 | SD |
| WEBRip-480p | 12 | SD |
| Bluray-480p | 13 | SD |
| Bluray-576p | 14 | SD |
| Remux-1080p | 23 | Muito grande |
| HDTV-2160p | 24 | 4K — não queremos |
| WEBDL-2160p | 25 | 4K — não queremos |
| WEBRip-2160p | 26 | 4K — não queremos |
| Bluray-2160p | 27 | 4K — não queremos |
| Remux-2160p | 28 | 4K — não queremos |
| BR-DISK | 29 | Disco completo — não utilizável |
| Raw-HD | 30 | Raw — não utilizável |

### 4.4 Format Items (Scores)

```json
"formatItems": [
  {"format": 1, "score": 10},
  {"format": 2, "score": 10},
  {"format": 3, "score": 10},
  {"format": 4, "score": 5},
  {"format": 5, "score": 15},
  {"format": 6, "score": 5},
  {"format": 7, "score": -50},
  {"format": 8, "score": -10000}
]
```

---

## 5. Execução — Migração em Massa

### 5.1 Radarr (1564 filmes)

**Método:** `PUT /api/v3/movie/editor`

**Payload:**
```json
{
  "movieIds": [1, 2, 3, ...],
  "qualityProfileId": 7
}
```

**Execução:**
- Batches de 200 IDs (limite prático do Radarr)
- 8 batches no total
- 1564 filmes migrados do profile 6 para o profile 7

**Erros encontrados:**
1. **Primeira tentativa com payload errado** — Usei o formato de PUT individual (`/api/v3/movie`) ao invés do formato de editor (`/api/v3/movie/editor`). O endpoint `/movie/editor` exige `{"movieIds": [...], "qualityProfileId": N}`, não o array completo de objetos movie.
2. **Timeout no batch 5** — O Radarr demorou mais de 120s para processar. Os batches anteriores já haviam sido aplicados. Verifiquei que 1201 de 1564 estavam migrados e completei os 363 restantes em um batch final.

### 5.2 Sonarr (344 séries)

**Método:** `PUT /api/v3/series/editor`

**Payload:**
```json
{
  "seriesIds": [1, 2, 3, ...],
  "qualityProfileId": 7
}
```

**Execução:**
- Batch único com 344 IDs
- 344 séries migradas do profile 6 para o profile 7
- Sem erros

---

## 6. Validação Final

### 6.1 Health Checks

| Serviço | Status |
|---------|--------|
| Radarr | ✅ Sem alertas |
| Sonarr | ✅ Sem alertas |

### 6.2 Profile Distribution

| Serviço | Profile 6 (antigo) | Profile 7 (Buster 1080p) |
|---------|-------------------|--------------------------|
| Radarr | 0 | 1564 (100%) |
| Sonarr | 0 | 344 (100%) |

### 6.3 Custom Formats

| Serviço | Total |
|---------|-------|
| Radarr | 8 |
| Sonarr | 8 |

---

## 7. Lições Aprendidas

### 7.1 API do Radarr/Sonarr

| Lição | Detalhe |
|-------|---------|
| **`fields` é array, não objeto** | O payload de custom format exige `"fields": [{"name": "value", "value": "..."}]`, não `"fields": {"name": "value", "value": "..."}`. |
| **`/movie/editor` vs `/movie`** | O endpoint `/movie/editor` usa `PUT` com `{"movieIds": [...], "qualityProfileId": N}`. O endpoint `/movie` usa `PUT` com o objeto movie completo. |
| **Quality IDs são diferentes do schema** | Os IDs das qualities no profile existente não batem com os IDs do `/api/v3/qualitydefinition`. Sempre usar o profile existente como template. |
| **`minFormatScore` >= 1** | O Radarr exige `minFormatScore >= 1`. Valor 0 gera erro de validação. |
| **Batches de 200** | O Radarr processa bem batches de 200 IDs. Batches maiores podem timeout. |

### 7.2 Criação de Profile

| Lição | Detalhe |
|-------|---------|
| **Usar template existente** | Criar profile do zero é propenso a erros (IDs duplicados, qualities faltando). Sempre pegar um profile existente via GET, modificar e POSTar. |
| **Remover `id` antes de POST** | O profile existente tem um `id` que deve ser removido antes de criar um novo. |

---

## 8. Troubleshooting

| Sintoma | Causa | Resolução |
|---------|-------|-----------|
| `The JSON value could not be converted` | `fields` era objeto, não array | Usar `"fields": [{"name": "value", "value": "..."}]` |
| `Sequence contains more than one matching element` | IDs duplicados no array de qualities | Usar profile existente como template |
| `Must contain all qualities` | Array de qualities incompleto | Copiar array completo do profile existente |
| `'Min Upgrade Format Score' must be >= 1` | `minFormatScore: 0` | Usar `minFormatScore: 1` |
| Timeout no bulk update | Batch muito grande | Reduzir para batches de 200 |
| Bulk update não aplica | Payload no formato errado | Usar `{"movieIds": [...], "qualityProfileId": N}` |

---

## 9. Referências

- **Documento relacionado:** `27_dumb_prod_quality_and_indexer_analysis.md`
- **Implementation Log:** `04_IMPLEMENTATION_LOG.md` — entrada de 2026-04-05 ~15:00
- **API Radarr:** `http://{{TAILSCALE_IP_PRIS}}:7880/api/v3/` (porta publicada) / `http://127.0.0.1:7878/api/v3/` (interna)
- **API Sonarr:** `http://{{TAILSCALE_IP_PRIS}}:8991/api/v3/` (porta publicada) / `http://127.0.0.1:8989/api/v3/` (interna)
- **API Key Radarr:** `b1f5b772cc5041a398005e1e05e08d5a`
- **API Key Sonarr:** `9f545b2728b64e5d9bda3eec1363d81b`

---

## 10. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-05 | Gaff (Arquiteto) | Documento inicial criado — configuração completa do profile Buster 1080p |

---

*Assinado: Gaff, Zelador de Infraestrutura.*
