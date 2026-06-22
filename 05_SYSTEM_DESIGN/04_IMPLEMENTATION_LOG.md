# 🛠️ Log de Implementação: Nexus Sync (IIVA & Inventory)

Este documento registra a jornada técnica de construção do sistema de sincronia viva do ecossistema Nexus.

## 📅 26 de Março de 2026 - Sessão 01: O Sensor de Eventos

### 🎯 Objetivo:
Implementar um "File Watcher" que detecte mudanças no diretório Johnny.Decimal (Almox) e gere sinais para o Banco de Dados.

### 🧠 Decisões de Engenharia:
1.  **Tecnologia:** Uso do <code>inotify</code> (Linux Kernel) para evitar consumo excessivo de CPU.
2.  **Linguagem:** Python 3.12+ utilizando a biblioteca <code>watchdog</code> como abstração de alto nível.
3.  **Localização:** O script residirá inicialmente em <code>~/Projects/DB-IIVA/tools/nexus-sync.py</code>.

---

## 📝 Diário de Bordo:

### 1. Preparação do Ambiente
*   [ ] Verificar instalação do <code>inotify-tools</code>.
*   [ ] Criar ambiente virtual (venv) dedicado para o Sync.
*   [ ] Instalar biblioteca <code>watchdog</code>.

### 2. Protótipo v1 (Captura de Sinais)
*   [ ] Script capaz de imprimir no terminal sempre que um arquivo <code>.md</code> for criado no Almox.
*   [ ] Testar detecção de pastas recursivas.

Teste de sensor OK!!!
---
*Log iniciado por Gaff (Technical Lead).*

### 🧪 26 de Março de 2026 - Debug e Otimização (Sessão 01.1)

#### 📝 Lições de Lab:
*   **Problema:** O script v1 tentou vigiar 1TB de arquivos recursivamente. O Python/Watchdog ficou "preso" no mapeamento inicial, causando atraso nos eventos.
*   **Solução (Otimização):** Implementado o padrão **Watchlist (Vigilância Direcionada)**.
*   **Ação:** Criado o <code>nexus_watcher_v2.py</code> que foca apenas em <code>Nexus-Docs</code> e na pasta de <code>Alunos</code> (IIVA).

#### 🛠️ Status do Teste:
1.  **inotifywait (Nativo):** Confirmou que o Kernel detecta mudanças instantaneamente.
2.  **v2 Script:** Carregado com caminhos específicos. Pronto para teste final de 10s.

---
*Log atualizado por Gaff (Technical Lead).*

### 🧪 26 de Março de 2026 - O Triunfo do Event-Driven (Sessão 01.2)

#### 📝 Lição de Ouro:
*   **Descoberta:** O sensor v2 (Events) funciona perfeitamente no Almox. O "atraso" inicial foi causado pelo **timeout de 10s** que não considerava o tempo de interação humana no menu do editor Zed.
*   **Ação:** O teste de 60s confirmou a captura instantânea de eventos <code>MODIFY</code>.
*   **Decisão Final:** Descartado o script de Polling (v3) em favor do v2 (Orientado a Eventos). O sistema está pronto para a fase de integração SQL.

---
*Log finalizado por Gaff (Technical Lead).*

## 📅 26 de Março de 2026 - Sessão 02: Java Lab 01 (Fundamentos)

### 🎯 Objetivo:
Setup do ambiente profissional Java e compreensão da tipagem estática.

### 🧠 Aprendizados de ADS:
1.  **Maven Architecture:** Entendimento do <code>pom.xml</code> como manifesto de dependências e estrutura <code>src/main/java</code>.
2.  **Naming Convention:** A regra de ouro onde o nome do arquivo (.java) deve ser idêntico ao nome da <code>public class</code>.
3.  **Tipagem Estática:** 
    *   Primitivos (<code>int</code>, <code>double</code>, <code>boolean</code>) guardam valores brutos e não aceitam <code>null</code>.
    *   Classes (<code>String</code>) são tipos de referência, possuem métodos embutidos e aceitam <code>null</code>.
4.  **HCI (Human-Computer Interaction):** Identificado que timeouts de teste de IA devem considerar a latência da interface humana (menus de editores).

---
*Log atualizado por Gaff (Java Mentor).*

