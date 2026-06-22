# 🧱 22_DUMB_WAVE2B_PROMOTABLE_STACK_SPEC: Especificação Concreta da Stack Promovível

| Campo | Valor |
| :--- | :--- |
| **Código** | `22` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-03 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Converter o blueprint, o runbook da stack limpa e a matriz de extração em uma especificação concreta para a futura criação da stack DUMB promovível.

Este documento existe para reduzir ambiguidade antes da primeira execução técnica da stack limpa.

---

## 2. Escopo

Esta especificação cobre:

- layout de diretórios esperado
- composição alvo do ambiente promovível
- forma recomendada do patch/override
- checklist da nova subida limpa

Ela ainda não autoriza execução. Ela apenas prepara a próxima fase técnica.

---

## 3. Layout Recomendado de Diretórios

## 3.1 Raiz da stack promovível

Recomendação de diretório dedicado na PRIS:

- `/home/{{LINUX_USER}}/docker/dumb-prod/`

### Motivo

Separar claramente:

- experimento homologado: `dumb-test`
- stack promovível: `dumb-prod`

## 3.2 Estrutura mínima recomendada

```text
/home/{{LINUX_USER}}/docker/dumb-prod/
├── docker-compose.yml
├── overrides/
│   └── decypharr_settings.py
├── config/
├── data/
├── logs/
└── symlinks/
```

## 3.3 Regra de organização

O diretório `overrides/` deve conter apenas mecanismos formalmente promovidos. Nada experimental sem justificativa explícita deve entrar nessa pasta.

---

## 4. Compose Alvo

## 4.1 Serviço principal

### Recomendação

Manter um único serviço DUMB dedicado, desde que continue sendo o modo suportado pelo próprio projeto e permaneça coerente com o bootstrap homologado.

## 4.2 Mounts mandatórios

### Library oficial
- `/mnt/storage/media:/media:rw,rslave`

### Backend DUMB
- bind de `/mnt/debrid` com propagation apropriada ao submount FUSE

### Symlink root
- bind dedicado para a raiz operacional de symlinks do DUMB

## 4.3 Volumes persistentes mínimos

- config persistente
- data persistente dos Arrs internos
- logs
- symlinks

## 4.4 Portas

As portas do experimento (`7879`, `8990`, `9697`) devem ser mantidas apenas se continuarem coerentes com o onboarding final escolhido.

### Regra

Não promover portas do experimento por inércia. Validar explicitamente se elas são parte do contrato desejado da stack nova.

---

## 5. Mecanismo Formal do Patch / Override

## 5.1 Princípio

O comportamento homologado precisa ser promovido; a forma improvisada do teste não.

## 5.2 Requisitos do mecanismo

O patch/override promovível deve:

1. priorizar `/media/movies` para Radarr
2. priorizar `/media/shows` para Sonarr
3. impedir que `/mnt/debrid/decypharr_symlinks/*` reapareça como root folder final
4. ser rastreável e armazenado fora do estado volátil do container

## 5.3 Forma recomendada

### Curto prazo

Override versionado em:

- `/home/{{LINUX_USER}}/docker/dumb-prod/overrides/decypharr_settings.py`

### Médio prazo

Substituir o override por solução mais nativa, caso o projeto DUMB/Decypharr passe a suportar configuração declarativa do root lógico.

## 5.4 Regra de qualidade

O mecanismo não pode depender de edição manual pós-bootstrap para corrigir roots errados. Se depender disso, a stack promovível não está pronta.

---

## 6. Seed de Policy

## 6.1 Profiles mínimos

Devem existir na stack nova:

- `Any`
- `SD`
- `HD-720p`
- `HD-1080p`
- `Ultra-HD`
- `HD - 720p/1080p`
- `Buster 1080p`

## 6.2 Custom formats mínimos

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

## 6.3 Forma recomendada

Seed via API ou mecanismo formal de policy, jamais por promoção cega das bases SQLite do `dumb-test`.

---

## 7. Itens Explicitamente Proibidos na Promoção

- bases SQLite do `dumb-test`
- itens de amostra já adicionados no experimento
- indexers injetados manualmente diretamente em banco
- root folders legados no estado final
- qualquer correção manual que só exista fora da documentação

---

## 8. Checklist da Nova Subida Limpa

## 8.1 Pré-subida

- [ ] diretório `dumb-prod` criado
- [ ] compose alvo criado
- [ ] override formal posicionado em `overrides/`
- [ ] mounts finais revisados
- [ ] paths do host confirmados

## 8.2 Subida

- [ ] stack sobe sem erro
- [ ] health inicial aceitável
- [ ] `/media/movies` visível no container
- [ ] `/media/shows` visível no container
- [ ] backend `/mnt/debrid` resolvível

## 8.3 Pós-bootstrap

- [ ] Radarr interno responde
- [ ] Sonarr interno responde
- [ ] root único do Radarr = `/media/movies`
- [ ] root único do Sonarr = `/media/shows`
- [ ] `Buster 1080p` presente em ambos
- [ ] custom formats mínimos presentes

## 8.4 Gate técnico

- [ ] nenhum root legado reapareceu
- [ ] nenhum item experimental foi herdado
- [ ] nenhuma correção manual extraordinária foi necessária

---

## 9. Gate de Saída desta Especificação

Esta fase é suficiente quando a próxima execução técnica puder responder claramente:

1. onde a stack nova viverá
2. quais mounts ela terá
3. como o bootstrap será corrigido formalmente
4. como a policy mínima será semeada
5. como validar que ela nasceu limpa

---

## 10. Próximo Passo

Usar esta especificação para preparar a primeira execução técnica da stack limpa promovível, já com escopo exato e rollback documental explícito.

---
*Assinado: Gaff, Zelador de Infraestrutura.*
