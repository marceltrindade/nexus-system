# 04_IMPLEMENTATION_LOG.md

## 📅 2026-06-15 — Briefing Diário IIVA (n8n Workflow)

### ✅ Ações Realizadas:

1. **Workflow "Briefing Diario IIVA" criado do zero** (`7ajpmk2XtFly4AL4`)
   - Schedule Trigger (21:15) → Google Calendar → IIVA API /alunos → IIVA API /aulas → Code JS → Data Table → Telegram
   - Google Calendar node nativo (não HTTP Request) com OAuth2 credential
   - Calendar ID descoberto: `marcelrtrindade.ii@gmail.com` (não aceita "primary")
   - 30 MCP tools do n8n configuradas e funcionando

2. **Data Table `briefing_iiva` criada** (`MODamyCn5kmXZOwq`)
   - 14 colunas: data, aluno_nome, aluno_id, horario, nivel, status_aluno, frequencia, ultima_aula_numero, ultima_aula_data, tem_aula_calendario, tem_aula_banco, precisa_criar, status, briefing_json
   - Lição: colunas `date` não aceitam string vazia — usar `null`

3. **Ciclo operacional definido**: n8n (21:15) → Joi consulta → Marcel aprova → Joi cria .md

4. **Workflow antigo arquivado** (`o7t7Fnt2Hi7gAUVf`)

5. **Planos de aula de hoje criados** (15/06):
   - Rodrigo — Aula #28 (08:00, B1, 60min): "Aviation Stories"
   - Guilherme — Aula #18 (19:00, Beginner, 45min): "Workplace Scenarios"
   - SyncThing sincronizou, watcher no VALIS registrou no banco

### 📂 Arquivos Alterados/Criados:
- `/mnt/almox/JD/00-09 System/05 Architecture/Nexus-Docs/03_WORKFLOWS/30_briefing_iiva_workflow.md`
- `/mnt/almox/JD/20-29 Work/IIVA-classes/21.01 Alunos/Rodrigo/2026-06-15_Aula_28_Rodrigo.md`
- `/mnt/almox/JD/20-29 Work/IIVA-classes/21.01 Alunos/Guilherme/2026-06-15_Aula_18_Guilherme.md`

### 🔧 Técnico:
- **Descoberta:** `await $("NodeName").all()` funciona no Code node v2 (task runner)
- **Bloqueio:** `fetch()` NÃO está disponível no sandbox do Code node v2
- **Bloqueio:** Google token CLI expirou (30/05), refresh `invalid_grant`. Precisa reautorização.
- **MCP tools registradas pelo gateway mas não injetadas no LLM toolset** — bug conhecido, resolvido com `/new` após restart do gateway

---

## 📅 2026-05-25 — Open WebUI Desktop Funcional + Joi/hledger Setup

### ✅ Ações Realizadas:
1. **Alias joy → joi** no `.zshrc` (linha 536) — acesso via `joi` → `ssh -t marcel@{{TAILSCALE_IP_PRIS}} hermes`
2. **hledger: 8 entries financeiras** da Estefani (salário, aluguel, luz x2, presente Vini, Boticário, VA/VR) + transação periódica `~ monthly from 2026/06/16` para luz (R$ 312.34)
3. **hledger skill atualizada** (`~/.config/opencode/skills/hledger/SKILL.md`) — forecast, periodic transactions, `; estimado`, holding account `Ativos:APagar`
4. **Open WebUI Desktop** — removido .deb (crash GPU), instalado Flatpak 0.0.8, configurado `http://joi.{{CLOUDFLARE_DOMAIN}}`, testado com `--ozone-platform=x11 --no-sandbox` no Wayland — **funcional**
5. **Prompt Joi treinado** para parsing de gastos da Estefani (estrutura de contas, formato hledger, Telegram → journal)

### 📂 Arquivos Alterados:
- `/home/{{LINUX_USER}}/.zshrc` — alias joi
- `/home/{{LINUX_USER}}/hledger/main.journal` — entries Estefani + luz periódica
- `/home/{{LINUX_USER}}/.config/opencode/skills/hledger/SKILL.md` — forecast/APagar docs
- `/home/{{LINUX_USER}}/.var/app/com.openwebui.open-webui/config/open-webui/config.json` — URL remota
- `/home/{{LINUX_USER}}/Documents/Nexus-Docs/04_IMPLEMENTATION_LOG.md`

### 📋 Próximo Passo:
Monitorar Open WebUI Desktop (estável por ora). Aguardar instruções sobre Joi e hledger.

---

## 📅 2026-04-26 — Buster Friendly ROY: Correção de Erro (Bancos Corrompidos)

### ❌ Problema:
1. **Cópia indevida de docker-compose.yml** - Copiei um novo compose para o ROY sem ler a documentação que indicava para NÃO mexer nos bancos
2. **Containers re-inicializados** - O compose fez os containers reescreverem os bancos, revertendo a correção de paths da Fase 2
3. **Paths retornaram** para `/media/movies` e `/media/shows` (em vez de `/mnt/media/...`)

### ✅ Correção Aplicada:
1. **Parar containers** - `docker stop radarr sonarr`
2. **Restaurar ownership** - `sudo chown -R marcel:marcel` nos diretórios de config
3. **Restaurar bancos do backup** - Copiar de `~/docker/buster-friendly/config/backups/`
4. **Corrigir paths via SQLite:**
   - `UPDATE Movies SET path = REPLACE(path, '/media/movies', '/mnt/media/movies');` (1744 registros)
   - `UPDATE Series SET path = REPLACE(path, '/media/shows', '/mnt/media/tv');` (384 registros)
   - `UPDATE RootFolders SET path = '/mnt/media/movies' WHERE path = '/media/movies';`
   - `UPDATE RootFolders SET path = '/mnt/media/tv' WHERE path = '/media/shows';`
5. **Verificar integridade** - `PRAGMA integrity_check;` = ok em ambos
6. **Restaurar permissões para container** - `sudo chown -R 911:911`
7. **Reiniciar containers** - `docker start radarr sonarr`

### 📊 Resultado:
- Radarr: 1744 movies com path `/mnt/media/movies/...` ✅
- Sonarr: 384 series com path `/mnt/media/tv/...` ✅
- Containers rodando nas portas 7878 e 8989 ✅
- Banco de dados corrigido e estável ✅

---

## 📅 2026-04-26 — Buster Friendly ROY: Fase 4 - Decypharr

### ✅ Ações Realizadas:

1. **Instalação Decypharr** - Binário baixado e executando em `/home/{{LINUX_USER}}/decypharr`
2. **Configuração minimal** - Arquivo `config.json` com modo WebDAV (`"mount": { "type": "none" }`)
3. **Integração Radarr** - Configurado como download client (host: localhost, port: 8282, category: radarr:Default)
4. **Integração Sonarr** - Configurado como download client (host: localhost, port: 8282, category: sonarr:Default)
5. **API verificada** - Versão v4.3.2 respondendo corretamente
6. **Testes de endpoint** - `/api/v2/torrents/info` retorna [] (sem torrents na fila)

---

### 📂 Estrutura:

```
~/decypharr (binário)
~/docker/buster-friendly/config/decypharr/config.json (config)
```

### 🔍 Endpoints Disponíveis:
- `GET /api/v2/app/version` → v4.3.2
- `GET /api/v2/torrents/info` → lista de torrents
- `POST /api/v2/torrents/add` → adicionar torrent via magnet/arquivo
- `GET /api/v2/downloadclient` → lista de download clients configurados

---

### 🎯 Próxima Fase (Fase 5):

- Integrar Jellyseerr ou Bazarr
- Configurar opções adicionais do Decypharr (auth, filtros, etc)
- Documentar fluxo de uso completo

---

## 📅 2026-04-26 — Buster Friendly ROY: Fase 5 - Bazarr

### ✅ Ações Realizadas:
1. **Configuração otimizada** - Arquivo `config.yaml` com carga reduzida:
   - `concurrent_jobs: 1` (apenas 1 job simultâneo)
   - `adaptive_searching_delay: 1w` (busca adaptativa semanal)
   - `wanted_search_frequency: 24` (busca a cada 24h)
   - `movies_sync: 720` (sync movies a cada 12h)
   - `series_sync: 720` (sync series a cada 12h)
2. **Rede isolada** - Docker network `buster-friendly` criada
3. **Container rodando** - Porta 6767 exposta, recursos limitados (CPU 0.5, RAM 512M)
4. **Config paths corrigidos** - `/mnt/media/movies/` e `/mnt/media/tv/`
5. **Providers ativos** - opensubtitlescom, supersubtitles, yifysubtitles, legendasnet

### 📊 Resultado:
- Bazarr rodando no ROY ({{LAN_IP_ROY}}:6767)
- Carga de sistema reduzida (workers limitados, busca moderada)
- Integração com Radarr (7878) e Sonarr (8989) configurada
- Configuração pronta para legendas automáticas

---

## 📅 2026-04-26 — Buster Friendly ROY: Fase 5 - Jellyseerr Integrado

### ✅ Integração Concluída:
- **Jellyseerr na PRIS** conectado aos serviços ARR no ROY
- **Configuração cross-node** estabelecida com sucesso
- **Endpoints configurados**:
  - Radarr: `http://{{LAN_IP_ROY}}:7878` (API: `b1f5b772cc5041a398005e1e05e08d5a`)
  - Sonarr: `http://{{LAN_IP_ROY}}:8989` (API: `9f545b2728b64e5d9bda3eec1363d81b`)
  - Prowlarr: `http://{{LAN_IP_ROY}}:9696` (API: `8ed1dd73a2554d5bb09a21a0053e3526`)

### 📊 Resultado:
- Fluxo de solicitações operacional: Jellyseerr (PRIS) → ARR Stack (ROY) → Real Debrid
- Conectividade cross-node validada entre PRIS e ROY
- APIs respondendo corretamente com autenticação

---

## 📅 2026-04-26 — Buster Friendly ROY: Fase 1 - RCLONE + ZURG

### ✅ Ações Realizadas (Original):
1. SSH configurado - Autenticação por chave UBIK → ROY ({{LAN_IP_ROY}})
2. Rclone forkado transferido - Da PRIS para ROY
3. Zurg instalado - v0.9.3-final (binário direta PRIS → ROY)
4. Token RD configurado - XWIDIDXQQN2E5GVE5DA3REGJIYCY53RL6H5ZKH6YP7G2WLGVJA4Q
5. Mount /mnt/zurg ativo - via rclone webdav → Zurg localhost:9999/dav
6. API respondendo - http://localhost:9999

---
## 📅 2026-04-26 — Buster Friendly ROY: Fase 6 - NFS ROY→PRIS PARA JELLYFIN

### ✅ Ações Realizadas:
1. **Portas estáticas configuradas** no ROY (/etc/nfs.conf):
   - mountd: 32767
   - statd: 32765 (outgoing: 32766)
   - lockd: 32768
2. **Firewall UFW** liberado para PRIS ({{LAN_IP_PRIS}}): portas 2049, 32765-32768
3. **Export NFS** configurado: `/mnt/media 192.168.15.0/24(rw,sync,no_subtree_check,no_root_squash)`
4. **Mount na PRIS** concluído:
   - Ponto: `/mnt/roy-media`
   - Opções: `vers=3,mountport=32767,port=2049,nolock`
   - Persistência: entrada adicionada ao `/etc/fstab`
5. **Validação**: `ls /mnt/roy-media` mostra downloads, movies, tv ✅

### 📊 Resultado:
- NFS mount operacional entre ROY e PRIS ✅
- Jellyfin na PRIS pode acessar mídia do ROY via `/mnt/roy-media` ✅
- Configuração persistente via fstab ✅

---

## 📅 2026-05-20 — Second Brain: Fase 1 de Plugins Obsidian

### ✅ Ações Realizadas:

1. **Instalação de 3 plugins** (download manual do GitHub):
   - **Templater** — motor de templates com JavaScript e prompts interativos
   - **Calendar** — calendário sidebar para navegar daily notes
   - **Dataview** — queries SQL-like nas notas do vault
