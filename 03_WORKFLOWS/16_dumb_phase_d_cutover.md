# 🚦 16_DUMB_PHASE_D_CUTOVER: Plano de Cutover e Rollback para Migração ao DUMB

| Campo | Valor |
| :--- | :--- |
| **Código** | `16` |
| **Status** | Fase D concluída |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir o plano operacional de cutover da stack de mídia da PRIS para o DUMB, com foco em:

- introdução segura de `/mnt/debrid` nos consumidores produtivos
- preservação do contrato atual de biblioteca
- rollback explícito e rápido
- minimização do risco de reimportação e deadlock de I/O

---

## 2. Princípios Operacionais

1. **Não alterar paths visíveis da biblioteca**
2. **Introduzir mounts antes de redirecionar o pipeline**
3. **Separar preparação de cutover lógico**
4. **Preferir rollback por reversão de compose/config**, não por reconstrução manual
5. **Seguir boot sequencial Buster Friendly** sempre que mounts críticos forem tocados

---

## 3. Estratégia de Cutover em Duas Ondas

## 3.1 Onda 1 — Preparação de Convivência

### Objetivo

Preparar a produção para enxergar o backend do DUMB sem ainda trocar o pipeline principal.

### Mudanças mínimas propostas

Adicionar mount de `/mnt/debrid` nos consumidores produtivos:

- `jellyfin`
- `radarr`
- `sonarr`

### Estado Esperado ao Final da Onda 1

- biblioteca atual continua intacta
- symlinks antigos continuam resolvendo via `/zurg`
- consumidores passam a conseguir resolver também symlinks novos apontando para `/mnt/debrid/...`
- nenhum redirecionamento de download ainda foi feito

### Gate da Onda 1

Antes de prosseguir para a Onda 2, deve estar demonstrado que:

- `/mnt/debrid` está visível dentro do Jellyfin
- `/mnt/debrid` está visível dentro do Radarr
- `/mnt/debrid` está visível dentro do Sonarr
- item novo do DUMB é legível sem quebrar biblioteca antiga

---

## 3.2 Onda 2 — Cutover do Pipeline

### Objetivo

Redirecionar o fluxo de novos downloads para o DUMB, mantendo a biblioteca existente intacta.

### Mudanças propostas

1. manter a biblioteca física atual
2. manter leitura dos itens legados
3. trocar download clients / integrações para que novos itens sejam abastecidos pelo DUMB
4. validar novos itens antes de qualquer convergência de symlinks antigos

### Estado Esperado ao Final da Onda 2

- novos downloads entram pelo DUMB
- itens antigos continuam servindo pelo backend legado
- biblioteca passa a conviver com symlinks mistos

---

## 4. Mudanças Técnicas Mínimas Previstas

## 4.1 Jellyfin

Adicionar mount:

- host: `/mnt/debrid`
- container: `/mnt/debrid`

### Motivo

Permitir leitura de symlinks novos apontando para o backend do DUMB sem alterar a definição das bibliotecas `/media/movies` e `/media/shows`.

## 4.2 Radarr

Adicionar mount:

- host: `/mnt/debrid`
- container: `/mnt/debrid`

### Motivo

Garantir que imports e validações de arquivo consigam resolver targets do DUMB.

## 4.3 Sonarr

Adicionar mount:

- host: `/mnt/debrid`
- container: `/mnt/debrid`

### Motivo

Garantir resolução de targets por temporada/episódio oriundos do DUMB.

---

## 5. Sequência Operacional Proposta

## 5.1 Pré-Cutover

1. congelar janela operacional
2. registrar estado atual dos composes
3. gerar backup dos arquivos de compose e configs críticas
4. confirmar saúde atual da PRIS
5. confirmar que nenhum playback está em curso no Jellyfin

## 5.2 Onda 1 — Preparação