## 📅 26 de Março de 2026 - Sessão 03: Consolidação e Encerramento

### 🎯 Resumo da Faxina Geral (UBIK):
*   **Recuperação de Espaço:** Removidos ~80GB de dados (Docker, Cache APT, Pontes de Migração obsoletas).
*   **Permissões do Almox:** Corrigida a propriedade de <code>/mnt/almox/JD</code> para <code>marcel:marcel</code> e ajustadas as permissões de diretórios (2775) e arquivos (664).
*   **Política de Armazenamento:** Formalizado o uso do SSD (sda2/sdc1) para sistema e projetos ativos, e HDD (Almox) para morada final JD.
*   **Triagem de Documents:** Todos os arquivos reais foram movidos para o Almox e substituídos por Symlinks na Home.

### 🏛️ Infraestrutura de Documentação:
*   **Nexus-Docs (Git):** Repositório criado no Almox e linkado em <code>~/Projects</code>.
*   **Mapeamento de Rede:** Documentados 15 serviços ativos via Cloudflare Zero Trust.
*   **Buster Friendly v2:** Documentada a nova stack (*Arrs + Decypharr) e a transição da era Riven.

### 🎓 Maturidade IIVA & Carreira:
*   **IIVA (Eva):** Definidos templates YAML Frontmatter para automação de logs e algoritmo de sugestão pedagógica.
*   **Roadmap ADS:** Estabelecida a estratégia de aprendizado empírico e preparação para vagas Java.

### ⚙️ Engenharia e Java Lab:
*   **Sensor Sync:** Validado <code>nexus_watcher_v2.py</code> como sensor de eventos eficiente para o Almox.
*   **Java Lab 01:** 
    *   Ambiente: OpenJDK 21 + IntelliJ Ultimate + DataGrip instalados.
    *   Prática: Criação de projeto Maven, entendimento de pacotes, tipos primitivos vs. classes e lógica <code>if/else</code>.

---
*Log encerrado por Gaff (System Architect & Java Mentor). Próximo passo: Integração do Watcher com SQLite/Postgres.*

## 📅 27 de Março de 2026 - Sessão 01: Soberania de Código

### 🎯 Objetivo:
Implementar infraestrutura Git privada para centralização de projetos sensíveis e automações.

### ⚙️ Implementação:
1.  **Forgejo (VALIS):** Instalado via Docker Compose em <code>~/docker/forgejo</code>.
    *   **Stack:** Forgejo v7 + SQLite3 (Otimização de RAM para 4GB).
    *   **Networking:** Configurado para <code>git.{{CLOUDFLARE_DOMAIN}}</code> via Cloudflare Tunnel.
2.  **Infrastructure Rule:** Formalizado o padrão de acesso <code>*.{{CLOUDFLARE_DOMAIN}}</code> para todos os novos serviços do ecossistema Nexus no Grafo de Memória.

### 📦 Estratégia de Migração:
*   **Destino Forgejo:** Projetos sensíveis (<code>Nexus-Docs</code>, <code>.dotfiles</code>, <code>BusterFriendlyV2</code>, <code>AgenciaPORTO</code>).
*   **Destino GitHub:** Portfólio público/privado para ADS (<code>Java-Lab</code>, <code>IIVA-Core</code>).

---
*Log atualizado por Gaff (System Architect).*

## 📅 27 de Março de 2026 - Sessão 02: Ativação da Soberania

### 🎯 Vitórias Técnicas:
*   **Primeiro Push:** Sincronizado o repositório <code>Nexus-Docs</code> com o servidor privado via SSH (Porta 222).
*   **Resolução de Conectividade:** Identificado que a porta 222 deve ser acessada via IP da Tailscale (<code>{{TAILSCALE_IP_VALIS}}</code>), contornando a limitação de portas do Cloudflare Tunnel.
*   **Wiki do Nexus:** Implementada a Wiki do repositório via Git (<code>Home</code>, <code>Glossário</code> e <code>Guia do Usuário</code>), estabelecendo o portal de manuais do ecossistema.
*   **Protocolo de Cópia:** Validado o uso do **CopyQ** para transferência íntegra de chaves SSH em terminais CLI.