2. **Ativação** — `community-plugins.json` atualizado com os 4 plugins (incluindo `consistent-attachments-and-links` já existente)
3. **Configuração** — `data.json` criado para cada plugin com settings otimizadas:
   - Templater: `trigger_templates: true`, `templates_folder: 50_Resources/Templates`
   - Calendar: `noteFolder: 10_Daily`, `noteFileFormat: YYYY-MM-DD`, `showWeekNumber: true`
   - Dataview: `enableInlineDataview: true`, `enableDataviewJs: false`, `warnOnEmptyResult: true`
4. **Migração de templates** — todos os templates migrados para sintaxe Templater:
   - `{{date}}` → `<% tp.date.now("YYYY-MM-DD") %>`
   - `{{title}}` → `<% tp.file.title %>`
   - `{{disciplina}}` → `<% tp.system.prompt("Disciplina?") %>` (Nota de Aula)
   - `{{aula}}` → `<% tp.system.prompt("Número da aula?") %>` (Nota de Aula)
   - `{{name}}` → `<% tp.file.title %>` (Pessoa)
5. **Novo template** — `Índice.md` criado para uso com Folder Note plugin
6. **Queries Dataview** — 10 queries prontas salvas em `50_Resources/Dataview Queries.md`

### 📂 Estrutura:

```
.obsidian/plugins/
├── templater-obsidian/
├── obsidian-calendar-plugin/
└── obsidian-dataview/

50_Resources/Templates/
├── Daily Note.md          ← migrado para Templater
├── Captura Rápida.md      ← migrado para Templater
├── Ficha de Leitura.md    ← migrado + prompts interativos
├── Nota de Projeto.md     ← migrado para Templater
├── Nota de Aula.md        ← migrado + prompts (disciplina, aula, professor, tópico)
├── Pessoa.md              ← migrado + prompts interativos
├── Conceito.md            ← mantido compatível
└── Índice.md              ← novo template

50_Resources/Dataview Queries.md  ← 10 queries prontas
```

### ⚠️ Notas:
- Templates agora usam prompts interativos quando abertos via Obsidian UI
- Script `sb` continua funcionando (usa placeholders simples, não Templater)
- Para usar prompts interativos, criar nota via Obsidian (Ctrl+N) e aplicar template
- Dataview requer reload do Obsidian para ativar

---

## 📅 2026-05-20 — Second Brain: Fase 3 de Plugins Obsidian

### ✅ Ações Realizadas:

1. **Instalação de 2 plugins**:
   - **Quick PARA** (v1.0.0) — auto-tagging baseado na pasta PARA, histórico de movimentação
   - **Auto Note Mover** (v1.2.0) — move notas automaticamente baseado em regras de tags
2. **Ativação** — `community-plugins.json` atualizado com 8 plugins no total
3. **Configuração Quick PARA**:
   - Pastas: `00_Inbox`, `30_Projects`, `40_Areas`, `50_Resources`, `90_Archive`
   - `tagOnCreate: true`, `tagOnMove: true`, `extractSubfolderTags: true`
   - `trackParaHistory: true`, `addAllTag: false`
   - `autoCancelTasksOnArchive: false` (segurança)
4. **Configuração Auto Note Mover** — 4 regras configuradas com **trigger manual** (segurança):
   - `daily` → `10_Daily`
   - `reading` → `50_Resources/Reading`
   - `project` → `30_Projects`
   - `aula` → `20_Academic/Disciplinas`
   - `confirmBeforeMove: true` (pede confirmação antes de mover)

---

## 📅 2026-05-20 — Second Brain: Fase 2 de Plugins Obsidian

### ✅ Ações Realizadas:

1. **Instalação de 2 plugins**:
   - **Omnisearch** (v1.29.2) — busca full-text com OCR em imagens e PDFs
   - **Various Complements** (v11.3.0) — autocomplete de wikilinks e tags
2. **Ativação** — `community-plugins.json` atualizado com 6 plugins no total
3. **Configuração Omnisearch**:
   - `ignoreDiacritics: true` (busca "filosofia" acha "filosofía")
   - `weighting`: title(3), heading(2), tags(2), path(1), content(1)
   - `excludedFolders`: `.obsidian`, `90_Archive`
   - `PDFIndexing: true`, `imageIndexing: native`
   - Atalho: `Ctrl+Shift+O`
4. **Configuração Various Complements**:
   - `complementType: both` (arquivo atual + vault inteiro)
   - `triggerCompletionOn`: wikilink(`[[`), tag(`#`)
   - `insertKey: Tab`, `maxSuggestions: 10`
   - `sortOrder: recent`, `useRecentFiles: true`

---

## 📅 2026-05-20 — Second Brain: Fase 4 de Plugins Obsidian

### ✅ Ações Realizadas:

1. **Instalação de 3 plugins**:
   - **Kanban** (v2.0.51) — boards visuais para gerenciar projetos e estudos
   - **Linter** (v1.31.2) — formata markdown automaticamente ao salvar
   - **Folder Note** (v0.7.3) — notas índice automáticas por pasta
2. **Ativação** — `community-plugins.json` atualizado com 11 plugins no total
3. **Configuração Kanban**:
   - `date-format: YYYY-MM-DD`, `archive-completed-cards: true`
   - `new-note-folder: 30_Projects`
4. **Configuração Linter**:
   - `lintOnSave: true` (formata ao salvar)
   - YAML sort alphabetical, compact YAML, trailing spaces trim
   - `foldersToIgnore: .obsidian, 90_Archive`
   - List style: dash, indent: 2 spaces
5. **Configuração Folder Note**:
   - `noteName: _{folder_name}`, `noteLocation: inside`
   - `openFolderNoteOnFolderClick: true`
   - `templatePath: 50_Resources/Templates/Índice.md`
   - `autoCreateFolderNote: false` (manual)
   - Exclui `.obsidian` e `50_Resources/Templates`

---

## 📅 2026-05-20 — Second Brain: Fase 5 de Plugins Obsidian

### ✅ Ações Realizadas:

1. **Instalação de 2 plugins**:
   - **Excalidraw** (v2.23.3) — desenho/diagramas à mão livre no Obsidian
   - **PARA Visualizer** (master branch) — dashboard com gráficos da distribuição PARA do vault
2. **Ativação** — `community-plugins.json` atualizado com 13 plugins no total
3. **Configuração Excalidraw**:
   - `folder: 50_Resources/Excalidraw` (desenhos organizados)
   - `autosave: true`, `autosaveInterval: 15000` (15s)
   - `theme: system`, `zoomToFitOnOpen: true`
   - `showTransclusion: true` (embeds de notas nos desenhos)
4. **Configuração PARA Visualizer**:
   - `timeRange: 90` dias
   - `showPARAInsights: true`, `showHeatmap: true`, `showGraph: true`
   - `showTagCloud: true`, `showStats: true`, `showPARAHistory: true`
   - `clickToOpen: true`, `theme: auto`
   - Requer Quick PARA instalado (usa frontmatter `para`)

---

## 📅 2026-05-20 — Second Brain: Testes Finais e Correção

### ✅ Testes Realizados:

1. **community-plugins.json** — 13 plugins listados ✅
2. **Plugin files** — 13/13 com main.js + manifest.json ✅
3. **Templates** — 8/8 com sintaxe Templater ✅
4. **Plugin configs** — 12/12 data.json válidos ✅
5. **sb script** — 7 comandos funcionando ✅
6. **sb integration** — 5 notas criadas corretamente ✅
7. **Vault structure** — 19 pastas organizadas ✅
8. **Interest indexes** — 6/6 categorias criadas ✅
9. **Dataview queries** — 11 queries prontas ✅

### 🔧 Correção Aplicada:

- **Problema:** Templates migrados para Templater (`<% %>`) não funcionavam com `sb` script
- **Solução:** Criados templates "raw" em `50_Resources/Templates/raw/` com placeholders simples (`{{date}}`, `{{title}}`)
- **Script `sb`** atualizado para usar `TEMPLATES/raw/` como fonte
- **Templates originais** em `50_Resources/Templates/` mantidos com sintaxe Templater para uso via Obsidian UI

### 🔧 Unificação (Opção C):

- **Problema:** Duas pastas de templates (`Templates/` + `Templates/raw/`) = duplicação desnecessária
- **Solução:** Templates unificados com `{{ }}` (para `sb`) + `<% %>` (para Templater/UI)
- `sb` substitui `{{ }}` e ignora `<% %>` → nota pronta
- Ao abrir no Obsidian, `<% %>` executa prompts interativos
- **Uma pasta só**, dois fluxos, zero duplicação

---

## 📅 2026-05-20 — ⚠️ Mudança de Rota: Buster Friendly → LibreELEC/Kodi + Torbox

### 🧭 Contexto da Decisão

Devido à situação recente do Real Debrid, a arquitetura de mídia do Nexus será reorientada:

- **Real Debrid → Torbox** (novo provedor de debrid)
- **ROY (Ubuntu Server + Docker + arr stack) → LibreELEC/Kodi** (media center direto)
- **PRIS** mantida, papel futuro a definir (automation hub? cloud?)
- **TV**: 1080p é o teto de qualidade (sem TV 4K)

### 📊 Status da GPU do ROY (Radeon R7 M260)

- **ROY** (Dell Inspiron 14, {{LAN_IP_ROY}}) está **offline** no momento — ping sem resposta
- GPU: Radeon R7 M260 (GCN, 4GB VRAM, 2014)
- Compatibilidade LibreELEC:
  - Usa driver open-source **`amdgpu`** no kernel moderno — suportado ✅
  - **1080p: perfeitamente capaz** ✅ (teto da TV)
  - 4K: suporta saída HDMI, mas **sem decodificação HEVC 10-bit por hardware** (GPU pré-HEVC) — não se aplica
- LibreELEC com SSH via **dropbear** — 100% configurável via terminal

### 🧪 Teste Prévio

- **LG webOS (homebrew + Kodi + Umbrella + Torbox)**: testado, mas pesado demais para rodar direto na TV
- **Conclusão**: LibreELEC no ROY resolve — hardware dedicado e otimizado

### 🗺️ Plano de Migração

| Fase | Ação | Prioridade |
|------|------|------------|
| **Fase 1** | Criar conta Torbox | Imediata |
| **Fase 2** | Configurar Kodi + POV/Torbox no UBIK (teste) | Antes de instalar no ROY |
| **Fase 3** | Backup dos dados do ROY (configs arr, se necessário) | Antes do wipe |
| **Fase 4** | Instalar LibreELEC no ROY (USB/Disk) | Após validação |
| **Fase 5** | Configurar ROY: IP fixo ({{LAN_IP_ROY}}), SSH, Kodi | Pós-instalação |
| **Fase 6** | Decidir novo papel da PRIS | Em paralelo |

### 🏛️ Stack de Addons no Kodi (ROY)

| Componente | Addon/Tool | Observação |
|------------|-----------|------------|
| **Debrid** | **POV** (principal) | Leve, menos dependências, guia oficial Torbox |
| **Fallback** | **Umbrella** | Secundário se POV não achar sources |
| **Legendas** | **OpenSubtitles (VIP)** | Automático pt-BR, sem limite diário |
| **YouTube** | **YouTube addon oficial** | Navegação completa no Kodi |
| **SponsorBlock** | **plugin.video.sponsorblock** | Pula patrocínios automático |
| **Biblioteca** | **Trakt** | Sincroniza histórico entre dispositivos |
| **Prime Video** | Addon via IA + DRM | Temporário (~6 meses, depois remover) |
| **Skin** | Arctic Zephyr / Aeon Nox | UI bonita, navegação por capas |
| **IPTV** | IPTV Simple Client | Se provedor de internet oferecer |

### 💡 Verificação Rápida do Stremio

Stremio não roda no LibreELEC — é plataforma separada (Android TV, Fire Stick). A stack correta é Kodi + addons (POV/Umbrella).

### 🏛️ O Que Muda na Arquitetura

