# 🔄 01.03.01 n8n-mcp: Manual Operacional

| Campo | Valor |
| :--- | :--- |
| **Código** | `01.03.01` |
| **Status** | Operacional |
| **Data** | 2026-04-01 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Introdução e Governança

Este documento descreve o **n8n-mcp**, o servidor MCP que conecta os agentes da Squad Nexus à instância n8n rodando na PRIS. O n8n é a camada de automação de workflows do ecossistema, e o MCP permite que agentes consultem, acionem e monitorem workflows via interface de ferramentas padronizada.

> **Soberania:** O n8n é self-hosted na PRIS. Nenhuma automação crítica depende de serviços externos de orchestration (Zapier, Make, etc.).

> **⚠️ NOTA:** Os containers Radarr, Sonarr, Prowlarr, Bazarr e Recyclarr foram **descontinuados** (pivot ROY para LibreELEC/Kodi, maio/2026). Workflows n8n que interajam com esses serviços estão obsoletos e precisam ser refatorados.

---

## 2. Topologia

### 2.1 Localização do Serviço

| Atributo | Valor |
| :--- | :--- |
| **Nó** | PRIS |
| **IP Tailscale** | `{{TAILSCALE_IP_PRIS}}` |
| **Porta** | `5678` |
| **Container** | `n8n` (Docker Engine) |
| **URL Interna** | `http://{{TAILSCALE_IP_PRIS}}:5678` |
| **URL MCP Endpoint** | `http://{{TAILSCALE_IP_PRIS}}:5678/mcp-server/http` |

### 2.2 Fluxo de Conexão MCP

```
[Agente Opencode]
       │
       │  (supergateway bridge)
       ▼
[n8n-mcp MCP Server]  ← npx supergateway --streamableHttp
       │
       │  (HTTP Streamable)
       ▼
[n8n API]  ← http://{{TAILSCALE_IP_PRIS}}:5678/mcp-server/http
       │
       ▼
[Workflows n8n]
```

### 2.3 Agentes com Acesso

| Agente | Acesso | Justificativa |
| :--- | :--- | :--- |
| **Engenheiro** | ✅ Leitura/Escrita | Acionar workflows de deploy, CI/CD e automações técnicas |
| **Debugger** | ✅ Leitura | Consultar logs de execução e diagnosticar falhas em workflows |
| **Demais agentes** | ❌ Sem acesso | Fora do escopo de atuação |

---

## 3. Configuração

### 3.1 MCP Server no Opencode

Configuração no `~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "n8n-mcp": {
      "type": "local",
      "command": [
        "npx",
        "supergateway",
        "--streamableHttp",
        "http://{{TAILSCALE_IP_PRIS}}:5678/mcp-server/http"
      ]
    }
  }
}
```

### 3.2 Restrição por Agente (Glob Patterns)

```jsonc
// Engenheiro
{
  "agent": "engenheiro",
  "tools": ["forgejo-nexus_*", "docker-gateway_*", "context7_*", "sequentialthinking_*", "puppeteer_*", "n8n-mcp_*"]
}

// Debugger
{
  "agent": "debugger",
  "tools": ["docker-gateway_*", "homebutler_*", "forgejo-nexus_*", "sequentialthinking_*", "n8n-mcp_*"]
}
```

### 3.3 n8n na PRIS (Docker)

O container n8n na PRIS deve ter o **MCP Server** habilitado nas variáveis de ambiente:

```yaml
# docker-compose.yml (PRIS) — trecho relevante
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    environment:
      - N8N_MCP_SERVER_ENABLED=true
      - N8N_MCP_SERVER_PATH=/mcp-server
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - TZ=America/Sao_Paulo
    ports:
      - "5678:5678"
```

> **Nota:** Se o MCP Server não estiver habilitado no n8n, o `supergateway` falhará com erro de conexão. Verifique com `docker logs n8n | grep -i mcp`.

---

## 4. Protocolos Operacionais

### 4.1 Health Check do n8n-mcp

```bash
# 1. Verificar se o container n8n está rodando na PRIS
ssh marcel@{{TAILSCALE_IP_PRIS}} "docker ps --filter name=n8n --format '{{.Status}}'"

# 2. Verificar se o endpoint MCP responde
curl -s -o /dev/null -w "%{http_code}" http://{{TAILSCALE_IP_PRIS}}:5678/mcp-server/http
# Esperado: 200 ou 405 (MCP usa POST, GET pode retornar 405)

# 3. Verificar logs do n8n para erros de MCP
ssh marcel@{{TAILSCALE_IP_PRIS}} "docker logs n8n 2>&1 | tail -20"
```

### 4.2 Troubleshooting

| Sintoma | Causa Provável | Resolução |
| :--- | :--- | :--- |
| `ECONNREFUSED` no supergateway | Container n8n parado na PRIS | `ssh marcel@{{TAILSCALE_IP_PRIS}} "docker start n8n"` |
| `404 /mcp-server/http` | MCP Server não habilitado no n8n | Adicionar `N8N_MCP_SERVER_ENABLED=true` ao compose |
| Timeout na conexão | Tailscale desconectado na PRIS | `ssh marcel@{{TAILSCALE_IP_PRIS}} "tailscale status"` |
| MCP tools não aparecem no agente | Glob pattern incorreto no opencode.json | Verificar se `n8n-mcp_*` está na lista `tools` do agente |

### 4.3 Migração de IP (Histórico)

- **Antes:** `http://{{LAN_IP_VALIS}}:5678/mcp-server/http` (LAN — frágil, dependente de DHCP)
- **Depois:** `http://{{TAILSCALE_IP_PRIS}}:5678/mcp-server/http` (Tailscale — estável, IP fixo na mesh)
- **Data da correção:** 2026-04-01
- **Motivo:** O n8n roda na PRIS, não no VALIS. O IP LAN apontava para o nó errado.

---

## 5. Integrações Futuras (Backlog)

| Integração | Status | Descrição |
| :--- | :--- | :--- |
| Google Calendar → n8n | 🔵 Backlog | Webhook de novos eventos dispara workflow de preparação de aula (IIVA) |
| Evolution API (WhatsApp) → n8n | 🔵 Backlog | Mensagens recebidas disparam fluxos de atendimento |
| Forgejo Webhook → n8n | 🔵 Backlog | Push para repositório dispara pipeline de deploy/testes |
| Home Assistant → n8n | 🔵 Backlog | Eventos da casa disparam automações complexas |

---

## 6. Histórico de Mudanças

| Data | Autor | Mudança |
| :--- | :--- | :--- |
| 2026-04-01 | Gaff | Documento inicial criado — topologia, config, protocolos |

---

*Assinado: Gaff, Arquiteto Chefe do Ecossistema Nexus.*