---
*Log atualizado por Gaff (System Architect).*

## 📅 2026-03-27 - Manutenção e Estabilização Buster Friendly V2

### ✅ Ações Realizadas:
- **Higienização Buster Friendly:** Parada controlada do Jellyfin e Zurg para limpeza de cache do Rclone. Destravado I/O sistêmico.
- **Recuperação Bazarr:** Reiniciado container para liberar lock de banco de dados.
- **Acesso Administrativo Jellyseerr:** Promovido usuário <code>marcel</code> para Admin via SQL direto no banco.
- **Remoção de Legado:** Desmontados e removidos diretórios <code>*_legacy</code> em <code>/home/{{LINUX_USER}}/media/</code>.
- **Otimização de Bancos:** Executados <code>VACUUM</code> e <code>ANALYZE</code> nos bancos de dados do Sonarr, Radarr e Prowlarr.

---

## 📅 2026-03-28 - Sprint 01: Unificação de Escopo (Concluída)

### ✅ Ações Realizadas (Issue #1):
- **Unificação de Escopo Decypharr (PRIS):** Implementada a mudança de visibilidade para a raiz do mount (<code>/zurg</code>).
  - **JSON Fix:** Atualizado <code>"folder": "/zurg"</code> nos arquivos <code>config.json</code> de Radarr e Sonarr no nó PRIS.
  - **Docker-Compose Fix:** Alterado bind mount para <code>\${MEDIA_DEST}/zurg:/zurg:ro</code> em ambos os containers.
- **Protocolo de Segurança:** Realizados backups dos arquivos originais (<code>.bak_20260328</code>) antes da injeção via Heredoc SSH.
- **Ciclo de Vida:** Stack de download (<code>decypharr-radarr</code>, <code>decypharr-sonarr</code>) reiniciada com sucesso.

---

## 📅 2026-03-29 - Incidente de Playback e Planejamento de Futuro

### 🔍 Diagnóstico de Incidente (Playback Jellyfin):
- **Problema:** Reprodução na TV picotando por saturação de I/O no nó **PRIS**.
- **Causa:** Conflito entre Scans de Biblioteca (Radarr/Sonarr) e Leitura de Playback (Jellyfin).
- **Ação Emergencial:** Parada controlada dos containers Arrs para estabilização do filme.

### 📋 Backlog de Evolução Corrigido:

#### **Issue #4: Script Nexus Safe-Boot (Maestro)**
- **Objetivo:** Automatizar o protocolo de espera de 15 minutos pós-mount do Zurg.
- **Lógica:** Script que impede a subida do Jellyfin até que o cache VFS do Rclone esteja estável.

#### **Issue #5: Nexus Play-Mode (Automação de Estado)**
- **Objetivo:** Solução temporária (software) para mitigar conflito de I/O na PRIS.
- **Lógica:** Monitorar API do Jellyfin; ao detectar playback ativo, executar <code>docker stop</code> nos Arrs; ao detectar fim da sessão, executar <code>docker start</code>.

#### **Issue #6: Migração Trinity (Arquitetura Distribuída)**
- **Objetivo:** Solução definitiva (hardware).
- **Topologia:** 
    - **PRIS (8GB):** Jellyfin + Zurg (Leitura) + Home Assistant.
    - **DECKARD (4GB):** Arrs + Zurg (Escrita) + Decypharr.
    - **VALIS (4GB):** Infra/Gateway (Pi-hole, NPM, Forgejo).
- **Requisito:** Aquisição de Switch Gigabit para cabeamento Ethernet.

---
*Log consolidado e corrigido por Gaff. Soberania de Código preservada (2:29 AM).*

## 📅 27 de Março de 2026 - Sessão 03: Arquitetura Multi-Agente e SRE

### 🎯 Objetivo:
Profissionalizar o workflow de desenvolvimento e gestão do ecossistema Nexus através de agentes especializados e automação de interface (DX).

### ⚙️ Implementação Técnica:
1.  **Custom Forgejo MCP:** Desenvolvido servidor MCP em Python (`~/Projects/forgejo-mcp/server.py`) utilizando FastMCP.
    *   **Ferramentas:** Listagem de repositórios, issues, milestones e gestão de labels.
    *   **Integração:** Injetado nativamente no `settings.json` do Gemini CLI.
