# 🧩 14_DUMB_PHASE_B_COMPATIBILITY: Blueprint de Compatibilidade de Paths para Migração ao DUMB

| Campo | Valor |
| :--- | :--- |
| **Código** | `14` |
| **Status** | Fase B concluída |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Definir como o DUMB poderá substituir a stack atual de automação de mídia na PRIS sem quebrar o contrato de biblioteca já indexado pelo Jellyfin.

---

## 2. Premissas Herdadas da Fase A

### 2.1 Contrato Absoluto de Biblioteca

Os caminhos que não podem mudar são:

- `/media/movies`
- `/media/shows`

No host, isso corresponde a:

- `/mnt/storage/media/movies`
- `/mnt/storage/media/shows`

### 2.2 Comportamento Atual

A biblioteca produtiva já é composta por symlinks armazenados em `/mnt/storage/media/...`, apontando hoje para targets sob `/home/{{LINUX_USER}}/media/zurg/...`.

### 2.3 Comportamento Observado no DUMB

No ambiente de teste, o DUMB criou symlink em sua raiz de biblioteca de teste com target absoluto para:

`/mnt/debrid/decypharr/realdebrid/__all__/...`

Conclusão: o DUMB separa duas camadas:

1. **camada de biblioteca** (onde o symlink fica)
2. **camada de backend de dados** (para onde o symlink aponta)

---

## 3. Princípio Arquitetural da Compatibilidade

### 3.1 O Que Deve Permanecer Estável

Deve permanecer estável o **path visível da biblioteca**.

Ou seja, o Jellyfin deve continuar vendo:

- `/media/movies/<filme>/arquivo`
- `/media/shows/<serie>/Season NN/arquivo`

### 3.2 O Que Pode Mudar

Pode mudar o **target do symlink**, desde que:

- ele seja resolvível no namespace do Jellyfin e dos Arrs
- a biblioteca visível permaneça no mesmo lugar
- a transição não quebre itens já indexados

### 3.3 Regra de Ouro

> A migração deve substituir o backend de symlink, não a biblioteca visível.

---

## 4. Estratégia Recomendada

## 4.1 Modo Seguro (Recomendado)

### Desenho

1. **Preservar a biblioteca física atual** em:
   - `/mnt/storage/media/movies`
   - `/mnt/storage/media/shows`
2. Fazer o DUMB escrever ou reparar symlinks **nesses mesmos caminhos de biblioteca**.
3. Introduzir o backend do DUMB em um namespace consistente, exposto aos containers como:
   - `/mnt/debrid`
4. Montar esse `/mnt/debrid` também em:
   - Jellyfin
   - Radarr
   - Sonarr

### Resultado

Os symlinks existentes na biblioteca poderão apontar para dois backends durante a convivência:

- legado: `/home/{{LINUX_USER}}/media/zurg/...`
- novo: `/mnt/debrid/decypharr/...`

Desde que ambos estejam resolvíveis, o Jellyfin continuará funcionando sem reimportação.

### Vantagem

Esse modo reduz o risco porque **não exige reescrita em massa imediata** dos symlinks antigos.

---

## 4.2 Modo Convergência (Pós-estabilização)

Depois da convivência validada, executar convergência gradual da biblioteca com ferramentas de repair do DUMB.

### Objetivo

Reduzir dependência do backend legado `/zurg` e concentrar a biblioteca no backend do DUMB.

### Método

- usar `symlink repair`
- usar `prefix rewrite` apenas quando a equivalência de path estiver comprovada
- migrar por amostras e depois por lotes pequenos

### Condição de Segurança

Essa etapa **não deve acontecer no mesmo momento do cutover inicial**.

---

## 5. Modelo de Compatibilidade Proposto

### 5.1 Biblioteca Visível (imutável)

| Função | Caminho |
| :--- | :--- |
| Filmes | `/mnt/storage/media/movies` |
| Séries | `/mnt/storage/media/shows` |

### 5.2 Exposição nos Containers (imutável)

| Serviço | Caminhos que devem permanecer |
| :--- | :--- |
| Jellyfin | `/media/movies`, `/media/shows` |
| Radarr | `/media/movies/` |
| Sonarr | `/media/shows/` |

### 5.3 Backend Legado (temporário)

| Backend | Caminho |
| :--- | :--- |
| Zurg atual | `/home/{{LINUX_USER}}/media/zurg` |

### 5.4 Backend Novo (DUMB)

| Backend | Caminho lógico exposto |
| :--- | :--- |
| DUMB debrid store | `/mnt/debrid` |

### 5.5 Regra de Resolução

Durante a convivência:

- symlink antigo pode continuar apontando para `/home/{{LINUX_USER}}/media/zurg/...`
- symlink novo gerado pelo DUMB pode apontar para `/mnt/debrid/...`

Ambos são aceitáveis enquanto os dois namespaces estiverem montados de forma compatível para os consumidores.

---

