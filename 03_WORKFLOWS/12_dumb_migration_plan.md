# 🧭 12_DUMB_MIGRATION_PLAN: Plano Mestre de Migração da Stack de Mídia para DUMB

| Campo | Valor |
| :--- | :--- |
| **Código** | `12` |
| **Status** | Aprovado para Fase A (descoberta read-only) |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Contexto e Motivação

A stack atual de automação de mídia da PRIS entrou em colapso operacional no trecho crítico de criação de symlinks. O experimento isolado com o **DUMB (Debrid Unlimited Media Bridge)** validou com sucesso o fluxo fim a fim para um caso real (`Jaws`), incluindo:

- busca via Radarr
- descoberta por indexer
- envio ao Decypharr
- submissão ao Real-Debrid
- criação de symlink
- import final no Arr

O objetivo agora é planejar a **migração controlada da produção** para o DUMB, preservando a biblioteca já conhecida pelo Jellyfin e garantindo rollback explícito.

---

## 2. Objetivo Arquitetural

Migrar a automação de mídia da PRIS para o DUMB sem destruir o contrato atual de paths da biblioteca e sem induzir reimportação massiva no Jellyfin.

### Restrições Mandatórias

1. **Jellyfin é restrição de compatibilidade**, não detalhe de implementação.
2. **Symlink path é contrato** e deve ser preservado ou reescrito de forma transparente.
3. **Rollback deve existir antes do cutover.**
4. **Toda fase exige evidência documentada.**
5. **Produção não será alterada sem validação prévia em homologação.**

---

## 3. O Que Já Está Validado

### 3.1 Confirmado no Ambiente Isolado

- DUMB sobe corretamente em ambiente separado
- Radarr, Sonarr e Prowlarr de teste respondem
- busca funciona com indexers viáveis
- Decypharr e Real-Debrid processam o fluxo
- symlink é criado corretamente
- Radarr importa o arquivo após o symlink

### 3.2 Ainda Não Validado

- migração sem reimportação da biblioteca no Jellyfin
- comportamento com os paths reais de produção
- estratégia definitiva de `symlink repair` com `prefix rewrite`
- comportamento completo com séries em produção
- rollback operacional da stack produtiva

---

## 4. Estratégia de Migração

### 4.1 Estado Alvo

O Jellyfin deve continuar lendo os mesmos caminhos lógicos já conhecidos, enquanto o DUMB assume o pipeline de descoberta, debrid, symlink e import.

### 4.2 Princípio Operacional

Não migrar serviço por serviço sem topologia. A migração será conduzida por camadas:

1. descoberta e inventário
2. desenho de compatibilidade de paths
3. homologação expandida
4. definição de cutover
5. execução assistida
6. validação pós-migração

---

## 5. Distribuição entre a Squad Nexus

### 5.1 Consultor

**Missão:** consolidar requisitos, escopo e critérios de sucesso.

**Entregáveis:**
- spec funcional da migração
- critérios de sucesso e falha
- mapa do que não pode quebrar
- riscos percebidos pelo usuário

### 5.2 Arquiteto (Gaff)

**Missão:** desenhar a topologia futura e governar a transição.

**Entregáveis:**
- arquitetura atual vs futura
- fluxos de dados
- plano de cutover
- plano de rollback
- matriz de compatibilidade de paths

### 5.3 Engenheiro

**Missão:** executar a mudança técnica aprovada.

**Entregáveis:**
- compose/config final
- ajustes de mounts e bindings
- configuração de `symlink repair` / `prefix rewrite`
- execução controlada do cutover

### 5.4 Debugger

**Missão:** estabilizar o runtime e explicar falhas.

**Entregáveis:**
- análise de logs
- causa raiz de desvios
- validação de mount, I/O e import
- parecer técnico sobre estabilidade

### 5.5 QA

**Missão:** validar experiência real e integridade operacional.

**Entregáveis:**
- checklist funcional
- validação no Jellyfin
- validação de busca, grab, import e symlink
- parecer GO / NO-GO

---

## 6. Plano por Fases

### Fase A — Descoberta Técnica da Produção

**Status:** Aprovada

**Objetivo:** levantar a topologia real atual sem alterar estado.

**Escopo:**
- compose atual da stack de mídia
- mounts e bind paths
- roots do Radarr e Sonarr
- paths atuais lidos pelo Jellyfin
- estrutura atual de symlinks
- targets atuais
- dependências entre serviços

**Modo:** read-only

**Saída esperada:** inventário canônico do estado atual da PRIS.

