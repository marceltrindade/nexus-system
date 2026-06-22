# ✅ 17_DUMB_PHASE_E_EXECUTION_CHECKLIST: Checklist Operacional Executivo do Cutover DUMB

| Campo | Valor |
| :--- | :--- |
| **Código** | `17` |
| **Status** | Pronto para aprovação de execução |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Este documento converte o plano de cutover em um **checklist operacional executável**, com gates, critérios de abortamento e rollback.

Ele existe para garantir que a migração para o DUMB seja executada com disciplina de mudança, mínima ambiguidade e máxima reversibilidade.

---

## 2. O Que Este Checklist Conforma

Este checklist conforma cinco dimensões críticas da migração:

### 2.1 Conformidade Arquitetural

Garante que a execução respeite o desenho aprovado:

- `/media/movies` e `/media/shows` permanecem como contrato absoluto
- `/mnt/debrid` entra como backend novo, não como nova biblioteca
- o cutover acontece em duas ondas

### 2.2 Conformidade Operacional

Garante ordem correta de execução:

- preparação antes de corte lógico
- validação antes de avanço
- rollback possível em qualquer gate

### 2.3 Conformidade de Segurança

Garante que a mudança não viole as restrições do ambiente:

- sem alteração destrutiva sem checkpoint
- sem reescrita em massa no primeiro corte
- sem ignorar o protocolo Buster Friendly

### 2.4 Conformidade de Serviço

Garante que os consumidores críticos continuem funcionais:

- Jellyfin continua lendo a biblioteca
- Radarr continua importando filmes
- Sonarr continua importando séries

### 2.5 Conformidade de Evidência

Garante auditabilidade:

- toda etapa tem evidência observável
- cada gate tem critério objetivo
- cada desvio gera decisão explícita: seguir, abortar ou reverter

---

## 3. Papéis na Execução

### Arquiteto
- conduz a ordem da mudança
- valida gates
- decide avanço ou abortamento técnico

### Engenheiro
- aplica compose/config aprovados
- executa mounts, recreates e integrações

### Debugger
- observa logs e sintomas de I/O, import e mount
- determina causa raiz em caso de falha

### QA
- valida Jellyfin, filme novo, série nova, biblioteca legada
- emite parecer GO / NO-GO

---

## 4. Checklist Executivo

## 4.1 Pré-Janela

- [ ] Janela de mudança aprovada por Marcel
- [ ] Nenhum playback ativo no Jellyfin
- [ ] Saúde atual da PRIS verificada
- [ ] Estado atual dos containers documentado
- [ ] Compose atual salvo em backup
- [ ] Configs críticas salvas em backup
- [ ] `04_IMPLEMENTATION_LOG.md` preparado para registro imediato

### Evidências mínimas
- status dos containers
- cópia dos composes
- confirmação de ausência de playback

### Gate
Se qualquer item acima falhar, **não iniciar Onda 1**.

---

## 4.2 Onda 1 — Preparação de Convivência

### Mudança
- [ ] Adicionar `/mnt/debrid:/mnt/debrid` em `jellyfin`
- [ ] Adicionar `/mnt/debrid:/mnt/debrid` em `radarr`
- [ ] Adicionar `/mnt/debrid:/mnt/debrid` em `sonarr`

### Aplicação controlada
- [ ] Recriar apenas containers afetados
- [ ] Respeitar a sequência segura da PRIS se houver impacto de mount
- [ ] Observar estabilidade após recriação

### Validação funcional
- [ ] `/mnt/debrid` visível dentro do Jellyfin
- [ ] `/mnt/debrid` visível dentro do Radarr
- [ ] `/mnt/debrid` visível dentro do Sonarr
- [ ] Biblioteca legada continua acessível
- [ ] Nenhum sinal de reimportação em massa

### Gate da Onda 1
Avançar para a Onda 2 somente se:

- [ ] biblioteca antiga intacta
- [ ] backend DUMB visível nos três consumidores
- [ ] sem load anormal ou sintomas de I/O crítico

### Abortamento
Se houver perda de biblioteca, mount invisível, reimportação em massa ou instabilidade severa, **executar rollback da Onda 1**.

---

## 4.3 Rollback da Onda 1

- [ ] Restaurar compose anterior de Jellyfin, Radarr e Sonarr
- [ ] Recriar apenas os containers alterados
- [ ] Confirmar retorno da biblioteca ao estado anterior
- [ ] Registrar causa do abortamento

### Critério de sucesso
- [ ] `/media/movies` funcional
- [ ] `/media/shows` funcional
- [ ] consumidores sem dependência de `/mnt/debrid`

---

## 4.4 Onda 2 — Cutover do Pipeline

### Pré-condição obrigatória
- [ ] Onda 1 aprovada integralmente

### Mudança
- [ ] Redirecionar fluxo de novos downloads para o DUMB
- [ ] Preservar biblioteca legada sem rewrite em massa
- [ ] Manter backend legado disponível durante convivência

### Validação mínima obrigatória
- [ ] 1 filme novo via DUMB importado
- [ ] 1 série nova via DUMB importada
- [ ] itens legados continuam legíveis
- [ ] Jellyfin enxerga item novo
- [ ] Jellyfin continua enxergando item antigo

### Gate da Onda 2
Considerar cutover inicial aprovado somente se:

- [ ] novos itens entram via DUMB
- [ ] biblioteca antiga não degrada
- [ ] sem reimportação massiva
- [ ] sem deadlock de I/O

---

## 4.5 Rollback da Onda 2

- [ ] Restaurar download clients/config antiga
- [ ] Reativar pipeline legado para novos itens
- [ ] Manter `/mnt/debrid` apenas se não gerar risco
- [ ] Isolar novamente o DUMB como homologação
- [ ] Registrar o ponto exato de falha

### Critério de sucesso
- [ ] novos itens voltam ao pipeline anterior
- [ ] biblioteca existente permanece íntegra
- [ ] ambiente retorna a estado operacional conhecido

---

## 4.6 Pós-Cutover Imediato

- [ ] Monitorar logs de Jellyfin
- [ ] Monitorar logs de Radarr
- [ ] Monitorar logs de Sonarr
- [ ] Monitorar logs do DUMB
- [ ] Confirmar ausência de reimportação em massa
- [ ] Confirmar ausência de processos em estado D
- [ ] Confirmar acessibilidade de item antigo + item novo

### Regra
Nenhuma convergência de symlinks antigos é autorizada nesta fase.

---

## 5. Critérios de GO / NO-GO

## GO

- biblioteca visível intacta
- `/mnt/debrid` resolvível nos consumidores
- filme novo validado
- série nova validada
- Jellyfin sem regressão
- load/I/O estáveis

## NO-GO

- mount invisível em qualquer consumidor
- biblioteca antiga quebrada
- reimportação em massa
- import falhando de forma recorrente
- sintomas de deadlock de I/O

---

## 6. Itens Explicitamente Fora do Escopo Desta Execução

- rewrite em massa da biblioteca antiga
- limpeza do backend legado `/zurg`
- convergência total da base antiga para o backend DUMB
- refatoração profunda do Prowlarr produtivo

---

## 7. Resultado Esperado Deste Checklist

Ao final, ele deve produzir um de três estados claros:

1. **GO** — convivência pronta e pipeline novo operando
2. **GO parcial** — Onda 1 aprovada, Onda 2 adiada
3. **NO-GO** — rollback executado e ambiente restaurado

Isso evita zona cinzenta operacional.

---
*Assinado: Gaff, Zelador de Infraestrutura.*