## 6. Prefix Rewrite — Como Deve Ser Entendido

### 6.1 Não usar `prefix rewrite` como martelo universal

Como a biblioteca atual mistura targets em:

- `/home/{{LINUX_USER}}/media/zurg/__all__/...`
- `/home/{{LINUX_USER}}/media/zurg/movies/...`
- equivalentes de séries

não existe garantia, nesta fase, de que um rewrite textual simples seja suficiente para todos os casos.

### 6.2 Uso Correto

O `prefix rewrite` deve ser tratado como ferramenta de **convergência progressiva**, não como premissa obrigatória do primeiro cutover.

### 6.3 Regra Operacional

1. primeiro validar convivência com targets mistos
2. depois provar equivalência de amostras
3. só então aplicar rewrite por lotes controlados

---

## 7. Convivência Temporária Entre Stack Antiga e DUMB

## 7.1 Fase de Coexistência

Durante a transição, manter:

- stack antiga ainda funcional para leitura dos itens já existentes
- DUMB responsável pelos novos itens homologados

### Requisito

Os containers consumidores devem enxergar simultaneamente:

- `/media/movies`
- `/media/shows`
- `/zurg` (legado)
- `/mnt/debrid` (novo backend)

### Objetivo

Permitir que a biblioteca conviva com symlinks antigos e novos sem evento de reimportação em massa.

---

## 7.2 Corte Lógico do Pipeline

O cutover inicial não precisa mover a biblioteca inteira. Ele precisa apenas redirecionar o **pipeline de novos downloads** para o DUMB, mantendo a biblioteca já existente legível.

### Em termos práticos

- o que já existe continua servindo da forma antiga
- o que entrar novo passa a ser gerado pelo DUMB
- a convergência total da biblioteca fica para fase posterior

---

## 8. Arquitetura Alvo Proposta

```text
Jellyfin ── lê ──> /media/movies e /media/shows
                    │
                    ├── symlinks legados ──> /home/{{LINUX_USER}}/media/zurg/...
                    └── symlinks DUMB   ──> /mnt/debrid/decypharr/...

Radarr / Sonarr ── importam em ──> /media/movies e /media/shows
                                    │
                                    └── DUMB passa a abastecer novos itens

DUMB ── backend de debrid/symlink ──> /mnt/debrid
```

---

## 9. Riscos e Mitigações da Fase B

### R1 — Symlink novo aponta para namespace invisível

**Risco:** o DUMB gerar target em `/mnt/debrid/...` e Jellyfin/Radarr/Sonarr não enxergarem esse mount.

**Mitigação:** garantir mount consistente de `/mnt/debrid` em todos os consumidores antes do cutover.

### R2 — Reescrita precoce de symlinks legados

**Risco:** `prefix rewrite` em massa quebrar parte da biblioteca.

**Mitigação:** adiar convergência total; trabalhar primeiro com convivência de backends.

### R3 — Mistura de filmes e séries com regras divergentes

**Risco:** aplicar regra única de rewrite em estruturas diferentes.

**Mitigação:** validar por domínio separado: filmes e séries.

### R4 — App-sync do Prowlarr do DUMB

**Risco:** assumir sincronização automática equivalente à produção.

**Mitigação:** tratar Prowlarr do DUMB como ponto que ainda exige validação específica antes do cutover final.

---

## 10. Decisões Arquiteturais da Fase B

1. **Não mudar os caminhos visíveis da biblioteca**
2. **Aceitar targets mistos na fase inicial de convivência**
3. **Introduzir `/mnt/debrid` como novo namespace canônico do backend DUMB**
4. **Adiar rewrite em massa para fase posterior de convergência**
5. **Planejar cutover do pipeline antes da convergência completa da biblioteca**

---

## 11. Saída para a Fase C e D

### Para a Fase C — Homologação Expandida

Precisamos testar:

- 1 série via DUMB
- novo item gerado pelo DUMB convivendo com biblioteca legada
- legibilidade do item novo pelo Jellyfin com `/mnt/debrid` montado
- comportamento de rescan sem reimport massivo

### Para a Fase D — Cutover

O runbook de cutover deverá ser construído em cima desta sequência:

1. preparar mounts do backend DUMB
2. garantir visibilidade de `/mnt/debrid` nos consumidores
3. redirecionar pipeline de novos downloads para o DUMB
4. validar ingestão de novos itens
5. só depois iniciar convergência dos symlinks antigos

---

## 12. Conclusão da Fase B

O desenho de compatibilidade mais seguro não é substituir imediatamente todos os symlinks antigos, mas sim:

1. manter a biblioteca visível intacta
2. permitir coexistência entre backend legado e backend DUMB
3. cortar o pipeline de novos downloads primeiro
4. convergir os symlinks antigos apenas após estabilização

Esse desenho minimiza risco de reimportação no Jellyfin e reduz o impacto operacional do cutover.

---
*Assinado: Gaff, Zelador de Infraestrutura.*
