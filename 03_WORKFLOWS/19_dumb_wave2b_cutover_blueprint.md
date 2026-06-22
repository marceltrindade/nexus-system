# 🧭 19_DUMB_WAVE2B_CUTOVER_BLUEPRINT: Blueprint Formal de Promoção da Onda 2B

| Campo | Valor |
| :--- | :--- |
| **Código** | `19` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Formalizar o blueprint de promoção da **Onda 2B**, transformando a homologação validada no `dumb-test` em um desenho de cutover controlado, reversível e coerente com a topologia canônica da produção.

O objetivo não é reaproveitar o experimento diretamente, mas converter suas descobertas em um modelo limpo de promoção operacional.

---

## 2. Veredito Arquitetural de Partida

### 2.1 Linha encerrada

A abordagem original da Onda 2, baseada em:

- `Arrs produtivos -> Decypharr do DUMB`

foi encerrada como **inviável no modelo atual do DUMB**.

### 2.2 Linha validada

A linha homologada e consolidada foi:

> **Arrs internos do DUMB -> library canônica da produção (`/media/...`) + backend Decypharr/DUMB**

### 2.3 Implicação

O cutover correto não deve tentar plugar os Arrs produtivos diretamente no DUMB. Ele deve promover um ambiente DUMB cujos Arrs internos já nasçam apontando para a library canônica e operem sobre ela como superfície final.

---

## 3. Princípios Arquiteturais da Promoção

### 3.1 Contrato absoluto de biblioteca

Os caminhos finais continuam sendo:

- `/media/movies`
- `/media/shows`

Esses paths permanecem como contrato oficial para Arrs e consumidores.

### 3.2 Separação entre biblioteca e backend

Os caminhos abaixo são backend operacional, não biblioteca final:

- `/mnt/debrid/decypharr`
- `/mnt/debrid/decypharr_symlinks`

### 3.3 DUMB como engine, não como namespace final

O DUMB continua responsável por:

- adquirir via Decypharr
- materializar symlinks
- resolver backend Real-Debrid

Mas o destino lógico de biblioteca deve permanecer em `/media/...`.

### 3.4 Promoção limpa, não improvisada

O ambiente promovido deve nascer de forma limpa, com bootstrap e mounts já finais, evitando carregar drift experimental do `dumb-test`.

---

## 4. Topologia Alvo

## 4.1 Host PRIS

### Library física oficial
- `/mnt/storage/media/movies`
- `/mnt/storage/media/shows`

### Backend DUMB
- `/mnt/debrid/decypharr`
- `/mnt/debrid/decypharr_symlinks`

## 4.2 Container DUMB promovido

### Mounts canônicos obrigatórios
- `/mnt/storage/media:/media:rw,rslave`
- bind de `/mnt/debrid` com propagation compatível ao submount FUSE

### Root folders obrigatórios
- Radarr interno -> `/media/movies`
- Sonarr interno -> `/media/shows`

### Root folders proibidos como destino final
- `/mnt/debrid/decypharr_symlinks/radarr-*`
- `/mnt/debrid/decypharr_symlinks/sonarr-*`

---

## 5. Estratégia Recomendada de Promoção

## 5.1 Recomendação principal

**Recriação limpa** de uma stack DUMB promovível.

### Motivos

1. reduz drift da homologação
2. evita carregar hacks temporários como estado final implícito
3. facilita rollback
4. facilita documentação e auditoria

## 5.2 O que NÃO fazer

- não promover o `dumb-test` como produção por simples continuidade
- não reativar a linha “Arrs produtivos -> DUMB”
- não permitir roots finais em `/mnt/debrid/decypharr_symlinks/*`

---

## 6. Componentes Mínimos do Estado Promovido

## 6.1 Arrs internos

Devem nascer com:

- root folders canônicos
- `Buster 1080p`
- custom formats mínimos compatíveis
- naming e media management coerentes

## 6.2 Decypharr

Deve:

- registrar apenas os Arrs internos relevantes
- manter backend de aquisição funcional
- não reimpor roots legados como destino lógico

## 6.3 Consumidores

Devem continuar resolvendo corretamente:

- biblioteca legada
- symlinks materializados pelo DUMB
- targets reais do backend

---

## 7. Fases da Promoção

## 7.1 Fase A — Preparação da stack limpa

### Objetivo
Criar uma stack DUMB limpa, promotível e documentável.

### Entregáveis
- compose limpo
- mounts finais definidos
- patch/override formalizado
- volumes próprios e intencionais

## 7.2 Fase B — Bootstrap controlado

### Objetivo
Subir a stack e validar a topologia antes de qualquer homologação.

### Gates
- health dos serviços
- `/media/movies` e `/media/shows` visíveis
- roots canônicos ativos
- `Buster 1080p` presente

## 7.3 Fase C — Homologação curta final

### Objetivo
Repetir em ambiente limpo a validação mínima já provada no `dumb-test`.

### Gate
- 1 filme importado corretamente
- 1 série importada corretamente
- materialização final em `/media/...`

## 7.4 Fase D — Homologação ampliada

### Objetivo
Ganhar confiança operacional sem absorção massiva.

### Gate
- amostra adicional aprovada
- sem regressão de I/O
- sem reaparecimento de roots legados

## 7.5 Fase E — Decisão de promoção operacional

### Objetivo
Definir a janela e o ritmo de promoção real.

### Gate
- Marcel aprova risco e janela
- rollback está explícito e testável

---

## 8. Gates de GO / NO-GO

## GO

- stack limpa saudável
- apenas `/media/movies` e `/media/shows` como roots finais
- `Buster 1080p` funcional
- amostra de filme validada
- amostra de série validada
- consumidores resolvendo os artifacts normalmente
- PRIS sem sinais de saturação anormal

## NO-GO

- retorno de root folder legado
- import final caindo em `/mnt/debrid/...` como biblioteca
- falha de resolução nos consumidores
- regressão de I/O ou processos em estado D
- necessidade de improviso fora do blueprint aprovado

---

## 9. Rollback Estratégico

Como a recomendação é recriação limpa, o rollback preferencial é simples:

1. parar/isolar a stack promovível nova
2. manter a produção atual estável
3. manter o `dumb-test` apenas como referência homologada
4. registrar a causa exata do NO-GO

### Regra de ouro

Nenhuma superfície antiga deve ser desativada antes do GO completo da stack limpa.

---

## 10. Riscos Principais

### 10.1 Drift do patch

O comportamento já validado depende de ajuste explícito no bootstrap do Decypharr. Esse ajuste precisa ser formalizado como parte do desenho, não como remendo tácito.

### 10.2 Drift de policy

`Buster 1080p` e seus custom formats mínimos precisam nascer corretamente na stack nova, ou a nova promoção perde paridade funcional com a produção desejada.

### 10.3 Aceleração prematura

Absorção massiva ou limpeza de legado antes de homologação ampliada pode transformar um blueprint bom em incidente operacional.

---

## 11. Decisão Recomendada

O caminho recomendado para promoção da Onda 2B é:

1. **recriação limpa** da stack promovível
2. **bootstrap já alinhado** com roots canônicos
3. **homologação curta repetida** em ambiente limpo
4. **homologação ampliada controlada**
5. só então **decisão de promoção operacional**

---

## 12. Próximos Passos da Fase 1

1. congelar este blueprint como baseline arquitetural
2. derivar dele o documento operacional da stack limpa
3. mapear quais elementos do `dumb-test` viram:
   - configuração permanente
   - override temporário
   - lixo experimental a não promover

---
*Assinado: Gaff, Zelador de Infraestrutura.*