2.  **Nexus Agent Protocol (v1.2):** Skill global instalada para garantir que toda IA siga os caminhos canônicos de documentação e protocolos de segurança (Anti-Overstepping).
3.  **Squad Nexus (Multi-Agent):** Criada a infraestrutura de pastas em `~/Projects/Nexus-Agents/` para 6 personas distintas:
    *   `01_Arquiteto`: Design e Topologia.
    *   `02_Engenheiro`: Codificação e Implementação.
    *   `03_Debugger`: Troubleshoot e Causa Raiz.
    *   `04_QA`: Sanity Check e Integridade.
    *   `05_IIVA`: Gestão Pedagógica (Idioma Independente).
    *   `06_Mentor`: Roadmap ADS e Carreira.
4.  **Terminal DX (Teleporte):** Implementados aliases no `.zshrc` (`nx-arquiteto`, `nx-engenheiro`, etc.) para troca instantânea de contexto.

### 🏛️ Decisões de Governança:
*   **Nomenclatura:** Adotado o padrão `[PROJETO] Sprint XX` para todas as Milestones no Forgejo.
*   **Caminho Canônico:** Consolidada a regra de que NENHUMA documentação técnica deve morar fora do repositório `Nexus-Docs`.

---
*Log consolidado e sincronizado via Forgejo. Sessão encerrada com 100% de sucesso operacional.*

## 📅 29 de Março de 2026 - Sessão 01: Soberania e Ordem (Saneamento Git)

### 🎯 Objetivo:
Mapear, arquivar e profissionalizar os repositórios locais do UBIK para garantir a soberania de código no Forgejo (VALIS).

### ✅ Ações Realizadas:
1.  **Auditoria de Repositórios:** Identificada a falta de controle de versão em projetos críticos (`Java-Lab`, `DB-IIVA`, `wallhaven-sync`, `Nexus-Agents`).
2.  **Arquivamento e Limpeza:**
    *   **AgenciaPORTO:** Removida do UBIK e arquivada permanentemente no Almox (Volumes Docker inclusos).
    *   **homebutler:** Diretório residual vazio removido.
3.  **Renomeação Estratégica:** `wallhaven-sync` renomeado para `Nexus-Wofi-Widgets` para melhor alinhamento com a arquitetura Nexus.
4.  **Soberania de Código (Git Push):**
    *   Inicializados 4 novos repositórios Git locais.
    *   Sincronizados com o **Forgejo Privado** no VALIS via Tailscale (Porta 222).
5.  **Profissionalização (Manifestos):**
    *   Criados `README.md` detalhados (Manifestos) para os 4 projetos principais, definindo stack, objetivos e protocolos.

### 🧠 Decisões de Arquitetura:
*   **Isolamento Sensível:** Todos os projetos de infraestrutura e gestão pessoal agora residem exclusivamente no Forgejo, removendo a dependência de plataformas de terceiros para dados sensíveis.
*   **Higiene Git:** Estabelecido o compromisso de manter `README.md` vivos e informativos desde o primeiro commit.

---
*Log atualizado por Gaff (System Architect).*

## 📅 2026-03-29 - Sessão 02: Sucesso Acadêmico e Mentoria ADS

### 🎓 Avaliação I - Banco de Dados (Uniasselvi):
- **Resultado:** Concluída com **Nota 10/10**.
- **Mentoria Técnica (Gaff):** 
    - Revisão profunda de conceitos **ACID** (Atomicidade, Consistência, Isolamento, Durabilidade).
    - Diferenciação prática entre **OLTP** (transacional) e **OLAP** (analítico/BI).
    - Reforço de **Integridade Referencial** (PK/FK) aplicada ao projeto IIVA.
- **Documentação:** Criado repositório de estudos `06_ADS_CAREER` no Nexus-Docs e documentada a resolução da prova em `2026-03-29-avaliacao-i-banco-de-dados.md`.

### 🏛️ Governança Nexus-Docs:
- **Git Push:** Realizado commit e push das novas documentações para o servidor Forgejo privado (VALIS), mantendo a soberania de conhecimento do ecossistema.

---
*Log atualizado por Gaff (ADS Mentor & System Architect).*
