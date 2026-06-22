# ▶️ 23_DUMB_WAVE2B_FIRST_EXECUTION_PLAN: Plano Operacional da Primeira Execução Técnica

| Campo | Valor |
| :--- | :--- |
| **Código** | `23` |
| **Status** | Executado com sucesso estrutural e validação funcional inédita confirmada |
| **Data** | 2026-04-03 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir a primeira execução técnica da stack limpa `dumb-prod` de forma minimamente arriscada, decompondo a operação em etapas pequenas, reversíveis e compatíveis com HITL.

Este documento não executa nada por si só. Ele existe para preparar a futura operação write com máxima clareza.

---

## 2. Princípio da Primeira Execução

### 2.1 O que esta execução precisa provar

1. a stack `dumb-prod` consegue subir limpa
2. `/media/movies` e `/media/shows` estão visíveis e corretos
3. o bootstrap já nasce sem roots legados
4. `Buster 1080p` e policy mínima podem ser reproduzidos formalmente

### 2.2 O que esta execução NÃO precisa provar ainda

- promoção operacional final
- absorção massiva de library
- substituição de qualquer superfície produtiva atual

---

## 3. Dependências de Aprovação HITL

Todas as etapas abaixo são **write** e exigem aprovação explícita de Marcel antes de execução:

1. criação do diretório `/home/{{LINUX_USER}}/docker/dumb-prod/`
2. criação de `docker-compose.yml`
3. criação do diretório `overrides/`
4. gravação do override formal `decypharr_settings.py`
5. criação de volumes/pastas auxiliares (`config/`, `data/`, `logs/`, `symlinks/`)
6. subida inicial da stack

---

## 4. Ordem Exata da Primeira Execução

## 4.1 Etapa A — Preparação da árvore `dumb-prod`

### Ação
Criar a estrutura mínima:

```text
/home/{{LINUX_USER}}/docker/dumb-prod/
├── docker-compose.yml
├── overrides/
├── config/
├── data/
├── logs/
└── symlinks/
```

### Objetivo
Separar o ambiente promovível do `dumb-test` já na raiz física.

### Validação
- diretório existe
- estrutura mínima existe

### Rollback
- remover a árvore `dumb-prod` se nenhuma etapa posterior depender dela

---

## 4.2 Etapa B — Compose inicial

### Ação
Criar `docker-compose.yml` inicial com:

- serviço DUMB único
- mounts finais obrigatórios
- volumes persistentes mínimos
- portas definidas explicitamente

### Objetivo
Materializar a topologia mínima promovível no compose.

### Validação
- `docker compose config` sem erro
- mounts esperados visíveis no output expandido

### Rollback
- restaurar backup do compose ou remover o arquivo

---

## 4.3 Etapa C — Override formal

### Ação
Criar override versionado em:

- `/home/{{LINUX_USER}}/docker/dumb-prod/overrides/decypharr_settings.py`

### Requisitos mínimos
O override deve:

1. priorizar `/media/movies` para Radarr
2. priorizar `/media/shows` para Sonarr
3. impedir recriação de roots finais em `/mnt/debrid/decypharr_symlinks/*`

### Objetivo
Garantir que o bootstrap já nasça correto.

### Validação
- arquivo existe
- sintaxe válida
- bind do override presente no compose

### Rollback
- restaurar versão anterior do override ou remover bind correspondente

---

## 4.4 Etapa D — Subida limpa inicial

### Ação
Subir apenas a stack `dumb-prod`.

### Objetivo
Verificar se a stack limpa atinge estado básico de saúde.

### Validação
- container sobe
- health inicial aceitável
- APIs internas respondem

### Rollback
- `docker compose down` da stack nova

---

## 4.5 Etapa E — Validação pós-bootstrap

### Ação
Checar:

- `/media/movies`
- `/media/shows`
- root folders finais
- profiles mínimos
- custom formats mínimos

### Objetivo
Fechar o gate técnico da primeira subida.

### Validação obrigatória
- Radarr interno responde
- Sonarr interno responde
- root único do Radarr = `/media/movies`
- root único do Sonarr = `/media/shows`
- `Buster 1080p` presente
- nenhum root legado reapareceu

### Rollback
- isolar a stack nova e preservar apenas evidências/logs

---

## 5. Separação de Writes por Turno

## Turno 1 — Estrutura

- criar diretório `dumb-prod`
- criar subdiretórios mínimos

## Turno 2 — Compose

- escrever `docker-compose.yml`
- validar `docker compose config`

## Turno 3 — Override

- escrever `overrides/decypharr_settings.py`
- validar sintaxe

## Turno 4 — Subida

- `docker compose up -d`
- validar health

## Turno 5 — Validação técnica

- checar mounts
- checar APIs
- checar roots
- checar profiles

---

## 6. Gates de Avanço

## Gate 1 — Árvore pronta

Avança apenas se:

