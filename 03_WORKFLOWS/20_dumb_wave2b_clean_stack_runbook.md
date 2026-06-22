# 🏗️ 20_DUMB_WAVE2B_CLEAN_STACK_RUNBOOK: Runbook Operacional da Stack Limpa Promovível

| Campo | Valor |
| :--- | :--- |
| **Código** | `20` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Traduzir o blueprint da Onda 2B em um runbook operacional para criação de uma **stack DUMB limpa e promovível**, apta a repetir a homologação validada no `dumb-test` sem herdar drift experimental.

Este documento existe para transformar o desenho arquitetural em sequência executável de preparação técnica.

---

## 2. Escopo Deste Runbook

Este runbook cobre apenas a **preparação da stack limpa promovível**.

Ele inclui:

- composição alvo
- mounts finais
- bootstrap esperado
- policy mínima obrigatória
- gates técnicos de subida

Ele não inclui ainda:

- promoção operacional final
- absorção massiva de library
- desativação do legado

---

## 3. Princípio Operacional

### 3.1 Regra central

A stack promovível deve nascer já alinhada com o contrato final:

- filmes em `/media/movies`
- séries em `/media/shows`

### 3.2 Regra de backend

Os caminhos abaixo continuam existindo, mas apenas como backend:

- `/mnt/debrid/decypharr`
- `/mnt/debrid/decypharr_symlinks`

### 3.3 Regra de promoção

O objetivo da stack limpa não é improvisar sobre o `dumb-test`, e sim recriar em estado controlado o comportamento que já foi homologado.

---

## 4. Composição Alvo da Stack Limpa

## 4.1 Serviço principal

Um container DUMB dedicado, com:

- Decypharr
- Radarr interno
- Sonarr interno
- Prowlarr interno (se permanecer necessário)
- backend Real-Debrid/rclone conforme onboarding do DUMB

## 4.2 Estado persistente esperado

Volumes próprios para:

- configuração persistente
- dados dos Arrs internos
- logs
- symlinks operacionais

## 4.3 Separação do experimento

A stack nova não deve reutilizar implicitamente:

- bases SQLite experimentais do `dumb-test`
- resíduos de itens de teste
- overrides não documentados

---

## 5. Mounts Finais Obrigatórios

## 5.1 Library canônica

Mount obrigatório:

- host: `/mnt/storage/media`
- container: `/media`
- modo: `rw,rslave`

### Motivo

Permitir que os Arrs internos tratem `/media/movies` e `/media/shows` como destino lógico real da biblioteca.

## 5.2 Backend DUMB

Mount obrigatório para backend de debrid com propagation compatível com submount FUSE.

### Exigência

O bind usado para `/mnt/debrid` deve permitir que o submount do backend Real-Debrid fique resolvível no namespace necessário.

## 5.3 Symlink root operacional

Manter a raiz de symlinks do DUMB acessível para fins operacionais, sem tratá-la como biblioteca final.

---

## 6. Bootstrap Esperado

## 6.1 Estado obrigatório ao fim do bootstrap

- Radarr interno acessível
- Sonarr interno acessível
- root folder único de Radarr: `/media/movies`
- root folder único de Sonarr: `/media/shows`
- nenhum root folder final em `/mnt/debrid/decypharr_symlinks/*`

## 6.2 Ajuste de bootstrap necessário

O comportamento já homologado mostrou que o patch do Decypharr precisa priorizar root folders canônicos.

### Exigência

Formalizar esse comportamento como parte do bootstrap da stack limpa.

### Não aceitável

Deixar a nova stack depender de correção manual pós-subida para remover roots legados.

---

## 7. Policy Mínima Obrigatória

## 7.1 Quality profiles

Os Arrs internos devem nascer com, no mínimo:

- `Any`
- `SD`
- `HD-720p`
- `HD-1080p`
- `Ultra-HD`
- `HD - 720p/1080p`
- `Buster 1080p`

## 7.2 Custom formats mínimos

### Radarr
- `HD Bluray Tier 01`
- `Remux Tier 01`
- `Repack/Proper`
- `2160p`
- `LQ`
- `BR-DISK`

### Sonarr
- `HD Bluray Tier 01`
- `WEB Tier 01`
- `Repack/Proper`
- `2160p`
- `LQ`
- `BR-DISK`

## 7.3 Resultado esperado

O profile `Buster 1080p` deve nascer funcional, não apenas nominal.

---

## 8. Sequência Operacional da Fase 2

## 8.1 Preparação documental

1. congelar este runbook
2. mapear quais elementos do `dumb-test` serão promovidos
3. classificar cada elemento como:
   - permanente
   - transitório
   - experimental a descartar

## 8.2 Preparação técnica

1. definir caminho da nova stack
2. definir compose limpo
3. definir volumes persistentes
4. definir forma formal do patch/override
5. validar que a library oficial existe no host

## 8.3 Subida controlada

1. subir apenas a stack limpa
2. validar health
3. validar mounts
4. validar API dos Arrs internos
5. validar roots finais

---

## 9. Gates Técnicos da Stack Limpa

## GO técnico da subida

- container saudável
- `/media/movies` visível
- `/media/shows` visível
- Radarr interno respondendo
- Sonarr interno respondendo
- `Buster 1080p` presente
- apenas roots canônicos ativos

## NO-GO técnico da subida

- root folder legado reaparece
- `/media` não existe ou está inconsistente
- Arr interno não sobe
- profile mínimo não existe
- patch depende de intervenção manual improvisada

---

## 10. Rollback da Fase 2

Se a stack limpa não atingir GO técnico:

1. parar a stack nova
2. preservar logs e compose para análise
3. manter `dumb-test` como referência homologada
4. não tocar no uso operacional atual

---

## 11. Artefatos Derivados Esperados

Este runbook deve gerar, nas próximas etapas:

1. compose alvo da stack limpa
2. estratégia formal de patch/override
3. checklist da homologação curta em ambiente limpo

---

## 12. Próximo Passo

Derivar deste runbook a lista exata de componentes a extrair do `dumb-test`, classificando:

- o que vira configuração permanente
- o que vira bootstrap formal
- o que deve ser descartado como resíduo experimental

---
*Assinado: Gaff, Zelador de Infraestrutura.*
