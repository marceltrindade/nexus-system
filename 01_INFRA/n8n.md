# 🌐 01.03.02 n8n: Configuração de Domínio Público

| Campo | Valor |
| :--- | :--- |
| **Código** | `01.03.02` |
| **Status** | Acesso Público Configurado |
| **Data** | 2026-04-01 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Visão Geral

O n8n é a plataforma de automação de workflows do ecossistema Nexus, rodando na PRIS. Este documento descreve a configuração para acesso público via domínio `n8n.{{CLOUDFLARE_DOMAIN}}` usando Cloudflare Zero Trust Tunnel.

---

## 2. Arquitetura

### 2.1 Componentes

| Componente | Papel | Detalhes |
|------------|-------|----------|
| **n8n** | Aplicação principal | Container Docker na PRIS, porta 5678 |
| **Cloudflare Tunnel** | Conexão segura | Serviço `cloudflared-tunnel` na PRIS, rede `proxy_network` |
| **Domínio Público** | Acesso externo | `n8n.{{CLOUDFLARE_DOMAIN}}` → Cloudflare → Tunnel → n8n |

### 2.2 Fluxo de Tráfego

```
[Usuário Externo]
       │
       │  (HTTPS via Cloudflare)
       ▼
[Cloudflare Edge]
       │
       │  (Tunnel via proxy_network)
       ▼
[cloudflared-tunnel]  ← rede proxy_network (IP: 172.20.0.10)
       │
       │  (HTTP via rede Docker)
       ▼
[n8n Container]  ← rede proxy_network (IP: 172.20.0.2)
       │
       │  (HTTP localhost:5678)
       ▼
[n8n Application]
```

### 2.3 Redes Docker

| Rede | Containers | Propósito |
|------|------------|-----------|
| `default` | n8n, homeassistant, filebrowser, syncthing | Isolamento padrão |
| `proxy_network` | n8n, cloudflared-tunnel, jellyfin, rdtclient, jellyseerr, decypharr-* | Compartilhamento para túnel |

> **Nota:** O n8n está conectado a **ambas** as redes para manter compatibilidade com volumes e permitir acesso ao túnel.

---

## 3. Configuração

### 3.1 Variáveis de Ambiente do n8n

Configuradas no `docker-compose.yml` da PRIS:

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    ports:
      - "5678:5678"
    volumes:
      - /mnt/storage/docker/n8n:/home/node/.n8n
    environment:
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - N8N_SECURE_COOKIE=false
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.{{CLOUDFLARE_DOMAIN}}/
      - N8N_EDITOR_BASE_URL=https://n8n.{{CLOUDFLARE_DOMAIN}}/
      - N8N_MCP_SERVER_ENABLED=true
      - N8N_MCP_SERVER_PATH=/mcp-server
    networks:
      - default
      - proxy_network
    restart: always
```

### 3.2 Cloudflare Zero Trust Tunnel

Configurado via **Cloudflare Zero Trust Dashboard**:

1. Acessar: [https://one.dash.cloudflare.com/](https://one.dash.cloudflare.com/)
2. Ir em: **Networks > Tunnels**
3. Selecionar o túnel ativo na PRIS
4. Clicar em: **Public Hostname** → **Add a public hostname**
5. Configurar:
   - **Type:** HTTP
   - **Subdomain:** n8n
   - **Domain:** {{CLOUDFLARE_DOMAIN}}
   - **Service URL:** `http://n8n:5678` (ou `http://172.20.0.2:5678`)

### 3.3 MCP Server

O n8n já tem o MCP Server habilitado via variáveis de ambiente:
- `N8N_MCP_SERVER_ENABLED=true`
- `N8N_MCP_SERVER_PATH=/mcp-server`

Endpoint acessível em: `https://n8n.{{CLOUDFLARE_DOMAIN}}/mcp-server/http`

---

## 4. Validação

### 4.1 Health Check Interno

```bash
# Na PRIS (rede proxy_network)
docker run --rm --network proxy_network alpine sh -c 'wget -qO- --timeout=3 http://n8n:5678/healthz 2>&1'
# Esperado: {"status":"ok"}
```

### 4.2 Acesso Público

```bash
# De qualquer máquina com internet
curl -s -o /dev/null -w "HTTP %{http_code}" https://n8n.{{CLOUDFLARE_DOMAIN}}/
# Esperado: HTTP 200 (ou 302 para login)
```

### 4.3 Endpoint MCP

```bash
# Testar conectividade do MCP
curl -s -o /dev/null -w "HTTP %{http_code}" https://n8n.{{CLOUDFLARE_DOMAIN}}/mcp-server/http -X POST
# Esperado: HTTP 200 (MCP usa POST, GET pode retornar 405)
```

---

## 5. Segurança

### 5.1 Autenticação

- O n8n está configurado com `N8N_SECURE_COOKIE=false` para compatibilidade com túnel
- **Recomendado:** Ativar autenticação básica ou OAuth no n8n após teste inicial
- Alternativa: Usar políticas de acesso no Cloudflare Zero Trust (ex: exigir login do Google)

### 5.2 Exposição

- Apenas a porta 5678 do n8n está exposta via túnel
- Nenhuma outra porta do container é acessível externamente
- O túnel usa autenticação mTLS entre cloudflared e Cloudflare Edge

### 5.3 Rate Limiting

- Recomendado configurar rate limiting no Cloudflare para evitar abuso
- Limite sugerido: 100 requisições/minuto por IP

---

## 6. Workflows Recomendados (Backlog)

| Workflow | Gatilho | Ação |
|----------|---------|------|
| **Forgejo → Notificação** | Push/Issue no Forgejo | Notifica Marcel via Telegram/Discord |
| **Google Calendar → IIVA** | Novo evento "Aula" | Gera template de plano de aula no Almox |
| **Evolution API → Suporte** | Mensagem WhatsApp recebida | Cria ticket no Forgejo |
| **Health Check Cron** | A cada 15min | Ping VALIS/PRIS/UBIK + serviços críticos |

> **⚠️ NOTA SOBRE CONTAINERS:** Os containers Radarr, Sonarr, Prowlarr, Bazarr e Recyclarr estão na stack de **Automação** (`/home/{{LINUX_USER}}/docker/media/automation/docker-compose.yml`), NÃO na stack principal. Qualquer workflow que interaja com esses serviços deve usar o caminho correto.

---

## 7. Pendentes (Configuração do n8n)

| Item | Status | Prioridade |
|------|--------|------------|
| **Workflows** | Nenhum configurado | Alta |
| **Autenticação** | Configuração básica pendente | Alta |
| **Integrações** | Testes de conectividade pendentes | Média |
| **Usuários** | Apenas usuário inicial criado | Média |
| **Backup** | Configuração de backup pendente | Baixa |

---

## 8. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-01 | Gadd | Configuração inicial — domínio público, variáveis de ambiente, rede proxy_network |

---

*Assinado: Gaff, Arquiteto Chefe do Ecossistema Nexus.*
