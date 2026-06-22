# 🛫 25_DUMB_WAVE2B_CUTOVER_EXECUTION_PLAN: Plano Concreto de Promoção e Cutover

| Campo | Valor |
| :--- | :--- |
| **Código** | `25` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-03 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Traduzir os critérios formais de promoção da Onda 2B em uma sequência operacional concreta, definindo convivência entre stacks, ordem de mudança, rollback por etapa e destino do `dumb-test`.

---

## 2. Estratégia Escolhida

### Recomendação

**Promoção conservadora com convivência temporária.**

### Princípio

- `dumb-prod` passa a ser o candidato principal
- `dumb-test` permanece como referência homologada por um período delimitado
- produção atual só perde responsabilidade quando a nova superfície provar estabilidade operacional suficiente

---

## 3. Papéis das Stacks Durante a Promoção

## 3.1 `dumb-prod`

### Papel

Nova stack principal promotível.

### Responsabilidades

- Arrs internos operacionais
- Decypharr central
- roots canônicos
- acquisition funcional

## 3.2 `dumb-test`

### Papel

Referência homologada e fallback de laboratório.

### Regra

Não deve mais ser tratado como candidato de produção. Permanece apenas como:

- baseline de comparação
- fallback técnico de homologação
- fonte histórica de troubleshooting

## 3.3 Produção atual

### Papel

Superfície operacional estável enquanto a promoção não cruza o gate final de cutover.

---

## 4. Ordem de Promoção Recomendada

## Etapa 1 — Congelamento funcional do `dumb-prod`

### Objetivo
Parar de expandir escopo técnico e fixar o que já foi provado.

### Gate
- filme inédito validado
- série inédita validada
- roots canônicos estáveis

## Etapa 2 — Revisão de policy fina

### Objetivo
Refinar, sem reabrir a arquitetura, a parte de:

- `Buster 1080p`
- custom formats
- naming/media management

### Gate
- policy mínima considerada suficiente por Marcel

## Etapa 3 — Janela de convivência controlada

### Objetivo
Executar um período curto em que o `dumb-prod` seja a principal superfície de observação, sem desligar imediatamente os artefatos anteriores.

### Gate
- estabilidade da PRIS
- sem regressão funcional
- sem incidentes de import para item novo

## Etapa 4 — Decisão de cutover parcial

### Objetivo
Escolher quais superfícies passam a ser oficialmente tratadas como principais.

### Candidatos
- manter `dumb-prod` como nova superfície principal
- rebaixar `dumb-test` a laboratório

## Etapa 5 — Cutover operacional real

### Objetivo
Formalizar a mudança para uso operacional principal.

### Gate
- Marcel aprova a janela final
- rollback aceito

---

## 5. Rollback por Etapa

## 5.1 Rollback da convivência

Se durante a convivência o `dumb-prod` mostrar regressão:

1. isolar `dumb-prod`
2. manter produção atual
3. manter `dumb-test` intacto
4. registrar o motivo no log

## 5.2 Rollback do cutover parcial

1. retirar `dumb-prod` da função principal
2. reverter para a superfície anterior
3. preservar evidências e logs

## 5.3 Rollback do cutover real

1. reverter a superfície principal imediatamente
2. não apagar `dumb-prod`
3. congelar o estado para autópsia técnica

---

## 6. Destino do `dumb-test`

## Curto prazo

Manter como referência homologada.

## Médio prazo

Rebaixar explicitamente para:

- laboratório histórico
- ambiente de comparação
- fallback documental

## Longo prazo

Avaliar desligamento apenas quando:

- `dumb-prod` estiver maduro
- a promoção real estiver estável
- não houver mais valor comparativo no teste antigo

---

## 7. Critérios de Encerramento do `dumb-test`

O `dumb-test` só pode ser encerrado se:

- `dumb-prod` estiver estável em uso operacional
- rollback do cutover não depender mais dele
- os artefatos de referência já tiverem sido documentados

---

## 8. Gate Atual

### Estado presente

O ecossistema está em:

> **Pronto para convivência controlada e preparação de cutover parcial**

### Ainda não está em

> **Pronto para desligamento de referências antigas**

---

## 9. Próximo Passo

Derivar deste plano o checklist operacional da convivência controlada, incluindo:

- o que observar diariamente
- o que constitui incidente
- o que autoriza avançar de convivência para cutover parcial

---
*Assinado: Gaff, Zelador de Infraestrutura.*
