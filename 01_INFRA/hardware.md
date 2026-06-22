# 🏗️ Hardware (Nexus Nodes)

> Tabela resumo — cada nó tem seu documento dedicado como fonte única.
> **DRY:** Especificações detalhadas → no documento de cada nó.

## Tabela de Nós

| Node | Modelo | CPU | RAM | GPU | Papel | Doc |
|------|--------|-----|-----|-----|------|-----|
| **UBIK** | Custom Desktop (PCWare A320G) | Ryzen 3 3200G | 14 GB (13 GB utilizáveis) | RX 550 + Vega 8 | Workstation principal | [[00_Nexus/01_INFRA/ubik]] |
| **VALIS** | Lenovo ideapad 330-15IKB | i3-7020U | 4 GB | Intel HD 620 | Infraestrutura & Serviços | [[00_Nexus/01_INFRA/valis]] |
| **PRIS** | Samsung Laptop | Intel Core i5-5200U | 8 GB | NVIDIA 920M | Automação (n8n, HA, Hermes) | [[00_Nexus/01_INFRA/pris]] |
| **ROY** | Dell Inspiron 5447 | Intel Core i5-4210U | 4 GB | Radeon R7 M260 | Kodi Media Center (LibreELEC) | [[00_Nexus/01_INFRA/roy]] |
| **BEETHOVEN** | Workstation | Ryzen 3 3200G | 16 GB | Vega 8 | Design Editorial (Tefa) | — |
| **DECKARD** | Presario CQ17 | Intel Celeron N3350 | 4 GB | HD Graphics 500 | Fallback (Fedora 44 Sway) | [[00_Nexus/01_INFRA/deckard]] |
| **RACHEL** | Positivo | i3-2310M | 4 GB | HD Graphics 3000 | Fallback & Retro | — |
| **A71** | Samsung Galaxy A71 | Snapdragon 730 | 6 GB | Adreno 618 | Offline (futura interface Nexus) | — |

## Notas

- **ROY:** Wake-on-LAN ativado via `eth0`. Não funciona via Wi-Fi. Atualmente conectado por Wi-Fi, cabo ethernet desconectado.
- **BEETHOVEN:** Máquina da Estefani — sem Tailscale.
- **DECKARD:** Fedora 44 (Sway) — online via Tailscale (IP `{{TAILSCALE_IP_DECKARD}}`). Sem Docker, 464GB SSD (2% usado).
- **VALIS:** Possui HD externo de 916 GB montado em `/home/{{LINUX_USER}}/mnt_externo` para backups e mídia. `4 GB RAM` refere-se ao módulo físico; 3.7 GiB disponíveis no sistema.
- **UBIK:** SSDs quase cheios — sistema 79% (24 GB livres), home 84% (36 GB livres). HDD Almox 52% (423 GB livres).
