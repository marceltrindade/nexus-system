# 🛠️ Nexus Git Standard (Procedimento)

Este documento define o padrão para criação e gestão de repositórios no ecossistema Nexus.

## 1. Localização e Visibilidade
- **Servidor:** Forgejo rodando no VALIS.
- **Visibilidade:** Repositórios sensíveis e de infraestrutura DEVEM ser **Privados**.
- **Publicidade:** Somente portfólios ADS devem ser espelhados no GitHub.

## 2. Acesso via SSH
Devido ao uso de Cloudflare Tunnel (HTTP only), o acesso Git via SSH deve ser feito pela rede **Tailscale**.
- **Endereço Remoto:** \`ssh://git@{{TAILSCALE_IP_VALIS}}:222/marcel/<repo>.git\`
- **Chave SSH:** Usar a chave pública do UBIK já cadastrada no Forgejo.

## 3. Semântica de Gestão (Scrum Nexus)
Para evitar a "dívida cognitiva", separamos problemas técnicos de objetivos de negócio usando a semântica de etiquetas (Labels) e marcos (Milestones).

### 🏷️ Categorização de Issues (O "O Quê")
- 🔴 **\`kind/bug\`**: Falhas críticas, interrupções de serviço ou erros de código.
- 🟡 **\`kind/task\`**: Manutenção, backups, limpezas ou configurações de infra.
- 🔵 **\`kind/feature\`**: Novas funcionalidades ou automações que não existiam.
- 🟢 **\`kind/enhancement\`**: Melhorias em processos ou códigos já funcionais.

### 🏛️ Estrutura de Objetivos (O "Para Onde")
- **Milestones:** Representam as Sprints ou Metas de Longo Prazo.
- **Nomenclatura Obrigatória:** Todas as Milestones e Projetos devem usar o prefixo do projeto:
    - Padrão: \`[PROJETO] Sprint XX: Descrição Objetiva\`
    - Exemplo: \`[BUSTER-FRIENDLY] Sprint 01: Estabilização de I/O\`

## 4. Ferramental (MCP & CLI)
- **Forgejo MCP:** O ecossistema possui um servidor MCP nativo (\`forgejo-nexus\`).
- **Comandos:** Use ferramentas como \`list_repositories\`, \`create_issue\` e \`list_milestones\`.
- **tea CLI:** Fallback para operações não cobertas pelo MCP. Use \`tea --login VALIS\`.

## 5. Workflow de Documentação (Wiki)
A Wiki de cada repositório é um repositório Git separado com o sufixo \`.wiki.git\`.
- **Uso:** Manuais de usuário e guias não-técnicos.

---
*Versão 1.3 - Atualizada com Regras de Nomenclatura e MCP em 27 de Março de 2026.*
