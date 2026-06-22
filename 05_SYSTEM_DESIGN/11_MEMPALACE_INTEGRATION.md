# 🧠 11_MEMPALACE_INTEGRATION: Sistema de Memória Compartilhada do Nexus

## Visão Geral
Este documento detalha a integração do **MemPalace** com o **ecossistema Nexus**, criando um **sistema de memória compartilhada** que permite aos agentes da Squad acessar todo o conhecimento acumulado do ecossistema de forma semântica e estruturada.

## 🎯 Objetivo
Criar um sistema de memória persistente e compartilhada que:
- Armazene todo o conhecimento do ecossistema Nexus
- Permita busca semântica por informações
- Forneça contexto histórico para decisões
- Facilite aconsistência entre agentes
- Torne o conhecimento acessível de forma estruturada

## 🏗️ Arquitetura

### Estrutura do Palácio
```
WINGS (Áreas temáticas)
├── nexus_palace      # Conhecimento técnico do ecossistema
├── iiva_knowledge    # Conhecimento pedagógico e histórico de alunos  
└── test_mempalace    # Área de testes
```

### Níveis de Organização
1. **Wings** → Áreas temáticas (projetos, domínios de conhecimento)
2. **Rooms** → Tópicos específicos dentro de cada área
3. **Drawers** → Conteúdo verbatim armazenado
4. **Closets** → Sumários compactados (em AAAK)
5. **Tunnels** → Conexões entre salas de diferentes wings

### Protocolo MCP
- **Tipo:** Local
- **Comando:** Wrapper que ativa ambiente virtual
- **Ferramentas:** 21 ferramentas do mempalace_* disponíveis
- **Comunicação:** JSON-RPC bidirecional

## 🔧 Configuração

### Servidor MCP
```json
"mempalace": {
  "type": "local",
  "command": ["/home/{{LINUX_USER}}/.config/opencode/scripts/mempalace-mcp-wrapper.sh"]
}
```

### Wrapper Script
```bash
#!/bin/bash
# Wrapper script to run mempalace MCP server with proper virtual environment
source /home/{{LINUX_USER}}/mempalace_env/bin/activate
python -m mempalace.mcp_server "$@"
```

### Ativação para Agentes
Todas as ferramentas `mempalace_*` estão ativadas para todos os agentes:
- Consultor, Arquiteto, Engenheiro, Debugger, QA, IIVA, Mentor, Escritor

## 🛠️ Ferramentas Disponíveis

### Busca e Consulta
- `mempalace_search` - Busca semântica no conhecimento
- `mempalace_status` - Visão geral do palácio
- `mempalace_wake_up` - Carrega contexto essencial (~600-900 tokens)
- `mempalace_list_wings` - Lista áreas temáticas
- `mempalace_list_rooms` - Lista tópicos dentro de uma área

### Manipulação de Conteúdo
- `mempalace_add_drawer` - Adiciona conteúdo ao palácio
- `mempalace_delete_drawer` - Remove conteúdo do palácio
- `mempalace_get_taxonomy` - Obtém a taxonomia completa

### Knowledge Graph
- `mempalace_kg_query` - Consulta relações entre entidades
- `mempalace_kg_add` - Adiciona fato ao knowledge graph
- `mempalace_kg_invalidate` - Invalida fato no knowledge graph
- `mempalace_kg_timeline` - Linha do tempo de fatos
- `mempalace_kg_stats` - Estatísticas do knowledge graph

### Diário de Agentes
- `mempalace_diary_write` - Escreve no diário do agente
- `mempalace_diary_read` - Lê o diário do agente

## 📚 Domínios de Conhecimento

### Nexus-Docs
- Protocolos da Squad
- Documentação de infraestrutura (VALIS, PRIS, UBIK)
- Logs de implementação
- Workflows e procedimentos
- Especificações técnicas
- Documentação de agentes

### IIVA (Idioma Independente)
- Material didático (gramática, métodos, vocabulário)
- Histórico de alunos (25 alunos, 1403 arquivos)
- Planos de aula e logs detalhados
- Perfis de alunos e progresso
- Administração e finanças (quando disponível)

## 🤖 Uso por Agentes

