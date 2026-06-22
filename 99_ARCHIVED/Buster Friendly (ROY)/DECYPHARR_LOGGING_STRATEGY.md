# 🧠 DECYPHARR LOGGING STRATEGY

## Objetivo

Criar e manter sistema de logs persistente para monitoramento do serviço Decypharr, garantindo observabilidade completa do pipeline de Debrid.

---

## Ambiente

| Componente | Detalhe |
| :--- | :--- |
| Host | Ubuntu Server (ROY) |
| Usuário | marcel |
| Serviço | Decypharr via systemd |
| Binário | `/home/{{LINUX_USER}}/decypharr` |
| Config | `/home/{{LINUX_USER}}/decypharr-config/config.json` |
| Porta | 8282 |
|Fonte logs primária | `journalctl -u decypharr` |

---

## Estado Atual (FUNCIONANDO)

- Serviço ativo via systemd
- Porta 8282 respondendo HTTP
- UI acessível
- Processo estável
- Restart automático ativo
- Nenhum container Docker interferindo

---

## Histórico Relevante

| Data |.Evento | Solução |
| :--- | :--- | :--- |
|—| Docker Compose falhava com exit code 135 | Migrar para systemd |
|—| Processo morria sem logs visíveis | Uso de journalctl |
|—| docker run funcionava | Diferença de runtime |

---

## Fontes de Logs

### 1. journalctl (primária)

```bash
journalctl -u decypharr -f --since "1h ago"
```

### 2. Arquivos persistentes (estratégia)

| Caminho | Descrição |
| :--- | :--- |
| `/var/log/decypharr/app.log` | Logs da aplicação (quando configurado) |
| `/var/log/decypharr/errors.log` | Erros extraídos |
| `/var/log/decypharr/health.json` | Health checks periódicos |

---

## Níveis de Log

| Nível | Quando usar |
| :--- | :--- |
| INFO | Startup, bind de porta, sync inicial, jobs agendados |
| WARN | Rate limits, Warnings de API, comportamento inesperado |
| ERROR | Falhas de bind, falhas de API, exceções não tratadas |
| DEBUG | Requests HTTP, detalhes do pipeline (opcional) |

---

## Eventos a Monitorar

### 1. Inicialização

- [ ] Startup do serviço
- [ ] Carregamento de config
- [ ] Bind da porta 8282
- [ ] Inicialização do manager

### 2. HTTP

- [ ] Falhas de bind (address already in use)
- [ ] Requests recebidos (nível debug)

### 3. Manager / Pipeline

- [ ] Sync inicial de torrents
- [ ] Processamento de torrents
- [ ] Jobs agendados (queue, refresh, etc)

### 4. Integração com Real-Debrid

- [ ] Falhas de API
- [ ] Mensagens: "Failed to process torrent ... giving up after 4 attempt(s)"
- [ ] Rate limits detectados

### 5. Shutdown / Restart

- [ ] Encerramento gracioso
- [ ] Restart automático (systemd)
- [ ] Crashes (se ocorrerem)

---

## Estratégia de Extração

### Extração manual para arquivo

```bash
journalctl -u decypharr --since "24h ago" --no-pager > /var/log/decypharr/dump-$(date +%Y%m%d).log
```

### Extração de erros

```bash
journalctl -u decypharr -p err --since "week ago" --no-picker > /var/log/decypharr/errors-$(date +%Y%m%d).log
```

### Rotação automática

Adicionar ao `/etc/logrotate.d/decypharr`:

```
/var/log/decypharr/*.log
/var/log/decypharr/*.json {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 0644 marcel marcel
}
```

---

## Alertas Configuráveis

| Condição | Ação recomendada |
| :--- | :--- |
| 3+ erros em 5min | Notificar via webhook/n8n |
| "Port already in use" | Verificar processo conflitante |
| 10+ tentativas em 1 torrent | Verificar API do Real-Debrid |
| Processo terminado inesperadamente | Verificar logs de crash |

---

## Health Check

```bash
curl -s http://127.0.0.1:8282/healthz
```

Verificar status: 200 = OK, qualquer outro = investigar.

---

## Restore / Backup

```bash
mkdir -p /mnt/backup/logs/decypharr
tar czvf decypharr-logs-$(date +%Y%m%d).tgz /var/log/decypharr/*.log
```

---

## O Que NÃO Fazer

- NÃO alterar configuração do Decypharr
- NÃO alterar systemd unit
- NÃO reiniciar serviço automaticamente
- NÃO mexer em outros serviços (Radarr/Sonarr/Bazarr/Prowlarr)

---

## Objetivo Final

Sistema de logs que permita:

- Diagnosticar problemas rapidamente
- Entender comportamento do pipeline
- Monitorar estabilidade ao longo do tempo
- Apoiar troubleshooting futuro

---

*Doc gerado em 2026-04-28 via opencode*