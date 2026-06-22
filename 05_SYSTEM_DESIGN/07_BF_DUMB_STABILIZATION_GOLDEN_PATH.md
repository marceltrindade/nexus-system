# 🌟 07_BF_DUMB_STABILIZATION_GOLDEN_PATH: Arquitetura Estável do Buster Friendly V2

| Campo | Valor |
| :--- | :--- |
| **Código** | `07` |
| **Status** | Implementado e Validado |
| **Data** | 2026-04-13 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. O Problema Histórico: FUSE Desync e I/O Duplicado

A stack **DUMB** enfrentava falhas críticas de importação devido a um descompasso triplo entre o Real-Debrid, o Zurg/Rclone e os containers Docker. Os Arrs entravam em estado de pânico (I/O Wait) ao tentar ler links simbólicos mortos ou pastas vazias.

### 1.1 Causas Identificadas no Audit de Abril/2026
1. **Redundância de Mounts:** O DUMB tentava gerenciar um Rclone interno que zumbificava o Kernel da PRIS.
2. **Cegueira de VFS:** O Rclone do Host não recebia o sinal de refresh (`rc_url`) e mantinha arquivos novos invisíveis por 24h.
3. **Links Fantasmas:** A biblioteca continha **313 links mortos** da arquitetura antiga que travavam o scan dos Arrs (Erro `Transport endpoint not connected`).
4. **Mismatch de Caminhos:** Jellyfin lia links em `/home/{{LINUX_USER}}/media` enquanto Arrs escreviam no caminho físico `/mnt/storage/media`.

---

## 2. A Solução Definitiva (O Caminho de Ouro)

### 2.1 Unificação de Visão (Conformidade com o Jellyfin)
Todos os containers (Jellyfin e DUMB) agora utilizam **links simbólicos universais** do host para garantir que o que o Arr escreve seja exatamente o que o Jellyfin lê.
*   **Bind Mount:** `- /home/{{LINUX_USER}}/media:/media:rw,rslave`
*   **Regra de Ouro:** Nunca usar caminhos absolutos de disco físico (`/mnt/storage`) dentro dos containers.

### 2.2 O Sistema Healer (Orientado a Eventos)
Implementado o serviço **`nexus-dumb-healer.sh`** via `inotifywait`.
*   **Função:** Monitora a criação de pastas pelo Decypharr. Se o Decypharr falhar em criar o link (bug de string), o Healer localiza o arquivo no Zurg e injeta o symlink manualmente usando o prefixo universal `/zurg/__all__`.
*   **Vantagem:** Elimina o delay humano e o polling do cron.

### 2.3 Comunicação em Tempo Real
A chave mestra da estabilidade foi configurar o Decypharr para "acordar" o Rclone do Host:
*   **Config:** `rc_url: "http://{{TAILSCALE_IP_PRIS}}:5572"`
*   **Fluxo:** Download Fim -> Sinal HTTP -> Refresh de Cache -> Arquivo Materializado.

---

## 3. Protocolos de Manutenção

### 3.1 Protocolo de Boot (Buster Friendly v2.0)
Em caso de reboot ou queda de energia:
1. Reiniciar `zurg-app.service` e `zurg.service`.
2. **Aguardar 15 minutos (Warm-up)** sem tocar no disco.
3. Reiniciar `jellyfin`. Se o Jellyfin travar no boot, limpar a pasta de logs em `/config/log/`.

### 3.2 Limpeza de Fantasmas
Sempre que houver troca massiva de infraestrutura, rodar a limpeza de links mortos:
`find /mnt/storage/media -type l ! -exec test -e {} \; -delete`

---
*Assinado: Gaff, Zelador de Infraestrutura.*