```
ANTES:
  Real Debrid → Zurg → Rclone → arr stack (ROY) → Jellyfin (PRIS)

DEPOIS:
  Torbox → Kodi + POV + OpenSubtitles + YouTube/SB → LibreELEC/Kodi (ROY)
```

- **arr stack (Radarr, Sonarr, Prowlarr, Bazarr, Decypharr, Zurg)** → descontinuado no ROY
- **Jellyfin na PRIS** → perde o papel de media center principal
- **Complexidade reduzida**: de 6+ containers para 1 OS/appliance (Kodi)
- **OpenSubtitles VIP** mantido e configurado como fonte automática de legendas

### 📝 Notas Técnicas

- LibreELEC: dropbear SSH, IP fixo `{{LAN_IP_ROY}}`, integração HDMI-CEC
- POV + Torbox: guia oficial em `support.torbox.app` → Kodi + POV
- GPU R7 M260: 1080p sem gargalo
- ROY hoje está offline — verificar conectividade antes do wipe
- Backup das configs do arr stack recomendado antes de instalar LibreELEC

---
*Plano documentado pelo Engenheiro Nexus Squad em 20/05/2026.*

---

## 📅 2026-05-20 — Second Brain: Revisões Periódicas (Weekly/Monthly)

### ✅ Ações Realizadas:

1. **Template Weekly Review** criado em `50_Resources/Templates/Weekly Review.md`:
   - Queries Dataview: daily notes da semana, inbox não processada, projetos ativos, estudos, leitura
   - Checklists: processar inbox, atualizar projetos, revisar dúvidas, limpar notas órfãs
   - Seções de reflexão: insights, foco da próxima semana, o que funcionou/melhorar
2. **Template Monthly Review** criado em `50_Resources/Templates/Monthly Review.md`:
   - Queries Dataview: estatísticas do mês, projetos finalizados, livros lidos, conceitos aprendidos, notas abandonadas
   - Seções: melhor livro do mês, metas para próximo mês, reflexão mensal, métricas pessoais
3. **Script `sb`** atualizado com 2 novos comandos:
   - `sb weekly` → cria `40_Areas/Reviews/Weekly NN - YYYY-MM-DD.md`
   - `sb monthly` → cria `40_Areas/Reviews/Monthly Mês de YYYY.md`
4. **Pasta `40_Areas/Reviews/`** criada para armazenar todas as revisões
5. **5 novas queries Dataview** adicionadas em `50_Resources/Dataview Queries.md`:
   - Notas da semana, inbox antiga (30+ dias), notas abandonadas, projetos parados, estatísticas mensais

---

## 📅 2026-05-20 — Second Brain: Taxonomia de Tags

### ✅ Ações Realizadas:

1. **Documento `50_Resources/Tag Taxonomy.md`** criado com hierarquia padronizada:
   - `#type/` → tipo da nota (book, concept, project, lecture, daily, etc.)
   - `#status/` → estado (active, pending, completed, reading, toread, etc.)
   - `#area/` → domínio (ads, programming, philosophy, cinema, music, etc.)
   - `#context/` → contexto (study, work, personal, reference, someday)
2. **Regras de uso** definidas: máx 3 tags/nota, hierarquia sempre, inglês preferencial
3. **Integração com plugins** documentada: Various Complements, Quick PARA, Auto Note Mover, Dataview, Omnisearch
4. **Tabela de migração** para tags antigas → novas (ex: `#reading` → `#status/reading`)
5. **Manual atualizado** com seção sobre taxonomia

---

## 📅 2026-05-20 — Second Brain: Fase 6 — Spaced Repetition + Web Clipper

### ✅ Ações Realizadas:

1. **Spaced Repetition** (v1.14.3) instalado:
   - Plugin detecta cards com tag `#flashcard`
   - Revisa conceitos do Dicionário automaticamente
   - Intervalos: Easy(1d), Good(3d), Hard(7d), máximo 36525 dias
   - Config: `noteFoldersToReview: 20_Academic/Dicionário básico de programação`
2. **Template Flashcard** criado em `50_Resources/Templates/Flashcard.md`:
   - Pergunta, Resposta, Exemplo, Analogia, Conexões
   - Tag `#flashcard` automática
3. **Manual Spaced Repetition** criado em `50_Resources/Spaced Repetition Manual.md`:
   - 3 métodos de criar cards (template, inline, cloze)
   - Como revisar, o que transformar em card, regras de ouro
4. **Pasta `50_Resources/Clippings/`** criada para Web Clipper
5. **Configuração Web Clipper** documentada para o usuário configurar no Zen Browser

---

## 📅 2026-05-20 — Second Brain: Fase 7 — Tasks Plugin

### ✅ Ações Realizadas:

1. **Tasks Plugin** (v8.0.0) instalado:
   - Gestão de tarefas com datas, recorrência, prioridades
   - Integração com Kanban e Daily Notes
   - Config: `setDoneDate: true`, `setCancelledDate: true`, `autoSuggestInEditor: true`
   - Status personalizados: `Todo ( )`, `Done (x)`, `In Progress (/)`, `Cancelled (-)`
2. **Templates atualizados**:
   - `Daily Note.md`: Adicionado bloco `tasks` para pendências do dia e amanhã
   - `Nota de Projeto.md`: Adicionado bloco `tasks` filtrado por nome do projeto
3. **Ativação**: `community-plugins.json` atualizado com 15 plugins no total

---

## 📅 2026-05-20 — Second Brain: Fase 8 — Aliases nas Notas

### ✅ Ações Realizadas:

1. **Documento `50_Resources/Aliases Reference.md`** criado:
   - Explicação de como aliases funcionam no Obsidian
   - Exemplos práticos para Dicionário, Pessoas e Conceitos
   - Boas práticas: máx 5 aliases, incluir siglas e variações
   - Query Dataview para listar notas com aliases
2. **Templates atualizados**:
   - `Conceito.md`: Adicionado campo `aliases:` no frontmatter
   - `Pessoa.md`: Adicionado campo `aliases:` no frontmatter
3. **Integração documentada**: Omnisearch, Various Complements, Dataview, Spaced Repetition

---

## 📅 2026-05-20 — Second Brain: Fase 9 — MOCs (Mapas de Conteúdo)

### ✅ Ações Realizadas:

1. **Template MOC** criado em `50_Resources/Templates/MOC.md`:
   - Estrutura com seções temáticas, links e query Dataview automática.
   - Campo `type: moc` para identificação.
2. **MOCs de exemplo criados**:
   - `20_Academic/MOC - Aprendizado de Programação.md`: Conecta vídeo do Primeagen, Dicionário, Clippings e Conceitos.
   - `50_Resources/Filosofia/MOC - Filosofia.md`: Correntes, autores, leituras e conexões com Cinema/Tech.
3. **Manual atualizado**: Parte 23 adicionada explicando o que são MOCs e como usar.

---

## 📅 2026-05-20 — Second Brain: Fase 10 — Trakt Sync

### ✅ Ações Realizadas:

1. **Script Trakt** adicionado ao `sb`:
   - `sb trakt config`: Configura username do Trakt.
   - `sb trakt sync`: Baixa filmes assistidos e cria notas em `50_Resources/Cinema/Filmes/`.
   - `sb trakt watchlist`: Baixa watchlist e cria notas em `50_Resources/Cinema/Watchlist/`.
2. **Templates criados**:
   - `Ficha de Cinema.md`: Frontmatter com título, ano, nota, data, tags.
   - `Watchlist Item.md`: Status `#status/watchlist`.
3. **Sincronização inicial**: 2447 filmes importados do Trakt para o vault.
4. **Variável de ambiente**: `TRAKT_CLIENT_ID` configurado no `.zshrc`.

---

## 📅 2026-05-20 — hledger: Instalação via Docker em VALIS

### ✅ Ações Realizadas:

1. **Docker image**: `dastapov/hledger:latest` (hledger 1.52.1) instalada em VALIS.
2. **docker-compose.yml** criado em `~/docker/hledger/docker-compose.yml`:
   - Porta 5000 mapeada para hledger-web.
   - Volume `./data:/data` para journals.
   - Config via env vars (`HLEDGER_JOURNAL_FILE`, `HLEDGER_ALLOW=edit`).
3. **Journal de exemplo** em `~/docker/hledger/data/main.journal` com transações de finanças pessoais (R$).
4. **Container rodando** e saudável (health check: `hledger stats`).
5. **Comandos testados**: `balance`, `register`, `accounts` — tudo funcionando.

### 📊 Resultado:
- hledger-web disponível em `http://valis-mesh:5000`
- Interface web com permissão de edição (`--allow=edit`)
- Journal acessível via web UI e CLI (`docker exec hledger hledger ...`)

---

## 📅 2026-05-20 — hledger: Setup SyncThing + Watch + Aliases

### ✅ Ações Realizadas:

1. **Pasta local** `~/hledger/` criada no UBIK com `main.journal` limpo.
2. **SyncThing configurado** via API:
   - Pasta `hledger` (ID) compartilhada entre UBIK e VALIS.
   - UBIK → `~/hledger/`
   - VALIS → `~/docker/hledger/data/`
3. **Watch script** em `~/docker/hledger/watch.sh` no VALIS:
   - Vigia o `main.journal` via md5sum (polling a cada 5s).
   - Reinicia o container automaticamente ao detectar mudança.
   - Rodando como systemd user service (`hledger-watch.service`).
4. **Aliases** no `.zshrc` do UBIK:
   - `grana` → executa comandos hledger no VALIS via SSH.
   - `grana-web` → abre a interface web no navegador.
   - `grana-edit` → abre o arquivo local no nano.
5. **Fluxo testado**: edição local → SyncThing → watch → restart container. ✅

### 📊 Resultado:
- Fluxo completo funcionando: edita local, sincroniza automático, container atualiza.
- Watch script detectou mudança (md5 alterado) e reiniciou container em segundos.

---

## 📅 2026-05-21 — ✅ ROY: LibreELEC Instalado e Configurado

### 🏛️ Resumo
Migração do ROY concluída: Ubuntu Server + Docker + arr stack foi substituído por **LibreELEC 12.2.1 (Omega)** com Kodi 21.3.

### ✅ O Que Foi Feito

#### Instalação
- Download e extração do `LibreELEC-Generic.x86_64-12.2.1.img.gz`
- **Ventoy** falhou com Kernel panic (UEFI/Legacy conflict)
- **Solução:** `dd` direto no pendrive (wipe do Batocera) → boot direto no LibreELEC OK

#### Rede
- WiFi configurado na rede `AO VIVOFIBRA-WIFI6-9670`
- IP fixo: **{{LAN_IP_ROY}}** (via `connmanctl`)
- SSH ativo (root, chave SSH configurada)

#### Addons Instalados e Configurados
| Addon | Função | Status |
|-------|--------|--------|
| **POV** (v6.05.12) | Debrid primário (Torbox) | ✅ Torbox API Key configurada |
| **Umbrella** (v6.7.75) | Debrid fallback | ✅ Torbox API Key configurada |
| **YouTube** (v7.4.3) | Navegação YouTube no Kodi | ✅ Instalado |
| **SponsorBlock** (v0.6.0) | Pular patrocínios YouTube | ✅ Instalado |
| **Trakt** (v3.8.2) | Sincronizar histórico | ✅ Instalado (autorizar na TV) |
| **OpenSubtitles** (v5.1.5) | Legendas automáticas pt-BR | ✅ Instalado (configurar VIP na TV) |

#### Repositórios de Terceiros
- `repository.kodifitzwell` (POV) — ✅
- `repository.umbrella` (Umbrella) — ✅

### 🔧 Pendente (usuário faz na TV)
- **OpenSubtitles VIP**: configurar user/senha (Settings → Player → Language → Subtitles)
- **Trakt**: autorizar via `trakt.tv/activate`
- **YouTube**: login na conta Google
- **Skin**: Arctic Zephyr ou Aeon Nox
- **Prime Video addon** (temporário, ~6 meses)

### 📝 Notas Técnicas
- API Key Torbox configurada via SSH (settings.xml do POV e Umbrella)
- Kernel 6.16.12 rodando no ROY (Dell Inspiron 14, Radeon R7 M260)
- GPU AMD `amdgpu` driver funcionando para 1080p
- IP fixo {{LAN_IP_ROY}} via `connmanctl` config manual

