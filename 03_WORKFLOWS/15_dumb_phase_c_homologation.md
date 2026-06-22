# 🧪 15_DUMB_PHASE_C_HOMOLOGATION: Homologação Expandida do DUMB

| Campo | Valor |
| :--- | :--- |
| **Código** | `15` |
| **Status** | Fase C concluída com gate parcial |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Executar homologação expandida do DUMB além do caso inicial com filme, validando:

- série via DUMB
- convivência entre biblioteca legada e backend novo
- risco de leitura pelo Jellyfin
- comportamento do fluxo em casos parcialmente bloqueados pelo Real-Debrid

---

## 2. Testes Executados

### 2.1 Validação de Mounts nos Consumidores Atuais

Inspeção dos mounts atuais confirmou:

- `jellyfin` monta `/zurg`, `/media/movies` e `/media/shows`
- `radarr` monta `/media`, `/downloads`, `/zurg` e `/mnt/storage/media`
- `sonarr` monta `/media`, `/downloads`, `/zurg` e `/mnt/storage/media`
- `dumb-test` monta `/mnt/debrid`

### 2.2 Resultado Crítico

Os consumidores produtivos **não montam `/mnt/debrid`** atualmente.

Logo, um symlink produtivo que aponte diretamente para `/mnt/debrid/...` ainda **não é legível** por Jellyfin/Radarr/Sonarr na configuração atual da produção.

---

## 3. Teste de Série no DUMB

### 3.1 Série Selecionada

`Invincible (2021)`

### 3.2 Preparação

- série adicionada no Sonarr de teste
- root folder do Sonarr de teste:
  `/mnt/debrid/decypharr_symlinks/sonarr-1080p`
- indexer ativo no Sonarr de teste:
  `MediaFusion (Prowlarr)`
- download client de teste:
  `decypharr`

### 3.3 Resultado do Fluxo

O Sonarr de teste executou busca para múltiplas temporadas e encontrou releases válidas.

O comportamento observado foi misto:

- algumas releases falharam com erro do Real-Debrid:
  - `infringing_file`
  - código `35`
- outras releases foram aceitas e processadas com sucesso

### 3.4 Evidência de Sucesso

Logs confirmaram:

- busca por temporada no Sonarr
- consulta ao `MediaFusion`
- envio ao Decypharr
- submissão de torrents válidos ao Real-Debrid
- criação de symlinks para episódios

---

## 4. Artefatos Produzidos no DUMB

### 4.1 Estrutura Interna Confirmada

No namespace interno do `dumb-test`, foi confirmada a criação de:

- `/mnt/debrid/decypharr_symlinks/sonarr-1080p/Invincible (2021)/Season 1/...`

### 4.2 Targets Internos Confirmados

Os symlinks de episódios apontam para o backend DUMB em:

- `/mnt/debrid/decypharr/realdebrid/__all__/Invincible - Season - 01 [2021] 1080p AMZN WebRip x265 DDP 5.1 Kira [SEV]/...`

### 4.3 Significado Arquitetural

O DUMB está produzindo corretamente a hierarquia de série por temporada e episódio, o que valida o comportamento esperado para TV.

---

## 5. Convivência com Biblioteca Legada

## 5.1 O Que Foi Validado

- o DUMB funciona para série em ambiente isolado
- a estrutura de symlink para episódios é compatível com o modelo de biblioteca por temporada

## 5.2 O Que Ainda Não Está Pronto em Produção

A convivência com a biblioteca produtiva **ainda não pode ser ativada** porque o namespace `/mnt/debrid` não está montado em:

- Jellyfin
- Radarr de produção
- Sonarr de produção

### Conclusão

O bloqueio atual da convivência não é mais de pipeline, mas de **exposição de mount**.

---

## 6. Gates da Fase C

### 6.1 Aprovados

- [x] Série via DUMB executa busca
- [x] Série via DUMB chega ao Decypharr
- [x] Série via DUMB cria symlinks internos por temporada
- [x] DUMB lida com fallback quando algumas releases falham no RD

### 6.2 Não Aprovados Ainda

- [ ] Jellyfin de produção consegue ler item novo gerado pelo DUMB
- [ ] convivência produção + `/mnt/debrid` está pronta
- [ ] rescan sem risco de reimport massivo foi demonstrado na produção

---

## 7. Riscos Reavaliados

### R1 — Exposição de namespace

O risco principal agora é a ausência de `/mnt/debrid` nos consumidores produtivos.

### R2 — Releases bloqueadas pelo RD

Séries podem encontrar releases proibidas (`infringing_file`), exigindo que o pipeline continue testando múltiplas alternativas.

### R3 — Falso positivo de homologação

O fato de a série funcionar dentro do DUMB não implica que o Jellyfin produtivo consiga lê-la sem ajuste de mounts.

---

## 8. Conclusão da Fase C

### 8.1 Conclusão Principal

O DUMB está homologado para série em ambiente isolado no que diz respeito a:

- busca
- fallback entre releases
- debrid
- criação de symlink por temporada/episódio

### 8.2 Gate que Barra Produção

O cutover ainda não pode ser proposto porque a produção atual **não enxerga `/mnt/debrid`**.

### 8.3 Interpretação Arquitetural

O problema deixou de ser “o DUMB funciona?” e passou a ser “como expor o backend DUMB aos consumidores sem quebrar a biblioteca atual?”.

---

## 9. Próximo Passo

Entrar na **Fase D — Plano de Cutover**, com foco em:

1. desenho de mounts necessários nos consumidores produtivos
2. ordem segura de alteração
3. rollback explícito
4. validação de convivência antes do corte final

---
*Assinado: Gaff, Zelador de Infraestrutura.*