### Consultor
- Acessa histórico de decisões do ecossistema
- Verifica protocolos e padrões estabelecidos
- Consulta precedentes antes de propor novas ideias

### Arquiteto
- Consulta decisões arquiteturais anteriores
- Verifica conformidade com padrões estabelecidos
- Acessa especificações técnicas

### Engenheiro
- Acessa procedimentos de implementação
- Consulta especificações de código
- Encontra soluções para problemas técnicos

### Debugger
- Pesquisa soluções de problemas anteriores
- Acessa logs de troubleshooting
- Identifica padrões de falhas

### QA
- Consulta critérios de aceitação
- Verifica especificações de qualidade
- Acessa checklists de validação

### IIVA
- Acessa histórico de alunos
- Consulta material didático
- Referencia metodologias de ensino

### Mentor
- Consulta recursos de carreira
- Acessa material de desenvolvimento profissional
- Referencia experiências anteriores

### Escritor
- Acessa material literário
- Consulta técnicas narrativas
- Referencia obras e teorias

## 🧠 Protocolo de Memória

### Para Agentes
1. **AO INICIAR SESSÃO:** Chamar `mempalace_wake_up` para carregar contexto essencial
2. **ANTES DE DECIDIR:** Consultar `mempalace_kg_query` ou `mempalace_search` primeiro
3. **AO TERMINAR SESSÃO:** Registrar aprendizados via `mempalace_diary_write`
4. **QUANDO FATOS MUDAM:** Invalidar com `mempalace_kg_invalidate`, adicionar com `mempalace_kg_add`

### Para Confiabilidade
- Nunca adivinhar - sempre verificar no palácio primeiro
- Dizer "deixe-me conferir" e consultar o conhecimento
- Armazenar aprendizados para futuras sessões
- Manter o knowledge graph atualizado

## 📊 Métricas de Sucesso

### Quantitativos
- **825 drawers** no palácio (total)
- **340 drawers** do IIVA
- **21 ferramentas** disponíveis
- **3 wings** principais
- **1462 arquivos** do IIVA integrados
- **25 alunos** com histórico completo

### Qualitativos
- Alta precisão nas buscas semânticas
- Respostas rápidas (< 2 segundos típicos)
- Conteúdo bem estruturado e acessível
- Facilidade de uso para agentes

## 🔧 Troubleshooting

### Problemas Comuns
1. **Servidor MCP não conectado**
   - Causa: Ambiente virtual não ativado
   - Solução: Verificar wrapper script e PATH

2. **Ferramentas não disponíveis**
   - Causa: Configuração MCP incorreta
   - Solução: Verificar opencode.json

3. **Buscas sem resultados**
   - Causa: Pouco conteúdo no palácio
   - Solução: Importar mais documentos

### Comandos de Diagnóstico
```bash
# Verificar status dos servidores MCP
opencode mcp list

# Testar servidor diretamente
source ~/mempalace_env/bin/activate && python -m mempalace.mcp_server

# Verificar conteúdo do palácio
mempalace status
```

## 🚀 Próximos Passos

### Imediatos
1. Monitoramento contínuo de uso das ferramentas
2. Expansão para outros domínios do ecossistema
3. Otimização de buscas baseada no uso real
4. Criação de dashboards de métricas

### Curto Prazo
1. Agentes consultando automaticamente o palácio
2. Sistema de feedback sobre qualidade dos resultados
3. Importação automática de novos documentos
4. Melhoria na relevância das buscas

### Médio Prazo
1. Aprendizado contínuo baseado no uso
2. Expansão para conhecimento externo
3. Integração com outras fontes de informação
4. Sistema de raciocínio baseado em precedentes

## 📚 Referências
- `Nexus-Docs/03_WORKFLOWS/05_nexus_squad_protocol.md`
- `~/.config/opencode/opencode.json`
- `~/.config/opencode/mempalace_instructions.md`
- `~/scripts/import_iiva_knowledge.sh`

---
*Assinado: Gaff, Arquiteto de Sistemas do ecossistema Nexus*
*Data: 07/04/2026*
*Documento: 11_MEMPALACE_INTEGRATION.md*