1. alterar compose dos consumidores para incluir `/mnt/debrid`
2. recriar containers necessários de forma controlada
3. respeitar protocolo Buster Friendly se qualquer mount crítico for afetado
4. validar visibilidade de `/mnt/debrid` nos containers
5. validar legibilidade de um item novo do DUMB por Jellyfin/Radarr/Sonarr

## 5.3 Onda 2 — Cutover Lógico

1. redirecionar download clients / integrações de novos itens para o DUMB
2. manter biblioteca antiga intacta
3. validar 1 filme novo e 1 série nova no caminho produtivo
4. observar import e leitura no Jellyfin

## 5.4 Pós-Cutover Imediato

1. monitorar logs de Jellyfin, Radarr, Sonarr e DUMB
2. confirmar ausência de reimport massivo
3. confirmar que itens legados permanecem acessíveis
4. congelar qualquer convergência de symlinks até estabilidade mínima

---

## 6. Gates de Abortamento

O cutover deve ser interrompido imediatamente se qualquer uma destas condições ocorrer:

1. Jellyfin perde acesso à biblioteca existente
2. `/media/movies` ou `/media/shows` passam a ficar inconsistentes
3. `/mnt/debrid` não é resolvido dentro de qualquer consumidor crítico
4. há sinais de reimportação em massa no Jellyfin
5. há deadlock de I/O, load anormal ou processo em estado D
6. novos itens do DUMB não importam corretamente após a troca

---

## 7. Rollback Explícito

## 7.1 Rollback da Onda 1

Se a simples introdução de `/mnt/debrid` causar instabilidade:

1. restaurar compose anterior dos consumidores
2. recriar apenas os containers alterados
3. validar que a biblioteca antiga voltou ao estado original

### Resultado esperado

Retorno imediato ao estado atual, sem tocar nos symlinks antigos.

## 7.2 Rollback da Onda 2

Se o redirecionamento do pipeline para o DUMB falhar:

1. restaurar download clients/configuração antiga
2. reativar pipeline legado para novos itens
3. manter mounts adicionados somente se não causarem risco
4. isolar o DUMB novamente como homologação

### Resultado esperado

A biblioteca produtiva continua íntegra, e apenas os novos itens passam a seguir o fluxo anterior.

## 7.3 Regra de Segurança

Rollback não depende de desfazer biblioteca inteira. Ele depende de:

- restaurar compose/config
- restabelecer integrações antigas
- preservar paths visíveis da biblioteca

---

## 8. Itens que NÃO Entram no Primeiro Cutover

1. rewrite em massa de symlinks antigos
2. convergência completa de `/zurg` para `/mnt/debrid`
3. limpeza imediata do backend legado
4. refatoração do Prowlarr produtivo para o app-sync do DUMB

Esses itens só entram após estabilidade comprovada.

---

## 9. Checklist de Execução

### 9.1 Antes da Onda 1

- [ ] backups dos composes e configs críticos
- [ ] health check da PRIS
- [ ] confirmação de ausência de playback no Jellyfin
- [ ] janela de mudança aprovada

### 9.2 Antes da Onda 2

- [ ] `/mnt/debrid` visível no Jellyfin
- [ ] `/mnt/debrid` visível no Radarr
- [ ] `/mnt/debrid` visível no Sonarr
- [ ] 1 item do DUMB resolvido pelos consumidores

### 9.3 Após o Cutover

- [ ] 1 filme novo via DUMB importado
- [ ] 1 série nova via DUMB importada
- [ ] biblioteca legada continua acessível
- [ ] sem reimport massivo no Jellyfin
- [ ] sem deadlock de I/O

---

## 10. Conclusão da Fase D

O cutover mais seguro não é um “big bang”. É uma transição em duas ondas:

1. **primeiro** preparar convivência de mounts e visibilidade de backend
2. **depois** cortar o pipeline de novos downloads

Esse desenho maximiza reversibilidade, minimiza risco de reimportação no Jellyfin e respeita a fragilidade operacional da PRIS.

---
*Assinado: Gaff, Zelador de Infraestrutura.*
