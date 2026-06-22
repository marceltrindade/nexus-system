# 🎓 Maturação IIVA v2 (Idioma Independente Virtual Assistant)

Este documento registra a evolução do sistema IIVA, saindo de um modelo estático de arquivos para um ecossistema inteligente e autogerido.

## 🧠 1. Visão do Produto: A "Secretária Executiva" (Sendo que IIVA soa como Eva)
O objetivo é que o assistente (GeminiCLI ou AnythingLLM) atue como uma secretária altamente competente. O Marcel foca 100% no ensino, enquanto o sistema IIVA cuida do mapeamento, registro e cruzamento de dados.

### O Ciclo da Aula (Mapa -> Viagem -> Diário)
1.  **O Plano (Mapa/Passado - Volátil):** Criado via conversa. É uma intenção que pode mudar durante a aula.
2.  **A Aula (Viagem/Presente - Real):** Encontro no Google Meet. Flexível às demandas do aluno.
3.  **O Log (Fato/Futuro - Conclusão):** Relato pós-aula com impressões subjetivas, dificuldades e conquistas. A criação do Log é o sinal de que a aula foi concluída.

---

## 🛠️ 2. Requisitos de Automação (O "Sistema Vivo")

### A. Gatilho de Atualização Automática
*   O sistema deve monitorar a criação de arquivos `.md` nas pastas dos alunos.
*   Ao detectar um novo `Log_YYYY-MM-DD.md`, a IA deve ler o conteúdo, extrair dados estruturados (JSON) e inserir no Banco de Dados.

### B. Cruzamento de Inteligência (Smart Planning)
O sistema deve ser capaz de sugerir o próximo plano de aula cruzando:
*   **Hierarquia de Conteúdos:** Nível do aluno (A1-C2).
*   **Histórico Recente:** O que foi dado nas últimas 3-5 aulas.
*   **Perfil do Aluno:** Profissão, gostos, personalidade e interesses.
*   **Métricas de Desempenho:** Dificuldades recorrentes (pronúncia, gramática) e conquistas.

### C. Gestão de Agenda Dinâmica
*   O banco deve refletir a agenda real (Google Calendar/Meet).
*   A sincronia é automatizada via MCP.
*   Status da aula: **Preparada** (Plano aprovado) e **Pronta** (Plano + Log concluído).

---

## 📋 3. Padronização de Arquivos (Templates YAML Frontmatter)

Para garantir que o sistema consiga extrair dados para o banco sem erros, todos os arquivos `.md` devem seguir um cabeçalho YAML.

### A. Template: Arquivo Pilar
```yaml
---
type: grammar | vocabulary | method | resource
suggested_level: B1
tags: [logic, business, healthcare]
complexity: 1-5
locked: true  # Se true, a IA não altera os metadados via re-análise automática
---
# [Título do Pilar]
[Conteúdo do Material Didático...]
```

### B. Template: Plano de Aula (Mapa)
```yaml
---
student: [Nome do Aluno]
planned_date: YYYY-MM-DD
target_pilar: [Ex: Grammar/Passive_Voice]
focus: [Ex: Business Writing]
status: pending  # "executed" ou "diverged" após o Log
---
# Objetivos da Aula
1. Explicar a estrutura da voz passiva.
2. Exercício prático com e-mails reais do aluno.
```

### C. Template: Log de Aula (Diário)
```yaml
---
student: [Nome do Aluno]
date: YYYY-MM-DD
lesson_number: 45
status: completed
homework_assigned: true
locked: false
---
# Relato da Aula
[Texto subjetivo do Marcel...]

# [Dificuldades]
* Item 1
* Item 2

# [Conquistas]
* Item 1
* Item 2
```

---

## ⚙️ 4. O Algoritmo de Sugestão (O Coração da IIVA)

Para sugerir o conteúdo ideal, a IIVA (Eva) utiliza um sistema de pesos (Scoring) baseado nas preferências pedagógicas do Marcel.

### Matriz de Pesos (Prioridades):
1.  **Nível Gramatical (+10 pts):** O conteúdo é essencial para o nível atual do aluno (A1-C2).
2.  **Reforço de Dificuldades (+7 pts):** O conteúdo ataca um erro recorrente registrado nos logs passados.
3.  **Interesse e Perfil (+5 pts):** O conteúdo tem tags que batem com a profissão ou gostos do aluno.
4.  **Variedade de Método (+3 pts):** Se a última aula foi Gramática, sugere Vocabulário ou Conversação para manter o equilíbrio.
5.  **Penalidade de Repetição (-20 pts):** Conteúdo já visto recentemente, a menos que seja para reforço explícito.

---

## ✅ 5. Decisões de Projeto (Resolvidas)

1.  **Interface de Aprovação:** A validação dos dados extraídos do Log será feita via **CLI (GeminiCLI)** ou **conversa natural**. O Marcel revisa a sugestão e dá o "OK" para persistência no DB.
2.  **Mapeamento de Pilares:** Sistema de decisão baseado no Mapa de Conteúdos com metadados no banco.
3.  **Soberania (Lock):** O Marcel tem a palavra final. Ativando o `locked: true` no YAML ou no DB, a IA não altera aquele registro em re-análises automáticas.
4.  **Sincronia de Agenda:** Consulta automatizada ao **Google Calendar via MCP**.
5.  **Rastreabilidade:** Plano de Aula (Mapa) permite comparar intenção vs. execução.

---
*Atualizado em 29 de Março de 2026 por IIVA.*
