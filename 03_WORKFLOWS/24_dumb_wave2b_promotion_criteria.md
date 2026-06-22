# 🚦 24_DUMB_WAVE2B_PROMOTION_CRITERIA: Critérios Formais de Promoção e Cutover

| Campo | Valor |
| :--- | :--- |
| **Código** | `24` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-03 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir os critérios formais que autorizam ou bloqueiam a promoção operacional da stack limpa `dumb-prod` para o próximo estágio da Onda 2B.

Este documento transforma a validação técnica já conquistada em um conjunto explícito de gates de governança, risco e rollback.

---

## 2. Princípio de Promoção

A promoção do `dumb-prod` não deve ocorrer porque “parece pronto”. Ela só deve ocorrer quando:

1. o comportamento mínimo exigido estiver provado
2. os critérios de GO / NO-GO estiverem explícitos
3. o rollback estiver claro
4. Marcel aprovar a janela sob HITL

---

## 3. Premissas Já Validadas

Até o momento, a Onda 2B já provou:

- stack limpa `dumb-prod` criada e operacional
- roots canônicos funcionais (`/media/movies`, `/media/shows`)
- aquisição funcional com Prowlarr + Decypharr
- filme realmente inédito processado ponta a ponta
- série realmente inédita processada ponta a ponta

Esses pontos removem a principal incerteza de viabilidade funcional da arquitetura.

---

## 4. Critérios de GO

## 4.1 GO técnico mínimo

A stack só é elegível para promoção se todos os itens abaixo forem verdadeiros:

- `dumb-prod` saudável em runtime
- Arrs internos operacionais
- `decypharr.config.json` com `arrs[]` e `debrids[]` corretos
- roots finais exclusivamente canônicos
- absence de roots legados como destino final

## 4.2 GO funcional mínimo

- filme realmente inédito processado ponta a ponta
- série realmente inédita processada ponta a ponta
- materialização final em `/media/...`
- reports reais vindos de indexers funcionais
- envio confirmado ao Decypharr

## 4.3 GO operacional mínimo

- PRIS sem sinais de saturação relevante
- rollback documental claro
- nenhuma dependência tácita do `dumb-test` para operação normal

---

## 5. Critérios de NO-GO

## 5.1 NO-GO estrutural

- reaparecimento de root folder legado
- perda de mount canônico `/media`
- `arrs[]` ou `debrids[]` inconsistentes

## 5.2 NO-GO funcional

- falha em processar item realmente novo
- ausência de report/grab para item válido sem causa clara de disponibilidade
- necessidade de improviso manual fora dos documentos aprovados

## 5.3 NO-GO operacional

- impacto perceptível na estabilidade da PRIS
- rollback incerto
- coexistência confusa entre stack nova e stack antiga

---

## 6. Critérios de Promoção por Etapa

## 6.1 Etapa 1 — Pronto para promoção controlada

Essa etapa é alcançada quando:

- todos os critérios de GO técnico e funcional estiverem atendidos
- Marcel aceitar a stack como promotível

## 6.2 Etapa 2 — Pronto para cutover parcial

Essa etapa exige adicionalmente:

- estratégia explícita de convivência entre `dumb-test`, `dumb-prod` e produção
- definição do que será mantido apenas como referência
- definição do que será desligado primeiro

## 6.3 Etapa 3 — Pronto para cutover operacional real

Essa etapa exige:

- janela aprovada por Marcel
- sequência operacional exata de promoção
- rollback testável
- comunicação documental final da mudança

---

## 7. Estratégias Possíveis de Promoção

## 7.1 Promoção conservadora

- manter `dumb-test` como referência homologada
- promover `dumb-prod` como candidato principal
- preservar a produção atual durante convivência temporária

### Recomendação

Esta é a estratégia preferida.

## 7.2 Promoção agressiva

- reduzir rapidamente a convivência
- mover o uso operacional para `dumb-prod` em janela curta

### Risco

Maior chance de erro humano e rollback apressado.

---

## 8. Rollback Obrigatório

Qualquer promoção só pode ocorrer se o rollback estiver definido assim:

1. isolar ou derrubar o `dumb-prod`
2. manter produção atual estável
3. preservar `dumb-test` como referência
4. registrar causa exata do rollback no `Implementation Log`

---

## 9. Gate Atual

### Estado atual honesto

O `dumb-prod` já atingiu o nível de:

> **Pronto para promoção controlada**

Mas ainda não significa:

> **Pronto para cutover operacional imediato**

### O que falta para a próxima transição

- decidir a estratégia de convivência/cutover
- formalizar a sequência operacional da promoção
- decidir o papel final de `dumb-test` após a promoção

---

## 10. Próximo Passo

Derivar deste documento o plano concreto de promoção/cutover, definindo:

- ordem de mudança
- papel de cada stack existente
- rollback por etapa
- critério de encerramento do `dumb-test`

---
*Assinado: Gaff, Zelador de Infraestrutura.*
