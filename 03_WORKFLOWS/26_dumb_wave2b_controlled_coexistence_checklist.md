# 📋 26_DUMB_WAVE2B_CONTROLLED_COEXISTENCE_CHECKLIST: Checklist Operacional da Convivência Controlada

| Campo | Valor |
| :--- | :--- |
| **Código** | `26` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-03 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir o checklist operacional da fase de convivência controlada entre `dumb-prod`, `dumb-test` e a superfície atual de produção, para permitir observação disciplinada e decisão segura sobre avanço para cutover parcial.

---

## 2. Regra da Convivência

Durante a convivência controlada:

- `dumb-prod` é a principal superfície de observação técnica
- `dumb-test` permanece como referência homologada
- a produção atual não é desligada precipitadamente

O objetivo desta fase não é acelerar. É observar com método.

---

## 3. Checklist Diário / por Sessão

## 3.1 Saúde da PRIS

- [ ] load average dentro de faixa aceitável
- [ ] memória disponível sem pressão anormal
- [ ] zero processos em estado `D`
- [ ] nenhum restart loop novo em containers críticos

## 3.2 Saúde do `dumb-prod`

- [ ] container `healthy`
- [ ] Arrs internos respondendo
- [ ] `decypharr.config.json` com `arrs[]` e `debrids[]`
- [ ] roots finais continuam em `/media/movies` e `/media/shows`
- [ ] ausência de roots legados reaparecendo

## 3.3 Saúde funcional

- [ ] filme novo continua importando corretamente
- [ ] série nova continua importando corretamente
- [ ] artifacts finais seguem indo para `/media/...`
- [ ] Decypharr continua processando sem erro estrutural

## 3.4 Integridade de aquisição

- [ ] indexers ainda visíveis nos Arrs internos
- [ ] reports continuam chegando quando há match válido
- [ ] Prowlarr não perdeu sync com Radarr/Sonarr

---

## 4. O que constitui incidente

## 4.1 Incidente crítico

Qualquer um dos itens abaixo é incidente crítico:

- item realmente novo falha sem causa clara de disponibilidade
- roots legados reaparecem
- import final sai de `/media/...`
- `dumb-prod` entra em estado instável ou flapping
- PRIS mostra regressão relevante de I/O

## 4.2 Incidente moderado

- falha de sync de Prowlarr recuperável
- telemetria confusa mas efeito final correto
- atraso temporário de acquisition sem impacto persistente

## 4.3 Não incidente

- episódio recém-exibido não disponível ainda nos indexers
- report sem match útil por indisponibilidade real de oferta

---

## 5. Gatilhos de Avanço para Cutover Parcial

O avanço para cutover parcial só é autorizado se, durante a convivência controlada:

- [ ] não houver incidente crítico
- [ ] pelo menos uma nova validação de filme seguir funcionando
- [ ] pelo menos uma nova validação de série seguir funcionando
- [ ] a PRIS permanecer estável
- [ ] Marcel julgar o comportamento suficientemente previsível

---

## 6. Gatilhos de Abortamento

Abortar a convivência controlada e retornar ao estado anterior se:

- [ ] houver regressão funcional repetível
- [ ] surgir dependência implícita do `dumb-test`
- [ ] surgir necessidade de improviso fora dos documentos aprovados
- [ ] a estabilidade da PRIS for comprometida

---

## 7. Papel do `dumb-test` nesta fase

Durante a convivência:

- [ ] manter `dumb-test` íntegro
- [ ] não promover o `dumb-test` novamente
- [ ] usar o `dumb-test` apenas como comparação e fallback técnico

---

## 8. Gate de Saída

Esta fase se encerra quando houver base suficiente para uma de duas decisões:

1. **GO para cutover parcial**
2. **NO-GO com permanência em convivência / rollback**

---

## 9. Próximo Passo

Se a convivência controlada for aceita por Marcel, derivar o checklist da janela de cutover parcial propriamente dita.

---
*Assinado: Gaff, Zelador de Infraestrutura.*