- diretórios corretos existem
- nenhum arquivo foi criado fora do caminho esperado

## Gate 2 — Compose válido

Avança apenas se:

- `docker compose config` não falha
- mounts finais batem com a spec

## Gate 3 — Override válido

Avança apenas se:

- override tem sintaxe válida
- o compose realmente o injeta no container

## Gate 4 — Stack sobe

Avança apenas se:

- serviços internos respondem
- não há falha estrutural imediata

## Gate 5 — Bootstrap correto

Considera a primeira execução bem-sucedida apenas se:

- os roots finais já nascem corretos
- `Buster 1080p` está presente
- nenhum root legado reaparece

---

## 7. Critérios de Abortamento

Abortar a primeira execução se:

1. a stack nova exigir improviso não documentado
2. o override não impedir o retorno de roots legados
3. `/media` não ficar visível corretamente
4. houver sinais de instabilidade relevante na PRIS

---

## 8. Resultado Esperado da Primeira Execução

Ao fim desta primeira execução técnica, o resultado mínimo esperado é:

- stack `dumb-prod` existente
- subida limpa validada
- roots canônicos únicos
- policy mínima presente
- pronto para futura homologação curta

---

## 8.1 Resultado Real Alcançado até Agora

### Executado com sucesso

- Turno 1 — estrutura `dumb-prod`
- Turno 2 — compose inicial validado por `docker compose config`
- Turno 3 — override formal versionado e com sintaxe válida
- Turno 4 — primeira subida limpa com container `healthy`
- bootstrap mínimo funcional com:
  - `decypharr`
  - `radarr`
  - `sonarr`
- roots canônicos consolidados:
  - `/media/movies`
  - `/media/shows`
- `arrs[]` do Decypharr preenchido automaticamente
- Profilarr provisionado e integrado ao circuito da stack
- validação prática de materialização em `/media/...` com artefatos que provavelmente já existiam no ecossistema anterior (`dumb-test` / backend debrid)

### Ainda em aberto

- identificação da superfície correta de add que realmente persiste itens no Radarr interno do `dumb-prod`
- validação mais limpa da policy fina aplicada pelo Profilarr
- decisão de promoção operacional/cutover
- eventual commit/push desta rodada documental

### Leitura arquitetural

A primeira execução técnica já passou do estágio de prova estrutural, mas sua validação funcional precisa ser reclassificada com mais rigor. O `dumb-prod` demonstrou reproduzir, em stack limpa, a rota da Onda 2B no nível de infraestrutura, bootstrap e materialização canônica. Contudo, ainda não foi demonstrado de forma inequívoca que ele consegue baixar e processar, ponta a ponta, um item realmente novo e ausente do ecossistema anterior.

### Reclassificação honesta das amostras

#### Primeira amostra

- `I Saw the TV Glow (2024)`
- `Adolescence (2025)`

Essa amostra permanece útil como validação de integração e materialização em `/media/...`, porém não deve mais ser tratada como prova final de repetibilidade. Há forte possibilidade de que os artifacts já existissem no backend previamente alimentado pelo `dumb-test`.

#### Segunda amostra

- `The Assessment (2025)`
- `Your Friends & Neighbors (2025)`

Essa amostra deve ser tratada como **inconclusiva**. Até o momento da validação, não houve prova suficiente de materialização final nem evidência observável robusta de processamento completo.

#### Prova controlada de ineditismo real

- `My Dinner with Andre (1981)`

Essa prova foi útil porque eliminou ambiguidades sobre artifacts pré-existentes. Após correção da superfície correta de add, o item passou a ser persistido no banco real do Radarr interno, gerou busca dirigida, report válido, envio ao Decypharr e materialização final em `/media/movies/...`.

#### Prova inédita de série

- `Falling Skies` / `S01E01`

Essa prova confirmou o mesmo padrão no eixo de séries. O `dumb-prod` conseguiu:

- adicionar a série ao Sonarr interno
- monitorar apenas o episódio alvo
- disparar `EpisodeSearch`
- buscar via Prowlarr
- enviar report ao Decypharr
- processar e materializar os artifacts correspondentes

### Veredito funcional final desta fase

Agora existe prova suficiente de que o `dumb-prod` cumpre sua função para itens realmente inéditos, tanto em filme quanto em série.

---

## 9. Próximo Passo

Consolidar documentalmente a rodada do `dumb-prod` e decidir o próximo gate entre:

1. preparar uma prova realmente inédita com critério mais rígido, ou
2. validar finamente a policy (`Buster 1080p` e custom formats), ou
3. preparar os critérios de promoção/cutover com a ressalva explícita de que a repetibilidade inédita ainda não foi provada.

Com a repetibilidade inédita agora comprovada, o próximo gate prioritário deixa de ser “provar função básica” e passa a ser “definir critérios e estratégia de promoção/cutover”.

---
*Assinado: Gaff, Zelador de Infraestrutura.*
