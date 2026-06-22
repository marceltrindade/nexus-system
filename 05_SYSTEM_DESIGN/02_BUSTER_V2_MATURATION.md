# 📺 Buster Friendly v2: O Curador de Realidades (Nexus Media Stack)

Este documento define a filosofia, a arquitetura e o futuro do ecossistema de mídia do Nexus, inspirado no universo de Philip K. Dick.

## 🧠 1. Filosofia e Identidade: O Nexus de Dick
O Buster Friendly não é apenas um downloader; é um curador que entende que a mídia é **memória familiar**.
*   **Nodes:** UBIK, VALIS, PRIS, DECKARD.
*   **O Valor do Histórico:** Preservação absoluta do histórico do Jellyfin.

---

## ⚙️ 2. Algoritmo de Afinidade (Scoring)

Em vez de notas genéricas (IMDb/Trakt), o sistema prioriza o "Gosto Autoral":

1.  **Lista de Elite (Peso Máximo):** Diretores (Carpenter, Peele, Spielberg, Kaufman, Bootsy Riley), Roteiristas e Compositores favoritos. Obras destes profissionais disparam download automático.
2.  **Histórico do Trakt (Peso Médio):** Gêneros recorrentes no histórico do Marcel (Horror, Sci-Fi) influenciam a pontuação.
3.  **Métricas Externas (Peso Baixo):** Notas do IMDb/Trakt servem apenas como desempate ou indicadores de "hype".

---

## 🏛️ 3. Gestão de Acervo (Keep vs. Delete)

Para equilibrar espaço e preservação, o sistema utiliza o conceito de **Digital Vault**:
*   **Mídia Temporária:** Filmes/Séries assistidos que não pertencem à Lista de Elite são sugeridos para exclusão após 48h da conclusão.
*   **Mídia de Acervo (The Vault):** Obras de diretores favoritos ou coleções sagradas são movidas automaticamente para o **Almox (Tier 3)** para preservação permanente.

---

## 🎵 4. Música, Audiobooks e Foco (Navidrome Integration)

A música deve ser um facilitador do workflow, não um distrator.
*   **Workflow-Aware:** O sistema detecta a carga cognitiva (ex: redação de logs ou código) e prioriza o **Silêncio** ou sons ambientes.
*   **Navidrome:** Solução sugerida para gerenciar os 38GB de música e audiobooks, permitindo acesso via Nexus Mesh.
*   **Vibe Matching:** Sugestão de álbuns baseada na "vibe" da mídia consumida recentemente (ex: trilhas sonoras similares).

---

## 🛡️ 5. Mandatos Técnicos (Revisão)
*   **1080p SDR Max.**
*   **1 Scraping Worker** no Decypharr.
*   **Boot Order:** Zurg -> Mount -> Stack -> Jellyfin.

---
*Atualizado em 26 de Março de 2026 por Gaff (Zelador do Nexus).*
