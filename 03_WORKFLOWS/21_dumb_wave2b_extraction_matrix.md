# 🧩 21_DUMB_WAVE2B_EXTRACTION_MATRIX: Matriz de Extração do `dumb-test` para a Stack Promovível

| Campo | Valor |
| :--- | :--- |
| **Código** | `21` |
| **Status** | Em elaboração controlada |
| **Data** | 2026-04-03 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Classificar os ativos, comportamentos e artefatos observados no `dumb-test` em três grupos:

1. **configuração permanente**
2. **bootstrap formal**
3. **resíduo experimental a descartar**

Esta matriz existe para impedir que a próxima stack promovível herde drift implícito do ambiente de homologação.

---

## 2. Regra de Classificação

## 2.1 Configuração permanente

Entra aqui tudo o que deve existir como parte estável e declarativa da nova stack.

## 2.2 Bootstrap formal

Entra aqui tudo o que precisa acontecer na criação/subida inicial, mas que não deve depender de correção manual posterior.

## 2.3 Resíduo experimental

Entra aqui tudo o que foi útil para homologação, mas não deve ser promovido como estado final.

---

## 3. Matriz de Extração

| Elemento observado no `dumb-test` | Classe | Destino recomendado | Motivo |
| :--- | :--- | :--- | :--- |
| Mount `/mnt/storage/media:/media:rw,rslave` | Configuração permanente | Compose final | É parte do contrato canônico da library |
| Bind de `/mnt/debrid` com propagation compatível ao submount FUSE | Configuração permanente | Compose final | É requisito estrutural do backend DUMB |
| Raiz operacional de symlinks do DUMB | Configuração permanente | Compose final | Necessária para backend e troubleshooting |
| Roots finais `/media/movies` e `/media/shows` | Bootstrap formal | Criação automática na subida | Devem nascer corretos, sem edição manual posterior |
| Política de bloqueio de roots legados em `/mnt/debrid/decypharr_symlinks/*` | Bootstrap formal | Patch/override formal | Impede recaída estrutural ao modelo antigo |
| `Buster 1080p` em Radarr interno | Bootstrap formal | Seed/policy inicial | Requisito mínimo de paridade funcional |
| `Buster 1080p` em Sonarr interno | Bootstrap formal | Seed/policy inicial | Requisito mínimo de paridade funcional |
| Custom formats mínimos do Radarr | Bootstrap formal | Seed/policy inicial | O profile não pode nascer apenas nominal |
| Custom formats mínimos do Sonarr | Bootstrap formal | Seed/policy inicial | O profile não pode nascer apenas nominal |
| Conectividade básica dos Arrs internos ao Decypharr | Bootstrap formal | Validação de subida | Precisa estar garantida já no bootstrap |
| `Jaws` no Radarr interno | Resíduo experimental | Descartar | Foi item de homologação, não configuração |
| `I Saw the TV Glow` no Radarr interno | Resíduo experimental | Descartar | Foi amostra de validação da nova rota |
| `Invincible (2021)` no Sonarr interno | Resíduo experimental | Descartar | Foi item legado migrado só para provar coerência |
| `Adolescence` no Sonarr interno | Resíduo experimental | Descartar | Foi amostra de homologação curta |
| Bases SQLite atuais do `dumb-test` | Resíduo experimental | Não promover diretamente | Contêm histórico e drift de teste |
| Override aplicado diretamente sobre `decypharr_settings.py` do teste | Bootstrap formal | Reescrever como mecanismo formal e rastreável | O comportamento é válido; a forma improvisada não |
| Portas publicadas do experimento (`7879`, `8990`, `9697`) | Configuração permanente condicional | Validar no compose final | Devem ser mantidas apenas se continuarem coerentes com o onboarding escolhido |
| Prowlarr interno do DUMB | Configuração permanente condicional | Reavaliar necessidade | Só permanece se houver valor real no modelo promovido |
| Indexers injetados manualmente nas bases do teste | Resíduo experimental | Não promover diretamente | Foi contingência de homologação, não baseline limpa |

---

## 4. Decisões de Promoção Derivadas

## 4.1 O que deve entrar no compose final

- mount da library oficial em `/media`
- bind correto do backend `/mnt/debrid`
- estrutura persistente de config/dados/logs/symlinks
- portas finais coerentes com o onboarding escolhido

## 4.2 O que deve virar bootstrap explícito

- criação/validação dos root folders canônicos
- imposição negativa contra roots legados como destino final
- seed de `Buster 1080p`
- seed de custom formats mínimos
- validação de API dos Arrs internos após subida

## 4.3 O que deve ser proibido de subir junto

- itens de teste já cadastrados
- bases SQLite do experimento
- injeções manuais de indexers no banco
- qualquer estado implícito que só funcione porque a homologação já mexeu no ambiente antes

---

## 5. Leitura Arquitetural

O principal ativo aproveitável do `dumb-test` não é seu estado persistido, mas sim o **conhecimento validado sobre o estado que a nova stack precisa produzir**.

Em outras palavras:

> a promoção correta não deve copiar o `dumb-test`; deve reproduzir, de forma limpa, o comportamento certo que ele demonstrou.

---

## 6. Gate de Saída desta Fase

Esta fase é considerada suficiente quando houver clareza explícita sobre:

1. o que entra no compose final
2. o que entra no bootstrap formal
3. o que deve ser deliberadamente descartado

---

## 7. Próximo Passo

Derivar desta matriz a especificação concreta da stack promovível, incluindo:

- layout de diretórios
- compose alvo
- mecanismo formal do patch/override
- checklist da nova subida limpa

---
*Assinado: Gaff, Zelador de Infraestrutura.*
