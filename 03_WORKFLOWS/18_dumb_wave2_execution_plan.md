# 🔀 18_DUMB_WAVE2_EXECUTION_PLAN: Plano Executivo da Onda 2 do Cutover

| Campo | Valor |
| :--- | :--- |
| **Código** | `18` |
| **Status** | Encerrado — abordagem original inviável |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir a Onda 2 do cutover de forma mínima e reversível, redirecionando o pipeline de **novos downloads** para o DUMB sem substituir imediatamente os frontends produtivos Radarr e Sonarr.

---

## 1.1 Resultado Final desta Linha

Esta linha de execução foi **encerrada** após validação prática em produção controlada e homologação ampliada no `dumb-test`.

### Motivo do Encerramento

O modelo “Arrs produtivos → Decypharr do DUMB” mostrou um limite estrutural: o Decypharr não depende apenas do handshake/autenticação, mas também do **estado do Arr associado** para materializar o symlink final e concluir o import. Isso torna a abordagem inadequada enquanto os Arrs produtivos não forem tratados como `arrs` nativos do próprio DUMB.

### Direção Substituta Validada

A linha que se provou viável foi:

> **Arrs internos do DUMB → library canônica da produção (`/media/...`) + backend Decypharr/DUMB**

Essa nova direção foi homologada com sucesso e consolidada no ambiente `dumb-test`.

---

## 2. Descoberta Crítica Pré-Onda 2

### 2.1 Pipeline atual real da produção

Os Arrs produtivos não estão usando o Decypharr antigo como cliente ativo.

#### Radarr (produção)
- `Decypharr RD` → **desabilitado**
- `RDTClient` → **habilitado**

#### Sonarr (produção)
- `Decypharr RD` → **desabilitado**
- `RDTClient` → **habilitado**

### 2.2 Implicação

A Onda 2 não é uma troca de “Decypharr antigo → DUMB”.

Ela é uma troca de:

> **pipeline produtivo atual baseado em RDTClient → pipeline baseado no Decypharr do DUMB**

---

## 3. Princípio Arquitetural da Onda 2

### 3.1 O que permanece igual

- Radarr produtivo continua sendo o frontend de filmes
- Sonarr produtivo continua sendo o frontend de séries
- Prowlarr produtivo continua sendo o orquestrador de indexers
- Jellyfin continua lendo a mesma biblioteca

### 3.2 O que muda

Somente o **cliente de download efetivo** de novos itens.

Em vez de enviar novos grabs para `RDTClient`, os Arrs produtivos passarão a enviar para o **Decypharr do DUMB**.

### 3.3 Vantagem

Esse desenho minimiza impacto porque preserva:

- base de dados dos Arrs produtivos
- histórico
- listas
- quality profiles
- integrações atuais com Prowlarr

---

## 4. Topologia Recomendada da Onda 2

## 4.1 Conectividade necessária

O `dumb-test` precisará alcançar `radarr` e `sonarr` produtivos por nome de serviço, e os Arrs produtivos precisarão alcançar o Decypharr do DUMB.

### Solução recomendada

Conectar o container `dumb-test` também à rede:

- `proxy_network`

Assim:

- o DUMB passa a resolver `radarr` e `sonarr`
- os Arrs produtivos passam a resolver `dumb-test`

---

## 4.2 Modelo de autenticação do Decypharr do DUMB

Foi confirmado no banco dos Arrs do DUMB que o cliente `decypharr` usa o seguinte modelo de autenticação:

### Radarr DUMB
- host: `127.0.0.1`
- port: `8282`
- username: `http://127.0.0.1:7879`
- password: **API key do Radarr DUMB**
- category: `radarr:1080p`

### Sonarr DUMB
- host: `127.0.0.1`
- port: `8282`
- username: `http://127.0.0.1:8990`
- password: **API key do Sonarr DUMB**
- category: `sonarr:1080p`

### Interpretação

O Decypharr do DUMB usa:

- **username = URL callback do Arr**
- **password = API key do Arr**

Logo, para produção, o desenho coerente é:

#### Radarr produção → DUMB Decypharr
- host: `dumb-test`
- port: `8282`
- username: `http://radarr:7878`
- password: API key do Radarr produção
- category: `radarr:1080p`

#### Sonarr produção → DUMB Decypharr
- host: `dumb-test`
- port: `8282`
- username: `http://sonarr:8989`
- password: API key do Sonarr produção
- category: `sonarr:1080p`

---