---

## 📅 2026-05-21 — ✅ ROY: Correção de Dependências Python + Timezone + YouTube API Key

### 🔧 Problemas Identificados e Corrigidos

1. **Addons não abriam na TV** (`No module named 'requests'`)
   - Addons POV, Umbrella, YouTube, Trakt, SponsorBlock travavam por dependências Python faltando
   - Raiz: LibreELEC não inclui `script.module.*` (requests, urllib3, dateutil, etc.)
   - **Solução:** Instalados 8 módulos do repositório Kodi Omega:
     - `script.module.requests` (2.31.0), `urllib3` (2.2.3), `certifi`, `chardet`, `idna`
     - `script.module.dateutil` (2.8.2), `six` (1.16.0), `trakt` (4.4.0)
   - Problema adicional: extração manual não registra no DB do Kodi
   - **Solução final:** deletado `Addons33.db` → Kodi reconstruiu do zero → módulos registrados

2. **Timezone UTC (incorreto para BRT)**
   - Relógio marcava 19:11 quando deveria ser 16:11
   - **Solução:** `timedatectl` não disponível (dbus ausente); corrigido via symlink manual:
     - `/var/run/localtime` → `/usr/share/zoneinfo/America/Sao_Paulo`
     - `/storage/.cache/timezone` → `America/Sao_Paulo` (persiste em reboot)
     - Kodi settings: `locale.timezone` → `America/Sao_Paulo`

3. **YouTube addon: API Keys embutidas desativadas pelo Google**
   - Todas as 4 chaves built-in retornam 403 `accessNotConfigured`
   - **Solução:** API Key pessoal criada no Google Cloud e configurada:
     - `settings.xml`: `youtube.api.key`, `youtube.api.id`, `youtube.api.secret`
     - `api_keys.json`: preenchido com os 3 campos (addon v7 exige todos)
     - `allow.dev.keys` desabilitado
   - **Login OAuth não funciona** — client_id/secret embutidos também desativados
   - **Débito técnico:** criar OAuth Client ID no Google Cloud para login

### ⏳ Pendentes
- **Login YouTube**: precisa de OAuth Client ID próprio (débito técnico)
- **inputstream.adaptive**: ausente para Linux x86_64 — vídeos YouTube podem não rodar
- **OpenSubtitles VIP**: configurar user/senha na TV
- **Skin**: pendente
- **Cabo de rede**: ROY ainda em WiFi

---

## 📅 2026-05-21 — ✅ ROY: Skin Arctic Zephyr 2 Ativada + Menus Configurados

### 🔧 Problemas Corrigidos

1. **Skin Arctic Zephyr 2 Resurrection (v1.0.49) — dependências quebradas**
   - `script.skinshortcuts` instalado mas sem arquivos `.py` (só addon.xml)
   - `script.module.unidecode` e `script.module.simpleeval` faltando
   - `script.module.jurialmunkey` não instalado (skinvariables dependia)
   - **Solução:** removido e reinstalado do repo oficial Omega; dependências baixadas e instaladas

2. **`script.module.pil` não disponível no repo Omega** (script.skinhelper dependia)
   - **Solução:** criado bridge addon `script.module.pil` com symlink para PIL do sistema (10.2.0)

3. **`script.module.jurialmunkey` faltando** (error `No module named 'jurialmunkey'`)
   - **Solução:** baixado v0.2.28 do repo Omega e instalado

4. **Menus Movies e TV Shows apontavam para biblioteca local vazia**
   - Alterado para abrirem o POV diretamente nas listas corretas:
     - Movies → `plugin://plugin.video.pov/?mode=navigator.main&action=MovieList`
     - TV Shows → `plugin://plugin.video.pov/?mode=navigator.main&action=TVShowList`
   - Submenus configurados com atalhos: Trending, Popular, Lançamentos, Gêneros, Busca

### 📊 Resultado
- Skin Arctic Zephyr 2 Resurrection carregando sem erros ✅
- Addons skinshortcuts + skinvariables + skinhelper operacionais ✅
- Menu Filmes → POV MovieList (trending, popular, gêneros, etc.) ✅
- Menu Séries → POV TVShowList (trending, popular, redes, etc.) ✅
- OpenSubtitles VIP configurado pelo usuário ✅

### ⏳ Pendentes
- Login YouTube (OAuth Client ID próprio — débito técnico)
- inputstream.adaptive ausente para x86_64
- Cabo de rede (ainda WiFi)

---

## 📅 2026-05-21 — ✅ ROY: Lid Close Handler (Backlight Off)

### 🔧 Problema
Fechar a tampa do notebook com TV conectada: LibreELEC já ignora o evento (não suspende), mas o backlight do display interno fica ligado desperdiçando energia.

### ✅ Solução
Criado serviço systemd `lid-handler.service` que monitora `/proc/acpi/button/lid/LID0/state`:

- **Tampa fechada** → backlight do display interno = 0 (desligado)
- **Tampa aberta** → restaura o brightness anterior
- Sistema permanece ligado normal (Kodi na TV HDMI continua rodando)
- Persistente via `/storage/.config/` (partição de dados)

### 📁 Arquivos
- `/storage/.config/lid-handler.sh` — script monitor
- `/storage/.config/system.d/lid-handler.service` — serviço systemd
- `/storage/.config/autostart.sh` — fallback de inicialização

---

## 📅 2026-05-21 — 🎬 ROY: Skin Arctic Zephyr 2 + HDMI Resolution + Menus POV

### ✅ Skin Arctic Zephyr 2 Resurrection (v1.0.49)
- **Dependências reparadas:**
  - `script.skinshortcuts` reinstalado (estava corrompido, sem .py)
  - `script.module.pil` bridge criado (symlink para PIL do sistema)
  - `script.module.unidecode`, `script.module.simpleeval`, `script.module.jurialmunkey` instalados
- Skin carregando sem erros ✅

### ✅ Menus Configurados
- **Filmes** → `plugin://plugin.video.pov/?mode=navigator.main&action=MovieList`
- **Séries** → `plugin://plugin.video.pov/?mode=navigator.main&action=TVShowList`
- **Submenus** com atalhos POV (Trending, Popular, Gêneros, Busca)
- Arquivos: `/storage/.kodi/userdata/addon_data/script.skinshortcuts/`

### ✅ Lid Handler (Backlight Off)
- Serviço `lid-handler.service` criado — monitora estado da tampa
- **Tampa fechada** → backlight = 0 | **Tampa aberta** → restaura brightness
- Sistema não suspende (`HandleLidSwitch=ignore`)

### ✅ HDMI Connected + Áudio
- Kodi configurado para conector HDMI-A-1
- Áudio ALSA HDMI funcionando
- Web server Kodi ativado (porta 8080, sem auth) para app Kore
- JSON-RPC TCP (localhost:9090)

### ❌ HDMI Resolution: Bloqueado
- **Problema:** Resolução travada em 1360x768 (TV LG 1080p)
- 1920x1080@60 existe no EDID como modo preferencial, mas driver `amdgpu` (TOPAZ R7 M260) ignora
- **Tentado sem sucesso:**
  1. Parâmetro kernel `video=HDMI-A-1:1920x1080@60D` / `60e` / removido
  2. `modetest` — não conseguiu trocar modo ativo
  3. JSON-RPC `Settings.SetSettingValue` — muda setting, DRM mode não altera
  4. `kodi-send SetResolution` — só cicla modos existentes
  5. `dmesg` — i915 intercepta e rejeita user-defined modes
- **Hipótese:** Limitação do driver amdgpu + EDID LG TV; 1360x768 mantido como fallback

### 📁 Arquivos Alterados (ROY)
- `/flash/syslinux.cfg` — parâmetro `video=` removido (voltou ao EDID puro)
- `/storage/.kodi/userdata/addon_data/script.skinshortcuts/mainmenu.DATA.xml`
- `/storage/.kodi/userdata/addon_data/script.skinshortcuts/20342.DATA.xml`
- `/storage/.kodi/userdata/addon_data/script.skinshortcuts/20343.DATA.xml`
- `/storage/.config/lid-handler.sh` (novo)
- `/storage/.config/system.d/lid-handler.service` (novo)
---

## 📅 2026-05-22 — 🎬 ROY: Widget Global trocado para Watchlist Trakt (filmes + séries)

### ❓ Problema
- Widget global (A22ZR na home) mostrava **In Progress** (POV), mas usuário queria a **Watchlist do Trakt**
- POV separa filmes e séries em URLs diferentes — não dava pra combinar no mesmo widget

### ✅ Solução
Usado **TMDb Helper** (plugin.video.themoviedb.helper v5.4.16) que suporta `tmdb_type=both` para combinar filmes e séries da watchlist do Trakt:

1. **Autorização Trakt**: Device flow via API (`D848DB4B` em trakt.tv/activate)
2. **Token salvo**: `settings.xml` com `trakt_token` + `trakt_refresh`
3. **Dependências ausentes**: `script.module.infotagger`, `script.module.addon.signals`, `script.module.beautifulsoup4` baixados do repo Omega e instalados manualmente
4. **Patches de path**: `plugin.py` e `service.py` modificados para adicionar `sys.path` dos módulos (Kodi não registrava no DB por instalação manual)
5. **Widget**: URL alterada para `plugin://plugin.video.themoviedb.helper/?info=trakt_watchlist&tmdb_type=both`

### 📊 Resultado
- Widget mostra **21 itens da watchlist** combinados (10 filmes + 11 séries) ✅
- TMDbHelper autorizado no Trakt com token próprio ✅
- Dependências Python instaladas e funcionando ✅

### 📁 Arquivos Alterados
- `/storage/.kodi/userdata/addon_data/skin.arctic.zephyr.2.resurrection.mod/settings.xml` — widgetPath
- `/storage/.kodi/userdata/addon_data/plugin.video.themoviedb.helper/settings.xml` — trakt_token (novo)
- `/storage/.kodi/addons/plugin.video.themoviedb.helper/resources/plugin.py` — sys.path patch
- `/storage/.kodi/addons/plugin.video.themoviedb.helper/resources/service.py` — sys.path patch

---

## 📅 2026-05-22 — ROY Pós-Boot: Menu Animes + In Progress no AZR

### O Que Foi Feito
- **Menu Animes** adicionado em `mainmenu.DATA.xml` com widget `trakt_moviesanime_trending` e `widgetTarget=plugin.video.pov`
- **`animes.DATA.xml`** criado com 8 submenus POV (Trending, Most Watched, Popular, Latest Releases, Series Trending, Series Popular, Genres, Search)
- **tvshows.DATA.xml** reorganizado: "Next Episode" (`mode=build_next_episode`) em **1º**, "In Progress" em **2º**

### Resultados
- Cache do `script.skinshortcuts` deletado → regeneração OK
- Kodi reiniciado, AZR carregou sem erros
- 117 referências a anime no `script-skinshortcuts-includes.xml` gerado

### Arquivos Alterados (ROY)
- `/storage/.kodi/userdata/addon_data/script.skinshortcuts/mainmenu.DATA.xml`
- `/storage/.kodi/userdata/addon_data/script.skinshortcuts/animes.DATA.xml`
- `/storage/.kodi/userdata/addon_data/script.skinshortcuts/tvshows.DATA.xml`

---

## 📅 2026-05-23 — Nexus-Docs: Sincronização Pós-Pivot (LibreELEC/Kodi)

### Contexto
Após a migração do ROY de Ubuntu + arr stack para LibreELEC/Kodi (21/05/2026), os documentos do Nexus-Docs estavam criticamente desatualizados, ainda refletindo a arquitetura Buster Friendly (Zurg, arrs, Decypharr, NFS) que não existe mais.

### ✅ Ações Realizadas