### Fase B — Desenho de Compatibilidade

**Objetivo:** provar como o DUMB substituirá a topologia antiga sem quebrar o Jellyfin.

**Escopo:**
- mapear contrato de paths da biblioteca
- decidir preservação exata de paths ou reescrita transparente
- definir regra de `prefix rewrite`
- definir raiz final de symlinks
- desenhar convivência temporária entre DUMB e stack antiga

**Saída esperada:** blueprint de compatibilidade de paths.

### Fase C — Homologação Expandida

**Objetivo:** testar casos além do filme único já validado.

**Escopo mínimo:**
- 1 filme cached
- 1 filme não-cached
- 1 série
- import repetido
- rescan
- symlink repair

**Saída esperada:** matriz de testes homologada.

### Fase D — Plano de Cutover

**Objetivo:** preparar a troca real com rollback explícito.

**Escopo:**
- backup de configurações críticas
- freeze operacional
- sequência exata de cutover
- critérios de abortar
- rollback documentado

**Saída esperada:** runbook operacional de produção.

### Fase E — Execução Assistida

**Objetivo:** migrar a produção sob aprovação explícita e validação passo a passo.

**Regras:**
- execução em fases curtas
- documentação imediata
- interrupção na primeira violação de gate

### Fase F — Pós-Migração

**Objetivo:** confirmar estabilidade, integridade da biblioteca e ausência de regressão.

**Escopo:**
- monitorar downloads
- monitorar imports
- validar Jellyfin
- confirmar ausência de reimport massivo
- validar consistência dos paths

---

## 7. Matriz de Testes Obrigatórios

### 7.1 Busca e Descoberta

- [ ] Radarr retorna resultados
- [ ] Sonarr retorna resultados
- [ ] Indexers respondem de forma consistente

### 7.2 Download / Debrid

- [ ] Item cached funciona
- [ ] Item não-cached falha de forma controlada
- [ ] Logs do DUMB são legíveis e suficientes para diagnóstico

### 7.3 Symlink

- [ ] Symlink é criado
- [ ] Target resolve corretamente
- [ ] Path final é estável
- [ ] `symlink repair` funciona

### 7.4 Import

- [ ] Radarr importa corretamente
- [ ] Sonarr importa corretamente
- [ ] Metadata não quebra

### 7.5 Jellyfin

- [ ] Jellyfin enxerga o path final
- [ ] Não há necessidade de reimport total
- [ ] Biblioteca existente permanece íntegra

### 7.6 Rollback

- [ ] Configurações antigas preservadas
- [ ] Caminho de reversão documentado
- [ ] Retorno ao estado anterior é viável

---

## 8. Documentação Prioritária

Os seguintes artefatos deverão existir antes do cutover final:

1. inventário da topologia atual
2. mapa de paths e mounts
3. relatório de homologação expandida
4. runbook de cutover
5. runbook de rollback
6. atualização contínua do `04_IMPLEMENTATION_LOG.md`

### Regra de Governança

Nenhuma fase é considerada concluída sem:

- evidência
- resultado
- arquivos afetados
- status
- próximo passo

---

## 9. Riscos Principais

1. reimportação involuntária no Jellyfin
2. divergência entre path antigo e path novo
3. sincronização inconsistente do Prowlarr no DUMB
4. instabilidade de indexers específicos
5. regressão em séries apesar do sucesso com filmes
6. saturação de I/O na PRIS durante uma transição mal sequenciada

---

## 10. Critérios de Aprovação Final

A migração só será considerada pronta quando:

- [ ] Jellyfin continuar reconhecendo a biblioteca
- [ ] 1 filme e 1 série funcionarem fim a fim
- [ ] `symlink repair` estiver validado
- [ ] rollback estiver documentado e viável
- [ ] documentação canônica estiver atualizada
- [ ] Marcel aprovar o cutover

---

## 11. Próxima Ação Aprovada

**Fase A — Descoberta Técnica da Produção (somente leitura + documentação)**

### Escopo Imediato

- inspecionar compose atual
- mapear mounts
- mapear roots do Radarr e Sonarr
- mapear biblioteca lida pelo Jellyfin
- mapear paths de symlink atuais
- identificar contratos que precisam ser preservados

### Resultado Esperado

Entrega de um pacote de descoberta com:

- topologia atual
- pontos de acoplamento
- riscos concretos
- proposta preliminar de compatibilidade de paths

---
*Assinado: Gaff, Zelador de Infraestrutura.*