## 5. Mudança Mínima Proposta

## 5.1 Não substituir os Arrs produtivos

Os Arrs produtivos permanecem ativos e continuam sendo a superfície oficial do pipeline.

## 5.2 Não trocar o Prowlarr produtivo nesta onda

O Prowlarr produtivo permanece como está.

## 5.3 Substituir somente o cliente efetivo de novos grabs

### Radarr
- manter `RDTClient` como fallback temporário, mas desabilitar durante o teste controlado
- adicionar `DUMB Decypharr` com categoria `radarr:1080p`

### Sonarr
- manter `RDTClient` como fallback temporário, mas desabilitar durante o teste controlado
- adicionar `DUMB Decypharr` com categoria `sonarr:1080p`

---

## 6. Sequência Operacional Recomendada da Onda 2

## 6.1 Pré-condições obrigatórias

- Onda 1 aprovada
- `dumb-test` saudável
- `/mnt/debrid` e `decypharr_symlinks` já visíveis nos consumidores
- Jellyfin resolvendo itens DUMB com sucesso

## 6.2 Passo 1 — Rede

- conectar `dumb-test` à `proxy_network`
- validar resolução de `radarr` e `sonarr` a partir do `dumb-test`
- validar resolução de `dumb-test` a partir dos Arrs produtivos

## 6.3 Passo 2 — Download clients produtivos

### Radarr
- adicionar cliente `DUMB Decypharr`
- host: `dumb-test`
- port: `8282`
- username: `http://radarr:7878`
- password: API key do Radarr produção
- category: `radarr:1080p`

### Sonarr
- adicionar cliente `DUMB Decypharr`
- host: `dumb-test`
- port: `8282`
- username: `http://sonarr:8989`
- password: API key do Sonarr produção
- category: `sonarr:1080p`

## 6.4 Passo 3 — Corte controlado

- desabilitar `RDTClient` temporariamente
- manter `Decypharr RD` legado desabilitado
- habilitar `DUMB Decypharr`

## 6.5 Passo 4 — Validação mínima

- testar 1 filme novo via Radarr produção
- testar 1 série nova via Sonarr produção
- confirmar criação de symlink do DUMB
- confirmar import no Arr produtivo
- confirmar leitura no Jellyfin

---

## 7. Gates da Onda 2

### GO

- `dumb-test` acessível pela `proxy_network`
- download clients novos autenticam com sucesso
- 1 filme novo importado
- 1 série nova importada
- Jellyfin lê ambos
- biblioteca legada continua íntegra

### NO-GO

- Arr produtivo não autentica no Decypharr do DUMB
- categoria não é processada corretamente
- novo item não gera symlink funcional
- novo item não importa
- Jellyfin não lê o item novo

---

## 8. Rollback da Onda 2

Se qualquer gate falhar:

1. desabilitar `DUMB Decypharr`
2. reabilitar `RDTClient`
3. manter Onda 1 ativa (mounts preservados)
4. isolar novamente o DUMB como homologação
5. registrar causa raiz

### Resultado esperado

O pipeline de novos itens retorna imediatamente ao estado anterior, sem perda da convivência já validada pela Onda 1.

---

## 9. Risco Mais Importante

O risco central da Onda 2 não é mais mount nem biblioteca; é **conectividade e autenticação cruzada entre Arr produtivo e Decypharr do DUMB**.

Por isso, o corte deve começar pela rede e pela autenticação antes de qualquer teste de mídia.

---

## 10. Conclusão

A Onda 2 mais segura é aquela que:

1. preserva Radarr/Sonarr/Prowlarr produtivos
2. troca apenas o cliente efetivo de novos downloads
3. mantém rollback imediato via reabilitação do `RDTClient`

Esse é o menor corte possível com máxima reversibilidade.

---

## 11. Encerramento Formal

### Veredito

**NO-GO definitivo para esta abordagem.**

### Evidência consolidada

1. rede entre `dumb-test` e Arrs produtivos validada
2. autenticação do download client validada
3. teste real com item novo chegou ao backend do DUMB
4. materialização/import final falhou por dependência do estado do Arr interno do DUMB

### Documento sucessor

O sucessor arquitetural desta linha deve formalizar o blueprint já homologado em teste:

- library final em `/media/movies` e `/media/shows`
- Arrs internos do DUMB como superfície operacional
- Decypharr/DUMB como backend de aquisição e materialização

---
*Assinado: Gaff, Zelador de Infraestrutura.*