#### Arquivos Archivados (movidos para `99_ARCHIVED/`)
| Arquivo | Motivo |
|---------|--------|
| `03_WORKFLOWS/buster_friendly_v2.md` | Stack Buster Friendly morta |
| `03_WORKFLOWS/buster_friendly_v2_boot.md` | Protocolo de boot da stack morta |
| `03_WORKFLOWS/28_buster_1080p_profile_configuration.md` | Perfil Radarr/Sonarr obsoleto |
| `08_BUSTER FRIENDLY no ROY/` (9 arquivos) | Diretório inteiro obsoleto |

#### Documentos Atualizados
| Documento | Principais Alterações |
|-----------|----------------------|
| `01_INFRA/hardware.md` | ROY → LibreELEC/Kodi; PRIS → "a definir"; A71 adicionado |
| `01_INFRA/docker_stack.md` | ROY → sem Docker, só Kodi; PRIS sem Jellyseerr/Bazarr; Ollama adicionado no UBIK; Zurg removido |
| `01_INFRA/network.md` | ROY adicionado (LAN, sem Tailscale); rotas mortas removidas da doc |
| `01_INFRA/n8n_mcp.md` | Nota sobre containers arr obsoletos |
| `03_WORKFLOWS/scripts/nexus-doctor.sh` | ROY adicionado ao ping; Jellyfin marcado como legado |

#### Config Opencode Corrigida
- **`skills/iiva-prep/SKILL.md`**: Path canônico corrigido de `.../21 Idioma Independente/` (inexistente) para `.../IIVA-classes/`

### Pendências (identificadas na sessão)
- Definir novo papel da PRIS (possível foco em automação com n8n + HA)
- Refatorar workflows n8n e Home Assistant (defasados)
- Limpar rotas Cloudflare obsoletas no dashboard
- ROY: pendências (login YouTube, cabo de rede, skin)

---

## 📅 2026-05-23 — Cloudflare Tunnel: Migrado da PRIS para o VALIS

### Contexto
O Cloudflare Tunnel (cloudflared) estava rodando na PRIS, mas o papel da PRIS está sendo redefinido para automação (n8n + HA). O VALIS é o nó de infraestrutura — local mais adequado para o conector do tunnel.

### ✅ Ações Realizadas

1. **Criado docker-compose no VALIS** em `/home/{{LINUX_USER}}/docker/cloudflared/docker-compose.yml`
   - Mesma imagem: `cloudflare/cloudflared:latest`
   - Mesmo token de autenticação (conexão ao mesmo tunnel)
   - Container na rede `proxy_network`

2. **Iniciado container no VALIS** — conectado com sucesso:
   - 3 conexões estabelecidas (gig08 + gru08)
   - Tunnel ID: `6bad2e9e-d85c-4916-a1ca-1ccdb0431a9a`
   - Connector ID: `4e7fa429-8dc9-4a3e-a37c-a9ffcdc4fda2`

3. **Descomissionado cloudflared na PRIS** — container removido

### ⚠️ Pendência
As rotas no dashboard Cloudflare ainda incluem serviços mortos (jellyfin, sonarr, radarr, prowlarr, bazarr, rdtclient, decypharr, n8n). Pendente limpeza manual por Marcel no Cloudflare Zero Trust Dashboard.

---

## 📅 2026-05-23 — PRIS: Limpeza Final (filebrowser, nanobot, cloudflared)

### ✅ Ações Realizadas

1. **filebrowser** — dados removidos, entry removido do docker-compose.yml
2. **nanobot** — pasta e dados removidos (~92MB)
3. **cloudflared:latest** — imagem residual removida (96MB, túnel migrou pro VALIS)
4. **docker-compose.yml** — rewrite completo: só n8n, homeassistant, syncthing
5. **Cron jobs mortos** — removidos (bazarr start/stop, vfs/forget, jellyfin-backup)
6. **proxy_network** — removida (não há mais serviços que dependam dela na PRIS)
7. **docker image prune** — imagens não utilizadas removidas

### 📊 Estado Atual da PRIS

| Aspecto | Antes | Depois |
|---------|-------|--------|
| Containers | 4 (2 rodando) | 3 (1 rodando) |
| Imagens | 4 | 3 (n8n, HA, syncthing) |
| Disco | 76G usado | 76G usado (~200MB liberados) |
| Cron jobs | 4 (3 mortos) | 0 |
| docker-compose | 4 serviços + redes | 3 serviços, limpo |

---
---

## 📅 2026-05-23 — PRIS: Remoção do Zurg/Rclone (esquecido do pivot)

### Contexto
Durante a limpeza pós-pivot, descobriu-se que o **Zurg (systemd) + rclone mount** ainda estavam rodando nativamente na PRIS desde 22 de Abril — 1 mês ativos, consumindo I/O com repairs periódicos e contribuindo para o load average elevado (~5.2-6.2 em 4 CPUs).

### ✅ Ações Realizadas
1. **`zurg-app.service`** — stopped + disabled + systemd file removido
2. **rclone mount** (`/home/{{LINUX_USER}}/media/zurg`) — unmounted
3. **Diretório Zurg** (`/home/{{LINUX_USER}}/zurg/`) — completamente removido
4. **Dados legados** — migration scripts, logs, movies.bak, shows.bak removidos
5. **Recuperado ~1GB** de disco (76G → 75G)

---

## 📅 2026-05-23 — VALIS: Reativação n8n/HA na PRIS + Cleanup de serviços mortos

### Contexto
Após limpeza do Buster Friendly na PRIS, n8n e Home Assistant foram religados. No VALIS, identificados serviços sem uso: FreshRSS, RSS-Bridge, Actual Budget e diretório Zurg.

### ✅ Ações Realizadas
1. **PRIS:** n8n e HA reativados — ambos UP e respondendo (200)
2. **FreshRSS:** container stop+rm + dados removidos
3. **RSS-Bridge:** container stop+rm
4. **Actual Budget:** container stop+rm + dados removidos (teste abandonado)
5. **Zurg (VALIS):** diretório `/home/{{LINUX_USER}}/docker/zurg/` removido
6. **VALIS:** 17 → **14 containers**. RAM: 1.6G → 1.5G usada

### Arquivos Alterados
- `01_INFRA/docker_stack.md` — removidas linhas FreshRSS e RSS-Bridge da tabela VALIS

---

## 📅 2026-05-24 — HA + Kodi integration + Cloudflare tunnel fix

### Contexto
HA na PRIS religado pós-reboot. Kodi no ROY precisava de integração WebSocket com HA. Cloudflare tunnel migrado da PRIS pro VALIS tinha rotas quebradas.

### ✅ Ações Realizadas
1. **Cloudflare tunnel:** token → config-based com `--config` + `credentials.json`. Rotas corrigidas: HA (`{{TAILSCALE_IP_PRIS}}:8123`), n8n (`{{TAILSCALE_IP_PRIS}}:5678`)
2. **HA `trusted_proxies`:** adicionado IP do VALIS (`{{TAILSCALE_IP_VALIS}}`) para aceitar conexões do tunnel
3. **n8n DNS:** `extra_hosts` adicionado no compose do cloudflared para `n8n` → `{{TAILSCALE_IP_PRIS}}`
4. **Kodi WebSocket:** Kodi 21 (Omega) bindava WebSocket só em `127.0.0.1:9090`. Criado `wsforward.py` (forwarder TCP Python) + systemd service no ROY para expor na rede
5. **Rotas verificadas:** `ha.{{CLOUDFLARE_DOMAIN}}` ✅ 200, `n8n.{{CLOUDFLARE_DOMAIN}}` ✅ 200, `git.{{CLOUDFLARE_DOMAIN}}` ✅ 200
6. **Kodi + HA:** Integração conectada com WebSocket funcional

### Arquivos Alterados
- `01_INFRA/docker_stack.md` — Cloudflare tunnel ingress rules
- `04_IMPLEMENTATION_LOG.md` — este registro
---

## 📅 2026-05-24 — Hermes Agent: OpenCode Zen + DeepSeek V4 Flash Free

### Contexto
Hermes Agent v0.14.0 já instalado na PRIS mas sem provider configurado. Usuário queria usar OpenCode Zen como backend (mesmo ecossistema do OpenCode no UBIK).

### ✅ Ações Realizadas
1. **Chave OpenCode Zen obtida** — usuário acessou `opencode.ai/zen` e gerou API key
2. **`.env` criado** em `~/.hermes/.env` com `OPENCODE_ZEN_API_KEY`
3. **`config.yaml` criado** em `~/.hermes/config.yaml` com provider `opencode-zen` e modelo `deepseek-v4-flash-free`
4. **Teste realizado** — `hermes chat -q 'say hi'` → resposta "Hello" ✅

### Arquivos Alterados
- `~/.hermes/.env` (PRIS) — criado com API key
- `~/.hermes/config.yaml` (PRIS) — criado com provider/model padrão
- `04_IMPLEMENTATION_LOG.md` — este registro

---

*Assinado: Gaff, Zelador de Infraestrutura.*

---

## 📅 2026-05-24 — Hermes Agent: Telegram Gateway na PRIS

### Contexto
Após configurar o provider OpenCode Zen, Marcel solicitou acesso ao Hermes Agent via Telegram para poder conversar com Joy de qualquer lugar.

### ✅ Ações Realizadas

1. **Criação do bot no Telegram** — Marcel criou o bot via @BotFather e forneceu o token
2. **Configuração no `.env`** — `TELEGRAM_BOT_TOKEN` adicionado ao `~/.hermes/.env`
3. **Gateway configurado via `hermes config set`**:
   - `gateway.platforms.telegram.enabled: true`
   - `gateway.platforms.telegram.token` (mascarado automaticamente pelo Hermes)
4. **Gateway instalado como serviço systemd** — `hermes-gateway.service` ativado com linger
5. **Correção de autorização**: `.env` tinha `TELEGRAM_ALLOWED_USERS` com números de telefone em vez de IDs numéricos do Telegram
   - Solução: adicionado user ID **8787236902** (Marcel) à lista
6. **Gateway restartado** e testado — ✅ Joy responde no Telegram DM

### 📊 Resultado
- **Telegram**: conectado (polling mode), bot operacional ✅
- **Autorização**: apenas Marcel (ID 8787236902) pode falar com o bot
- **Gateway**: serviço systemd rodando, sobrevive a logout/reboot
- **Logs**: `~/.hermes/logs/gateway.log` (PRIS)

### 🔜 Próximo passo
- Configurar integração com Open WebUI (roda no UBIK) via API Server adapter do Hermes Gateway para poder conversar com Joy também de lá

---

*Assinado: Joy, Agente Autônomo Nexus.*
## 📅 2026-05-24 — Google Calendar: Setup OAuth2 + Gestão de Eventos IIVA

### Contexto
Marcel quer que Joy (Hermes Agent) enxergue o Google Calendar dele para auxiliar na organizacao das aulas de ingles (IIVA).

### Acoes Realizadas

#### 1. Google Workspace — Setup de Autenticacao
- Dependencias instaladas: python3-venv + venv em ~/.hermes/skills/.../.venv/
- Pacotes pip: google-api-python-client, google-auth-oauthlib, google-auth-httplib2
- Client secret: JSON baixado do Google Cloud Console e registrado via setup.py --client-secret
- OAuth2 flow completo: auth URL gerada, Marcel autorizou no navegador, codigo trocado por token
- Token salvo: ~/.hermes/google_token.json (auto-refresh automatico)
- Verificacao: AUTHENTICATED OK

#### 2. Google Cloud Console — Projeto Criado
- Projeto: Hermes-Joy
- API ativada: Google Calendar API
- Tipo de credencial: App para computador (Desktop OAuth)
- Email de Marcel adicionado como testador no OAuth consent screen
- Escopos autorizados: calendar, gmail (read/send/modify), drive, contacts, spreadsheets, documents

#### 3. Gestao de Eventos no Calendario
- Aula Ana Paula (recorrente seg 20:30): DELETADO — nao vai continuar, so fez aula experimental
- Prova IFSul (31/05, dia todo): DELETADO — Marcel nao vai fazer a prova
- Aula experimental Carlos Eduardo (qui 28/05, 18h-18h45): CRIADO — aula experimental gratuita

