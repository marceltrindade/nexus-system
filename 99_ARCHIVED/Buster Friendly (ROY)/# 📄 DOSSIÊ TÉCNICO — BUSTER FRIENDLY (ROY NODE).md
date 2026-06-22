
---
## 1. 🎯 OBJETIVO DO PROJETO

Construir uma stack **standalone, limpa e previsível** para automação de mídia usando:

- Real Debrid como storage (via Zurg)
    
- Symlinks locais (via Decypharr)
    
- Stack ARR (Prowlarr, Radarr, Sonarr)
    
- Integração com Jellyfin (em outro node: PRIS)
    

### Princípios:

- ❌ Sem DUMB
    
- ❌ Sem armazenamento local real de mídia
    
- ✔ Arquitetura modular
    
- ✔ Debug simples
    
- ✔ Controle total de paths
    

---

## 2. 🖥️ ARQUITETURA

### Node: ROY (automação)

Responsável por:

- Indexação
    
- Orquestração
    
- Symlink
    
- Interface com Real Debrid
    

### Node: PRIS (media server)

Responsável por:

- Jellyfin
    
- Playback
    
- Interface com usuários
    

---

## 3. 📦 STACK DEFINIDA

### Ordem de inicialização (CRÍTICA)

```text
1. Rclone
2. Zurg
3. Prowlarr
4. Radarr
5. Sonarr
6. Decypharr
7. (Integrações: Jellyseerr, Bazarr)
```

---

## 4. 📁 ESTRUTURA DE DIRETÓRIOS

```bash
/mnt/
  zurg/              # mount Real Debrid (fonte)
  media/
    movies/          # symlinks filmes
    tv/              # symlinks séries

~/docker/buster-friendly/
  docker-compose.yml
  config/
    prowlarr/
    radarr/
    sonarr/
    decypharr/       # (a ser migrado/adaptado)
```

---

## 5. 🔄 FLUXO DE DADOS

```text
Real Debrid API (token)
    ↓
Zurg (localhost:9999)
    ↓
rclone webdav mount (/mnt/zurg)
    ↓
/mnt/zurg/ (__all__, movies, shows, zurg_4k, unsorted)
    ↓
[Próximo] Decypharr → /mnt/media (symlinks)
    ↓
PRIS (Jellyfin via NFS)
```

---

## 6. 💾 ESTADO ATUAL

### ✅ CONCLUÍDO (Fase 1 - 2026-04-26):

- SSH configurado (chave SSH UBIK → ROY)
- Rclone forkado instalado (transferido da PRIS)
- Zurg v0.9.3-final instalado (binário PRIS → ROY)
- Token Real Debrid configurado (mesmo da PRIS)
- Mount /mnt/zurg ativo via rclone webdav
- API Zurg respondendo em localhost:9999
- Sincronização: 4127+ torrents (em_cacheamento)

### 📂 Estrutura no ROY:

```bash
~/zurg/
├── zurg          # Binário Zurg v0.9.3-final
├── rclone       # Rclone forkado
├── config.yml   # Token + config (mount_path: /mnt/zurg)
└── logs/       # Logs de execução

/mnt/zurg/      # Mount point (em cacheamento - ~4127 arquivos)
```

### ⚙️ Status Execução (2026-04-26 01:32 UTC):
- Zurg: PID 61822 - Sincronizando 4127+ torrents
- rclone mount: PID 64137 - cache populando
- API: http://localhost:9999 responding

### ❗ Pendente (Fase 2+):
- Decypharr (migração)
- Correção de paths nos bancos (.db) ⚠️ CRÍTICO
    

---

## 7. ⚠️ PROBLEMA CRÍTICO

Os bancos `.db` (SQLite) contêm paths antigos do DUMB:

Possíveis valores:

```text
/zurg
/media
/mnt/debrid
```

### Novo padrão obrigatório:

```text
/mnt/zurg
/mnt/media
```

### REGRA:

> ❗ NÃO subir containers ARR antes de corrigir os paths nos bancos

---

## 8. 🧠 DADOS A PRESERVAR

Localização original (PRIS):

```bash
/home/{{LINUX_USER}}/docker/dumb-prod/data/
```

Dados relevantes:

```text
prowlarr/default/prowlarr.db
radarr/default/radarr.db
sonarr/default/sonarr.db
```

Status:

- ✔ Copiados para ROY
    
- ✔ Estrutura adaptada para linuxserver
    
- ❗ Ainda não ajustados internamente
    

---

## 9. 🔧 FASES DE IMPLEMENTAÇÃO

---

### 🔹 FASE 1 — RCLONE + ZURG

Objetivo:

- acesso ao Real Debrid
    
- mount funcional em `/mnt/zurg`
    

Requisitos:

- rclone configurado com RD
    
- zurg apontando para backend correto
    

Validação:

```bash
ls /mnt/zurg
```

---

### 🔹 FASE 2 — CORREÇÃO DOS BANCOS

Objetivo:

- substituir paths antigos por novos
    

Arquivos:

```text
prowlarr.db
radarr.db
sonarr.db
```

Ações:

- abrir SQLite
    
- substituir strings de path
    
- validar integridade
    

---

### 🔹 FASE 3 — SUBIDA CONTROLADA

Subir um por vez:

```text
1. Prowlarr
2. Radarr
3. Sonarr
```

Validação por etapa:

- serviço sobe sem erro
    
- UI acessível
    
- configs carregadas corretamente
    

---

### 🔹 FASE 4 — DECYPharr

Objetivo:

- reconectar pipeline de aquisição
    

Ações:

- migrar config do DUMB (se aplicável)
    
- ajustar paths
    
- validar symlink em:
    

```bash
/mnt/media/movies
/mnt/media/tv
```

---

### 🔹 FASE 5 — INTEGRAÇÕES

#### Jellyseerr

- conectar com Radarr/Sonarr
    

#### Bazarr

- conectar com Radarr/Sonarr
    
- paths corretos
    

---

### 🔹 FASE 6 — PRIS (JELLYFIN)

#### Jellyfin

Ações:

- montar NFS de `/mnt/media`
    
- criar novas bibliotecas (invisíveis)
    
- validar scan completo
    
- substituir bibliotecas antigas
    

---

## 10. ⚠️ REGRAS OPERACIONAIS

- ❌ Não executar etapas fora de ordem
    
- ❌ Não subir stack parcialmente configurada
    
- ❌ Não editar DB com containers rodando
    
- ✔ Validar cada fase antes de avançar
    
- ✔ Manter logs observáveis
    

---

## 11. 🧩 RISCOS CONHECIDOS

|Risco|Impacto|Mitigação|
|---|---|---|
|Paths errados no DB|quebra total da stack|corrigir antes de subir|
|Zurg mal configurado|mídia inacessível|validar mount antes|
|Decypharr inconsistente|sem symlinks|validar após subida|
|NFS mal configurado|Jellyfin não vê mídia|testar manualmente|

---

## 12. 📌 ESTADO DESEJADO FINAL

```text
/mnt/zurg        → Real Debrid acessível
/mnt/media       → symlinks funcionando

Prowlarr         → indexers OK
Radarr/Sonarr    → automação OK
Decypharr        → symlinks OK

PRIS             → Jellyfin lendo tudo via NFS
```

---

## 13. 🧭 INSTRUÇÃO PARA AGENTE EXTERNO

Se outro agente assumir:

> NÃO iniciar containers antes de:
> 
> 1. validar Zurg mount
>     
> 2. corrigir paths nos bancos SQLite
>     
> 3. confirmar estrutura `/mnt`
>     

> Trabalhar em modo passo-a-passo, validando cada etapa.

---