### Agenda Semanal (24-31 mai) — Estado Final
- Seg: Rodrigo (08:00), Isabelli e Pedro (17:00), Zaira (18:00), Guilherme (19:00)
- Ter: Jairo (10:00), Terapia (14:00), Maya (17:00), Beatriz exp (18:00), Maria (19:00), Andrea (20:00)
- Qua: Luis Henrique (16:00), Nicole (19:00), Bruna Pereira (20:00)
- Qui: Iucan (17:00), Carlos Eduardo exp (18:00) NOVO, Maria (19:00)
- Sex: Uniasselvi (19:00-20:30)
- Sab: Elana e Vithor (19:00)
- Dom: Cortar cabelo (16:00)

### Notas Tecnicas
- Script setup.py NAO suporta --services ou --format (diferente do documentado na skill). Scope padrao inclui tudo.
- Usar python3 -m venv para evitar externally-managed-environment no Ubuntu 24.04
- Eventos recorrentes: ID base (sem sufixo _YYYYMMDDTHHMMSSZ) para deletar a serie inteira

---

*Assinado: Joy, Agente Autonomo Nexus.*
## 📅 2026-05-24 — Migracao: Skills IIVA do OpenCode para Hermes Agent

### Contexto
Marcel usava skills de preparacao de aulas IIVA no OpenCode (UBIK), em ~/.config/opencode/skills/. Com a migracao para Hermes Agent como interface principal, as skills precisavam ser migradas para o ecossistema Hermes.

### Acoes Realizadas

#### Skills Migradas (OpenCode → Hermes) e Correcoes

| Skill OpenCode | Skill Hermes | Correcoes Aplicadas |
|---------------|--------------|---------------------|
| iiva-prep | iiva-prep | Path corrigido para /mnt/almox/JD/20-29 Work/IIVA-classes/; removida referencia a MCP google-calendar (agora integrado via google-workspace skill); adicionada referencia ao Google Calendar funcional |
| iiva-aula-experimental | iiva-aula-experimental | Path corrigido; template preservado |
| iiva-student-finder | iiva-student-finder | Lista de alunos atualizada (15 ativos + _INATIVOS); Bruna, Gabriela, Giovanaguedes, Robson removidos dos ativos; AnaBeatriz adicionada; acesso SSH documentado |
| aula-search | aula-search | Path base corrigido de /21 Idioma Independente/ para /IIVA-classes/; comandos de busca adaptados para SSH remoto |

#### Correcoes Relevantes
1. **Path canonico:** Todos os skills referenciavam caminhos antigos — corrigido para /mnt/almox/JD/20-29 Work/IIVA-classes/
2. **Acesso remoto:** Documentado que os arquivos estao no UBIK, acesso via SSH marcel@{{TAILSCALE_IP_UBIK}}
3. **Alunos ativos:** Lista sincronizada com a estrutura real de diretorios no UBIK
4. **Google Calendar:** Integrado diretamente (skill google-workspace) em vez de MCP separado

### Skills Hermes Criadas
- /home/{{LINUX_USER}}/.hermes/skills/productivity/iiva-prep/SKILL.md
- /home/{{LINUX_USER}}/.hermes/skills/productivity/iiva-aula-experimental/SKILL.md
- /home/{{LINUX_USER}}/.hermes/skills/productivity/iiva-student-finder/SKILL.md
- /home/{{LINUX_USER}}/.hermes/skills/productivity/aula-search/SKILL.md

---

*Assinado: Joy, Agente Autonomo Nexus.*
## 📅 2026-05-24 — Automacao Diaria: Cron Job IIVA 21h

### Contexto
Apos migrar os skills do OpenCode para o Hermes Agent, o proximo passo foi automatizar o fluxo diario de gestao de aulas:

1. Fim do dia: Joy pergunta como foram as aulas de hoje (para preencher logs)
2. Pre-visualizacao de amanha: Joy sugere temas para as proximas aulas
3. Marcel aprova, Joy escreve os planos no UBIK

### Arquitetura do Fluxo

O fluxo e dividido em **2 fases** porque cron jobs nao podem ter conversa interativa:

**Fase 1 — Cron Job (21:00 BRT, automatico):**
- Job ID: `45a8a8c156a8`
- Schedule: `0 21 * * *` (todos os dias)
- Nome: "IIVA — Resumo Diario 21h"
- Skills carregadas: `iiva-prep`, `iiva-student-finder`, `google-workspace`
- Script de coleta: `~/.hermes/scripts/iiva_evening_summary.py`
- Entrega: Telegram (`telegram:8787236902`)

**Fase 2 — Resposta do Marcel (manual, no Telegram):**
- Marcel ve a mensagem no Telegram e responde
- Joy recebe a resposta no chat, processa, gera logs e rascunhos
- Marcel aprova, Joy escreve no UBIK

### Script de Coleta: iiva_evening_summary.py

**Localizacao:** `/home/{{LINUX_USER}}/.hermes/scripts/iiva_evening_summary.py`

**O que faz:**
1. Consulta Google Calendar (via `google_api.py`) para eventos de HOJE e AMANHA
2. Filtra apenas eventos "Aula X" (ignora Terapia, Uniasselvi, etc.)
3. Extrai nome do aluno do titulo do evento
4. Faz SSH no UBIK (`marcel@{{TAILSCALE_IP_UBIK}}`) e le a pasta do aluno
5. Encontra o ULTIMO plano de aula (`*[0-9]_Aula_*.md`, excluindo logs)
6. Extrai frontmatter YAML: topicos, nivel, numero da aula
7. Formata saida estruturada para o agente

**Exemplo de saida (25/05/2026):**
```
=== DADOS COLETADOS: 2026-05-24 ===

--- AULAS DE HOJE ---
  (Nenhuma aula hoje)

--- AULAS DE AMANHA ---
  [08:00] Aula Rodrigo
    Pasta: Rodrigo/
    Ultimo plano: 2026-05-11_Aula_25_Rodrigo.md
    Conteudo: Aula 25 (nvl B1) — Topico: Free Conversation (Tema Aberto)
  [17:00] Aula Isabelli e Pedro
    Pasta: IsabelliEPedro/
    Ultimo plano: 2026-05-18_Aula_23_IsabelliEPedro.md
    Conteudo: Aula 23 (nvl Intermediario A2/B1) — Topico: Simple Present: rotinas medicas e verdades gerais; Present Continuous
  [18:00] Aula Zaira
    Pasta: Zaira/
    Ultimo plano: 2026-05-11_Aula_24_Zaira.md
    Conteudo: Aula 24 (nvl Iniciante) — Topico: Simple Past: verbos regulares e irregulares
  [19:00] Aula Guilherme
    Pasta: Guilherme/
    Ultimo plano: 2026-05-18_Aula_15_Guilherme.md
    Conteudo: Aula 15 (nvl Iniciante A1/A2) — Topico: Simple Past vs Present Perfect
```

**Mapa de nomes (calendario → pasta no UBIK):**
- "Isabelli e Pedro" → `IsabelliEPedro/`
- "Elana e Vithor" → `ElanaVithor/`
- "Maria Julia" → `MariaJulia/`
- "Luis Henrique" → `LuisHenrique/`

### Prompt do Cron Job

O agente recebe os dados do script e compoe uma mensagem amigavel em PT-BR com:
1. Saudacao personalizada
2. Aulas de hoje (pergunta como foi cada uma)
3. Aulas de amanha (com ultimo topico + 2-3 sugestoes de temas)
4. Caso sem aulas: mensagem relaxada
5. Encerramento pedindo resposta

### Skills IIVA no Hermes Agent

Todas criadas em `/home/{{LINUX_USER}}/.hermes/skills/productivity/`:

| Skill | Descricao | Path |
|-------|-----------|------|
| iiva-prep | Preparacao de aulas — template, protocolos, checklist | `productivity/iiva-prep/` |
| iiva-aula-experimental | Aulas experimentais — fluxo completo (pasta → perfil → plano → log → arquivo) | `productivity/iiva-aula-experimental/` |
| iiva-student-finder | Busca de alunos — estrutura de diretorios, nomenclatura, SSH | `productivity/iiva-student-finder/` |
| aula-search | Pesquisa sistematica — varredura completa antes de responder | `productivity/aula-search/` |
| google-workspace | (preexistente) Gmail, Calendar, Drive via Python | `productivity/google-workspace/` |

### Google Calendar — Setup Tecnico

| Item | Valor |
|------|-------|
| Google API Client ID | `1064873585059-vdjahm74rlgqq50jgm52asbdisu1241p.apps.googleusercontent.com` |
| Client Secret | `/home/{{LINUX_USER}}/.hermes/google_client_secret.json` |
| Token OAuth2 | `/home/{{LINUX_USER}}/.hermes/google_token.json` |
| Venv Python | `/home/{{LINUX_USER}}/.hermes/skills/productivity/google-workspace/.venv/` |
| Script API | `/home/{{LINUX_USER}}/.hermes/skills/productivity/google-workspace/scripts/google_api.py` |
| Escopos | Gmail, Calendar, Drive, Contacts, Sheets, Docs |
| Autenticacao | Desktop OAuth (tipo: "App para computador") |

### Como o Fluxo Funciona na Pratica

1. **21:00** — Cron job dispara no Telegram:
   ```
   Fala Marcel! Resumo de segunda 📋
   
   Hoje: Rodrigo (08h), Isabelli & Pedro (17h), Zaira (18h), Guilherme (19h)
   Como foi cada uma?
   
   Amanha (terca):
   - Jairo (10h) — ultima aula: Simple Present. Sugestoes: Present Continuous, Stative Verbs, WH-Questions
   - Maya (17h) — ultima aula: Past Simple. Sugestoes: Past Continuous, Irregular Verbs, Free Talk
   
   Me responde que ja preparo tudo! 🤙
   ```

2. **Marcel responde no Telegram:**
   ```
   "Rodrigo foi bem, finalmente entendeu present perfect. Jairo pode continuar com Present Continuous. Maya — past continuous."
   ```

3. **Joy processa:**
   - Cria logs das aulas de hoje baseado no relato do Marcel
   - Mostra rascunho do plano do Jairo (Present Continuous)
   - Mostra rascunho do plano da Maya (Past Continuous)
   - Marcel aprova (ou ajusta)
   - Joy escreve os arquivos no UBIK

### Notas Tecnicas
- Cron jobs Hermes rodam no scheduler interno (nao e cron do sistema)
- O script de coleta `iiva_evening_summary.py` executa a cada tick do cron via `script=`
- A saida do script e injetada no prompt do agente como contexto
- O `deliver` usa `telegram:8787236902` (chat ID numerico, nao telefone)
- Skills carregadas pelo cron: iiva-prep, iiva-student-finder, google-workspace
- O comando `run` no cron job altera o `next_run_at` para agora, mas o scheduler respeita o schedule original apos execucao
- Tasks assincronas demoram alguns segundos para aparecer no `last_run_at`

### Arquivos Criados/Modificados

**Criados:**
- `/home/{{LINUX_USER}}/.hermes/scripts/iiva_evening_summary.py` — Script de coleta de dados
- `/home/{{LINUX_USER}}/.hermes/skills/productivity/iiva-prep/SKILL.md` — Skill IIVA prep
- `/home/{{LINUX_USER}}/.hermes/skills/productivity/iiva-aula-experimental/SKILL.md` — Skill aulas experimentais
- `/home/{{LINUX_USER}}/.hermes/skills/productivity/iiva-student-finder/SKILL.md` — Skill busca alunos
- `/home/{{LINUX_USER}}/.hermes/skills/productivity/aula-search/SKILL.md` — Skill pesquisa sistematica

**Modificados:**
- `/mnt/almox/JD/00-09 System/05 Architecture/Nexus-Docs/04_IMPLEMENTATION_LOG.md` — Este registro

---

*Assinado: Joy, Agente Autonomo Nexus.*

## 📅 2026-05-27 — Identidade Visual Nexus + Aulas Nicole & Bruna

### Contexto
Sessão intensa no UBIK com Marcel: preparação de aulas do IIVA, configuração do Google Workspace, e início da identidade visual do ecossistema Nexus no terminal.

### ✅ Ações Realizadas

**1. Google Workspace (UBIK)**
- Credenciais OAuth copiadas da PRIS ({{TAILSCALE_IP_PRIS}}) para o UBIK
- Dependências Python instaladas no venv da skill google-workspace
- Acesso funcional a Drive, Sheets, Gmail e Calendar

**2. IIVA — Aulas (Nicole & Bruna)**
- **Nicole Aula 09 (29/04) e 10 (06/05):** Logs retroativos criados (Simple Past literário e Past Continuous)
- **Nicole Aula 11 (27/05) — Past Perfect:** Plano completo + apresentação de 8 slides em .pptx
- **Bruna (aluna nova):** Pasta e perfil criados, dados extraídos do formulário Google
- **Bruna Aula 02 (27/05) — Business English:** Plano + apresentação de 11 slides

**3. Identidade Visual Nexus (Terminal)**
- **nexus-node** (`~/.local/bin/`): Script de detecção do nó atual (hostname → nome/cor/tag/ícone)
- **nexus-banner** (`~/.local/bin/`): Banner ANSI colorido para cada nó
- **nexus-connect** (`~/.local/bin/`): SSH wrapper com banner pré-conexão
- **nexus-fetch** (`~/.local/bin/`): Fastfetch wrapper
- **nexus-prompt.zsh** (`~/.config/`): Header colorido no prompt do ZSH (cor do nó)
- **Starship**: Config atualizada — prompt Gruvbox restaurado, sem módulos custom problemáticos
- **Fastfetch**: Config com tema verde
- **Aliases ZSH**: `to-pris`, `to-valis`, `to-deckard`, `to-roy` adicionados ao `.zshrc`

**4. Nexus Logos**
- Coleção de ícones encontrada em `/mnt/almox/JD/30-39 Tech Development/04_Specific_Projects/Nexus_Logos/`
- Ícones para NEXUS, UBIK, PRIS, VALIS, DECKARD, BEETHOVEN em SVG/PNG/JPG

**5. Second Brain**
- Template `Daily Note.md` simplificado: queries de tasks removidas (overwhelming)
- Daily de 2026-05-27 populada com o resumo do dia

### 📊 Resultado
- ✅ Google Workspace funcional no UBIK
- ✅ Nicole com plano + apresentação + logs completos (Aulas 09, 10, 11)
- ✅ Bruna onboarding completo (perfil + plano + apresentação)
- ✅ Scripts de identidade visual do Nexus criados e funcionais
- ✅ Terminal com header colorido por nó
- ✅ Nexus Logos catalogados
- ✅ Second Brain daily + template limpos

### 🔜 Próximos passos
- Refinar identidade visual nos apps (Wofi, tmux, nexus-doctor, avatars por nó)
- Discutir com Marcel a visão completa do que ele quer

---

*Assinado: Joi, Agente Nexus.*

## 📅 2026-05-29 — Hindsight LTM Híbrido (PRIS + UBIK)

### Contexto
A Joi (agente Hermes no UBIK) não tinha acesso prático ao Hindsight (memória de longo prazo). O banco `memory_store.db` existe apenas na PRIS, e o UBIK só recebia um resumo diário via `HINDSIGHT_HIGHLIGHTS.md`.

### ✅ Ações Realizadas

1. **Diagnóstico:**
   - Confirmado que `memory_store.db` (SQLite, 17 fatos) existe apenas na PRIS (`{{TAILSCALE_IP_PRIS}}`)
   - Schema: tabela `facts` com FTS5, campos `content`, `category`, `trust_score`, `tags`, `hrr_vector`
   - UBIK não tem banco local — `HINDSIGHT_HIGHLIGHTS.md` é o único cache

2. **Script de consulta criado:**
   - `~/.hermes/scripts/hindsight.sh` — shell script que consulta o Hindsight da PRIS via SSH
   - 5 comandos: `query`, `recent`, `category`, `count`, `add`
   - Exemplos:
     ```bash
     hindsight.sh query "Tuya"       # busca textual
     hindsight.sh recent 5            # últimos 5 fatos
     hindsight.sh category user_pref  # filtro por categoria
     hindsight.sh count               # contagem por categoria
     hindsight.sh add "texto novo"    # adicionar fato
     ```

3. **Estratégia Híbrida definida:**
   - **Cache local (rápido):** `HINDSIGHT_HIGHLIGHTS.md` — fatos de alto valor sincronizados via Syncthing diariamente (05:00, cron da PRIS)
   - **LTM completa (profunda):** Consultas SQL via SSH na PRIS quando necessário
   - **MEMORY.md:** Mantido como bloco compacto de ~2.200 chars para fatos sempre-disponíveis

### 📊 Resultado
- ✅ Consulta funcional: `hindsight.sh query "Joi"` retorna 5 fatos em < 1s
- ✅ Cache local com 17 fatos sincronizados
- ✅ Script documentado e versionado em `~/.hermes/scripts/`
- ✅ MEMORY.md consolidado (95% de uso — 2.108/2.200 chars)

### 🔜 Próximo passo
- Considerar instalação do Hindsight no UBIK (modo `local_embedded`) se a latência SSH se tornar um gargalo

---

*Assinado: Joi, Agente Nexus.*

## 📅 2026-05-29 — Hindsight LTM Híbrido (PRIS + UBIK)

### Contexto
A Joi (agente Hermes no UBIK) não tinha acesso prático ao Hindsight (memória de longo prazo). O banco `memory_store.db` existe apenas na PRIS, e o UBIK só recebia um resumo diário via `HINDSIGHT_HIGHLIGHTS.md`.

### ✅ Ações Realizadas

1. **Diagnóstico:**
   - Confirmado que `memory_store.db` (SQLite, 17 fatos) existe apenas na PRIS (`{{TAILSCALE_IP_PRIS}}`)
   - Schema: tabela `facts` com FTS5, campos `content`, `category`, `trust_score`, `tags`, `hrr_vector`
   - UBIK não tem banco local — `HINDSIGHT_HIGHLIGHTS.md` é o único cache

2. **Script de consulta criado:**
   - `~/.hermes/scripts/hindsight.sh` — shell script que consulta o Hindsight da PRIS via SSH
   - 5 comandos: `query`, `recent`, `category`, `count`, `add`
   - Exemplos:
     ```
     hindsight.sh query "Tuya"       # busca textual
     hindsight.sh recent 5            # últimos 5 fatos
     hindsight.sh category user_pref  # filtro por categoria
     hindsight.sh count               # contagem por categoria
     ```

3. **Estratégia Híbrida definida:**
   - **Cache local (rápido):** `HINDSIGHT_HIGHLIGHTS.md` — fatos de alto valor sincronizados via Syncthing diariamente (05:00, cron da PRIS)
   - **LTM completa (profunda):** Consultas SQL via SSH na PRIS quando necessário
   - **MEMORY.md:** Mantido como bloco compacto de ~2.200 chars para fatos sempre-disponíveis

### 📊 Resultado
- ✅ Consulta funcional: `hindsight.sh query "Joi"` retorna 5 fatos em < 1s
- ✅ Cache local com 17 fatos sincronizados
- ✅ Script versionado em `~/.hermes/scripts/`
- ✅ MEMORY.md consolidado (95% de uso)

### 🔜 Próximo passo
- Considerar instalação do Hindsight no UBIK (modo `local_embedded`) se a latência SSH se tornar um gargalo

---

*Assinado: Joi, Agente Nexus.*

## 📅 2026-05-29 — AVA Uniasselvi + Hindsight LTM Híbrido + Preço Zaffari

### Contexto
Três frentes avançadas: (1) acesso ao AVA da faculdade para estudos, (2) LTM funcional via Hindsight na PRIS, (3) consulta de preços em supermercados.

### ✅ Ações Realizadas

**1. AVA Uniasselvi — Acesso total**
- Login automatizado com Playwright (2-step: CPF → senha → seleção de curso)
- Dashboard: `ava2.uniasselvi.com.br`
- Disciplinas 2026/1 mapeadas: Estrutura de Dados, Banco de Dados, Linguagens de Programação, Empreendedorismo Criativo, Imersão Profissional: Projeto de Banco de Dados
- Credenciais salvas em `~/.hermes/config.yaml` (CPF com dois zeros iniciais como string)

**2. Hindsight LTM Híbrido**
- Script `~/.hermes/scripts/hindsight.sh` criado para consultar o `memory_store.db` da PRIS via SSH
- 5 comandos: `query`, `recent`, `category`, `count`, `add`
- Cache local via `HINDSIGHT_HIGHLIGHTS.md` (17 fatos, sincronizado diariamente 05h)
- MEMORY.md consolidado (95% de uso)

**3. Preço Zaffari**
- Playwright consulta site do Zaffari — Coca-Cola 2L: R$10,99
- Aviso enviado à Estefani no grupo Telegram

### 📊 Resultado
- ✅ AVA funcional — Joi pode consultar notas, calendário, materiais e links de aulas
- ✅ LTM híbrido funcionando — consultas à PRIS em < 1s
- ✅ Script hindsight.sh versionado e funcional
- ✅ Daily note atualizada

### 🔜 Próximos passos
- Usar AVA para alimentar fluxo de estudos (aula gravada → resumo → Second Brain)
- Depois do AV3: resolver Tuya/HA + planejar projeto IIVA

---

*Assinado: Joi, Agente Nexus.*

## 📅 2026-05-29 — Trakt.tv API + DMM Torbox + Watchlist Analysis + Marcel's Film Profile

### Contexto
Marcel perguntou se Joi consegue interagir com o Trakt.tv dele, que tem 2.453 filmes assistidos. Em seguida, pediu verificação de disponibilidade no Torbox via DMM.

### ✅ Ações Realizadas

**1. Trakt.tv — Script de consulta em tempo real**
- Criado `~/.hermes/scripts/trakt.sh` com 5 comandos:
  - `recente [N]` — últimos N filmes vistos
  - `buscar <termo>` — busca na API do Trakt
  - `stats` — estatísticas da conta
  - `watchlist [N]` — ver watchlist
  - `recomendar` — sugestão (precisa refinamento)
- API pública do Trakt funciona sem token (só client_id)
- Testado: stats (2.453 filmes, 574 séries), busca ("Matrix" retornou 10 resultados)

**2. Watchlist analisada (14 filmes)**
- Destaques: Saccharine ⭐7.8, Teenage Sex and Death at Camp Miasma ⭐8.0, Obsession ⭐8.2
- Clássicos: Tekkonkinkreet (2006), Cannibal Holocaust (1980)
- Maioria dos 2026 ainda só nos cinemas

**3. Torbox — API registrada**
- Chave: `38b5f10c-3c85-44ca-8830-11f51113043f`
- API responde para `/user/me` mas retorna 403 para operações de torrent/search
- DMM testado: login via API key retorna 403 (plano 1 não inclui API de busca)
- Zen browser do Marcel tem sessão DMM ativa, mas sem porta de debug remoto

**4. Perfil cinematográfico de Marcel registrado no Hindsight**
- Clássicos: Blade Runner, Alien, Exorcista, Bebê de Rosemary
- Diretores: Carpenter, Spielberg (1977-1999), Kubrick, Hitchcock
- Gêneros: horror cósmico, afrossurrealismo (Peele, Riley, Glover), body horror, female body horror
- Preferência: só assiste filmes com release digital/físico (nada de cam rip)
- Já viu a maioria dos filmes cult recomendados (Hereditary, Midsommar, The Lighthouse, The Substance)

### 📊 Resultado
- ✅ Trakt consultável em tempo real
- ✅ Watchlist mapeada (14 filmes)
- ✅ Perfil de gosto salvo no Hindsight
- 🟡 Torbox API limitada pelo plano — pendente verificar upgrade ou usar sessão DMM do navegador

---

*Assinado: Joi, Agente Nexus.*

## 📅 2026-06-06 — ROY: Verificação de Wake-on-LAN

### ✅ Ações Realizadas:
1. Verificado WoL no ROY (Dell Inspiron 14, LibreELEC 12.2.1) via SSH
2. `ethtool eth0`: suporta `pumbg`, ativado `g` (Magic Packet) — **WoL operacional**
3. Constatado que ROY está conectado via Wi-Fi (`wlan0`), ethernet desconectado (`NO-CARRIER`)
4. Documentado em `01_INFRA/hardware.md` — seção ROY com detalhes de WoL e limitação do Wi-Fi

### 📂 Arquivos Alterados:
- `/mnt/almox/JD/00-09 System/05 Architecture/Nexus-Docs/01_INFRA/hardware.md` — nova seção ROY com WoL

### ⚠️ Observação:
WoL requer cabo ethernet conectado. Não funciona via Wi-Fi. Se quiser usar no futuro, conectar ROY por cabo.

---

*Assinado: Joi, Agente Nexus.*

---

## 📅 2026-06-13/14 — IIVA Database: Deploy VALIS + SyncThing Fix + Fluxo Completo

### ✅ Ações Realizadas:

1. **`requirements.txt` criado** — dependências congeladas (fastapi, uvicorn, watchdog, pyyaml, python-dotenv)
2. **`.gitignore` criado** — protegendo `iiva.db`, `.env`, `venv/`, `__pycache__/`
3. **`git init`** — primeiro commit na `main` (13 arquivos), branch `develop` criada
4. **Arquivos de exemplo criados** — `examples/perfil-modelo.md`, `examples/aula-modelo.md`, `examples/log-modelo.md`, `examples/INTEGRATION.md`, `.env.example`
5. **Domínio `{{PERSONAL_DOMAIN}}` comprado** na Hostinger (R$6/ano). Subdomínios planejados: `git.{{PERSONAL_DOMAIN}}` → Forgejo, `blog.{{PERSONAL_DOMAIN}}` → blog, raiz → landing page
6. **Análise de MVP documentada** no Second Brain — o que temos já é funcional, financeiro e materiais não travam

### 🚀 Deploy no VALIS

- **Projeto copiado** via rsync do UBIK para `~/docker/iiva/` no VALIS
- **VenV recriado** no VALIS (caminhos do UBIK não funcionavam) + dependências instaladas
- **Systemd `iiva-api.service`** criado — API FastAPI rodando 24/7 na porta 8000, restart automático
- **Systemd `iiva-watcher.service`** criado — file watcher monitorando o vault, restart automático
- **`PYTHONUNBUFFERED=1`** adicionado ao watcher para logs em tempo real

### 🔧 Correções Aplicadas

**SyncThing — Caminho errado:**
O SyncThing no UBIK monitorava `.../21 Idioma Independente/21.01 Alunos` (antigo) em vez de `.../IIVA-classes/21.01 Alunos` (atual). Corrigido via API REST do SyncThing (chave em `~/.local/state/syncthing/config.xml`).

**Update DB — Encoding corrompido do `í`:**
Múltiplas substituições corromperam o encoding do `í` na coluna `nível`. Solução: renomeada a coluna no banco para `nivel` (sem acento) e corrigidas as queries SQL no código. Cache Python limpo.

**Watcher — Regex não aceitava logs:**
O regex só parseava `_Aula_NN_`, ignorando `_Log_Aula_NN_`. Corrigido para `(\d{4}-\d{2}-\d{2})_?(?:Log_)?Aula_(\d+)_`.

### ✅ Teste de Fluxo Completo — VALIDADO

1. **Edição no UBIK** — adicionada nota "Jairo está em Fortaleza" no `Perfil_Jairo.md`
2. **SyncThing** — sincronizou o arquivo para o VALIS
3. **Watcher** — detectou `📝 Modificado: .../Jairo/Perfil_Jairo.md`
4. **Banco** — atualizado: `✅ Aluno atualizado: Jairo`
5. **API** — `curl localhost:8000/alunos` → 19 alunos respondendo

### 📂 Arquivos Criados/Alterados:

**UBIK (`~/Projects/IIVA/`):** `.env.example`, `.gitignore`, `requirements.txt`, `examples/perfil-modelo.md`, `examples/aula-modelo.md`, `examples/log-modelo.md`, `examples/INTEGRATION.md`

**VALIS (`~/docker/iiva/`):** `main.py`, `watcher.py`, `update_db.py`, `iiva.db` (19 alunos, 257 aulas)

**VALIS (systemd):** `iiva-api.service` (porta 8000), `iiva-watcher.service`, `iiva-watcher.service.d/env.conf`

**Second Brain:** `30_Projects/{{PERSONAL_DOMAIN}} - Portfolio.md`, `40_Life/Dividas Tecnicas/2026-06-12 VALIS - Diagnostico.md` (atualizado com plano de migração)

### 📊 Status Final

| Serviço | Local | Status |
|---------|-------|--------|
| API IIVA | VALIS:8000 | ✅ Rodando, 19 alunos |
| Watcher | VALIS | ✅ Monitorando vault |
| SyncThing | UBIK ↔ VALIS | ✅ Caminho corrigido |
| Git | UBIK (`main`) | ✅ Primeiro commit |
|| Domínio | Hostinger | ✅ `{{PERSONAL_DOMAIN}}`

---

## 📅 2026-06-22 — Nexus Docs: DRY Restructuring (VALIS)

### ✅ Ações Realizadas:

1. **`01_INFRA/valis.md` criado** — Fonte única sobre o node VALIS
   - Hardware real (Lenovo ideapad 330-15IKB, RAM 4GB, SSD 914G + HD externo 916G)
   - Todos os serviços rodando: 13 containers (incluindo Hoarder e Qdrant — não documentados antes)
   - Serviços removidos: NPM (parado), Ocular e Watchtower (removidos)
   - Cloudflare tunnels atualizados (removidas rotas da stack Buster extinta)
   - HD externo `/home/{{LINUX_USER}}/mnt_externo` documentado (backups, media, downloads)

2. **`01_INFRA/hardware.md` atualizado** — Tabela resumo com wikilinks para docs dos nós (DRY)

3. **`01_INFRA/network.md` atualizado** — Topologia referenciando docs dos nós; rotas Cloudflare corrigidas

4. **`01_INFRA/docker_stack.md` reestruturado** — Mapa de portas em uso (DRY: sem duplicar serviços)

5. **`40_Life/Dividas Tecnicas/2026-06-12 VALIS - Diagnostico.md` limpo** — Dados de infra removidos (agora em valis.md); mantido apenas plano de migração IIVA

6. **`00_INDEX.md` atualizado** — Adicionada entrada para valis.md, PRIS e UBIK como (a criar)

7. **`AGENTS.md` atualizado** — Seção Infrastructure Reference com coluna Doc e DRY notice

### 🔄 Pendente:
- [ ] Criar `pris.md`, `ubik.md`, `roy.md` (mesmo padrão DRY)
- [ ] Limpar rotas Cloudflare obsoletas no dashboard
- [ ] Configurar DNS `valis.home` para resolver do UBIK

*Assinado: Joi, Agente Nexus.*

---

## 📅 2026-06-22 — PRIS doc criado (DRY)

### ✅ Ações Realizadas:

1. **`01_INFRA/pris.md` criado** — Fonte única do node PRIS
   - Hardware: Samsung 270E5K, i5-5200U, 8GB RAM, SSD 223G + HD 916G (/mnt/storage)
   - 4 containers Docker: n8n, Home Assistant, Syncthing, Open WebUI (JOI)
   - 3 processos nativos: Hermes Gateway (:9099), Dashboard (:9119), PostgreSQL (:5432)
   - Odysseus inativo (dados ainda presentes em ~/docker/odysseus/)
   - /mnt/storage documentado (JD root, media, docker volumes)

2. **hardware.md, network.md, docker_stack.md, 00_INDEX.md, AGENTS.md** — wikilinks atualizados para pris.md

---

## 📅 2026-06-22 — ROY doc criado (DRY)

### ✅ Ações Realizadas:

1. **`01_INFRA/roy.md` criado** — Fonte única do node ROY
   - Dell Inspiron 5447, i5-4210U, 4GB RAM, HDD 914.8 GB (911 GB livres)
   - LibreELEC 12.2.1 (Omega) + Kodi 21.x
   - Addons documentados: POV 6.05.12, Umbrella, Trakt, YouTube, Otaku, OpenSubtitles, SponsorBlock
   - Skin: Arctic Zephyr 2 Resurrection Mod
   - Rede: Wi-Fi apenas, sem Tailscale

2. **hardware.md, network.md, docker_stack.md, 00_INDEX.md** — wikilinks atualizados para roy.md

---

## 📅 2026-06-22 — DECKARD doc criado (DRY)

### ✅ Ações Realizadas:

1. **`01_INFRA/deckard.md` criado** — Fonte única do node DECKARD
   - Compaq Presario CQ-17, Celeron N3350, 4GB RAM, SSD 464GB (2% usado)
   - Fedora 44 (Sway), sem Docker, sem containers
   - Online via Tailscale ({{TAILSCALE_IP_DECKARD}}) — descoberto online, ping/SSH respondendo
   - Uptime 18 dias — Syncthing ativo

2. **hardware.md, network.md, docker_stack.md, 00_INDEX.md, AGENTS.md** — wikilinks atualizados para deckard.md
   - hardware.md: corrigido OS de "Linux Mint" para "Fedora 44 Sway"
   - hardware.md: corrigida nota de "offline 17d" para "online via Tailscale"

---

## 📅 2026-06-22 — UBIK doc criado (DRY)

### ✅ Ações Realizadas:

1. **`01_INFRA/ubik.md` criado** — Fonte única do node UBIK
   - PCWare A320G, Ryzen 3 3200G, 13 GB RAM, RX 550 + Vega 8
   - Armazenamento: SSD sistema (79%), SSD home (84%), HDD Almox (52%)
   - 1 container (Open WebUI) + Ollama local (5 modelos) + Obsidian API
   - Syncthing inativo no UBIK

2. **hardware.md, network.md, docker_stack.md, 00_INDEX.md, AGENTS.md** — wikilinks atualizados
   - RAM corrigida de 14 GB para 13 GB
   - Todos os "(a criar)" substituídos por wikilinks reais — estrutura DRY completa

---

## 📅 2026-06-22 — DNS .home resolvido e network.md finalizado

### ✅ Ações Realizadas:

1. **DNS local configurado** — Pi-hole no VALIS não tinha registros `.home`. Resolvido:
   - Habilitado `etc_dnsmasq_d = true` no `pihole.toml`
   - Criado `/etc/dnsmasq.d/nexus-hosts.conf` com registros para valis, pris, ubik, roy, deckard, ha, n8n, git
   - Container pihole reiniciado
   - ✅ `valis.home`, `pris.home`, `ubik.home`, `roy.home`, `deckard.home` resolvendo

2. **network.md atualizado** — DNS section refletindo estado atual; Cloudflare cleanup documentado com instruções de acesso ao dashboard (requer login manual — sem API key disponível)

---

## 📅 2026-06-22 — Nexus Docs sanitizados (placeholders)

### ✅ Ações Realizadas:

1. **`00_Nexus/.env.example` criado** — mapeia todas as variáveis sensíveis (IPs Tailscale + LAN, domínios, usuário)

2. **`00_Nexus/.env` criado** com valores reais — no `.gitignore`

3. **Sanitização aplicada em 10 arquivos** — IPs, domínios, paths com username substituídos por `{{VAR_NAME}}`

4. **Placeholders implementados:** `{{TAILSCALE_IP_VALIS}}`, `{{TAILSCALE_IP_PRIS}}`, `{{TAILSCALE_IP_UBIK}}`, `{{TAILSCALE_IP_DECKARD}}`, `{{LAN_IP_VALIS}}`, `{{LAN_IP_PRIS}}`, `{{LAN_IP_UBIK}}`, `{{LAN_IP_ROY}}`, `{{LAN_IP_DECKARD}}`, `{{CLOUDFLARE_DOMAIN}}`, `{{PERSONAL_DOMAIN}}`, `{{LINUX_USER}}`, `{{GITHUB_USER}}`

### 🔄 Próximo passo:
Repo pode ser tornado público — nenhum IP real, domínio ou username exposto.
