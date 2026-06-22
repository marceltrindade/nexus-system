# 🔎 13_DUMB_PHASE_A_DISCOVERY: Descoberta Técnica da Produção na PRIS

| Campo | Valor |
| :--- | :--- |
| **Código** | `13` |
| **Status** | Fase A concluída |
| **Data** | 2026-04-02 |
| **Autor** | Gaff (Arquiteto) |
| **Revisor** | Marcel Trindade |

---

## 1. Objetivo

Levantar, em modo estritamente read-only, a topologia real da stack de mídia em produção na PRIS para preparar a migração controlada para o DUMB.

---

## 2. Escopo Inspecionado

- containers ativos da stack de mídia
- `docker-compose.yml` da stack principal, automação e download
- mounts críticos de mídia
- root folders de Radarr e Sonarr
- download clients atuais
- bibliotecas configuradas no Jellyfin
- contrato atual de symlinks e targets

---

## 3. Estado Atual dos Containers

### 3.1 Produção Ativa

| Container | Papel | Estado |
| :--- | :--- | :--- |
| `jellyfin` | streaming | Up |
| `radarr` | filmes | Up |
| `sonarr` | séries | Up |
| `prowlarr` | indexers | Up |
| `decypharr-radarr` | bridge RD / filmes | Up |
| `decypharr-sonarr` | bridge RD / séries | Up |
| `rdtclient` | alternativa de download | Up |

### 3.2 Homologação Isolada

| Container | Papel | Estado |
| :--- | :--- | :--- |
| `dumb-test` | homologação DUMB | Up (healthy) |

### 3.3 Observação Topológica

A produção atual e a homologação DUMB estão coexistindo no mesmo host, sem substituição ainda da stack principal.

---

## 4. Topologia de Compose

### 4.1 Stack Principal (`/home/{{LINUX_USER}}/docker/media/docker-compose.yml`)

O `jellyfin` monta:

- `/home/{{LINUX_USER}}/media/zurg` em `/zurg`
- `/home/{{LINUX_USER}}/media/movies` em `/media/movies`
- `/home/{{LINUX_USER}}/media/shows` em `/media/shows`

### 4.2 Stack de Automação (`/home/{{LINUX_USER}}/docker/media/automation/docker-compose.yml`)

O `radarr` e o `sonarr` montam:

- `/home/{{LINUX_USER}}/media` em `/media`
- `/home/{{LINUX_USER}}/media/downloads` em `/downloads`
- `/home/{{LINUX_USER}}/media/zurg` em `/zurg`
- `/mnt/storage/media` em `/mnt/storage/media`

O `prowlarr` usa `/home/{{LINUX_USER}}/docker/media/config/prowlarr` em `/config`.

### 4.3 Stack de Download (`/home/{{LINUX_USER}}/docker/media/download/docker-compose.yml`)

Os dois serviços Decypharr montam:

- `${MEDIA_DEST}/zurg` em `/zurg`
- `${MEDIA_DEST}/downloads` em `/downloads`

`RDTClient` também usa o mesmo mount do `zurg` e da pasta de downloads.

---

## 5. Contrato Atual de Paths

### 5.1 Mapa Canônico

| Caminho lógico no container | Caminho no host | Destino real |
| :--- | :--- | :--- |
| `/media/movies` | `/home/{{LINUX_USER}}/media/movies` | `/mnt/storage/media/movies` |
| `/media/shows` | `/home/{{LINUX_USER}}/media/shows` | `/mnt/storage/media/shows` |
| `/zurg` | `/home/{{LINUX_USER}}/media/zurg` | mount `fuse.rclone` |

### 5.2 Evidência no Host

- `/home/{{LINUX_USER}}/media/movies` é **symlink** para `/mnt/storage/media/movies`
- `/home/{{LINUX_USER}}/media/shows` é **symlink** para `/mnt/storage/media/shows`
- `/home/{{LINUX_USER}}/media/zurg` é mount `fuse.rclone`

### 5.3 Implicação Arquitetural

O **contrato real da biblioteca** consumida pelo Jellyfin não é `/zurg`, mas sim o conteúdo exposto em:

- `/mnt/storage/media/movies`
- `/mnt/storage/media/shows`

Esses paths são o contrato que não pode quebrar durante a migração.

---

## 6. Jellyfin — Bibliotecas Configuradas

### 6.1 Bibliotecas Ativas

Arquivos de configuração do Jellyfin confirmam:

- biblioteca Movies → `/media/movies`
- biblioteca TV Shows → `/media/shows`

### 6.2 Evidências

Arquivos relevantes:

- `data/root/default/Movies/movies.mblink` → `/media/movies`
- `data/root/default/Movies/options.xml` → `<Path>/media/movies</Path>`
- `data/root/default/TV Shows/shows.mblink` → `/media/shows`
- `data/root/default/TV Shows/options.xml` → `<Path>/media/shows</Path>`

### 6.3 Conclusão

O Jellyfin está rigidamente acoplado aos caminhos:

- `/media/movies`
- `/media/shows`

Logo, qualquer migração bem-sucedida precisa preservar esses caminhos visíveis no container do Jellyfin.

---

## 7. Radarr / Sonarr — Root Folders e Download Clients

### 7.1 Root Folders

| Serviço | Root folder |
| :--- | :--- |
| Radarr | `/media/movies/` |
| Sonarr | `/media/shows/` |

### 7.2 Download Clients Atuais

#### Radarr
- `Decypharr RD` → host `decypharr-radarr`, porta `8282`
- `RDTClient` → host `rdtclient`, porta `6500`

#### Sonarr
- `Decypharr RD` → host `decypharr-sonarr`, porta `8283`
- `RDTClient` → host `rdtclient`, porta `6500`

### 7.3 Conclusão

Os Arrs de produção já estão modelados para importar em cima do mesmo contrato lógico usado pelo Jellyfin:

- filmes em `/media/movies/`
- séries em `/media/shows/`

---

## 8. Prowlarr — Integração Atual

### 8.1 Apps Persistidas

O Prowlarr produtivo possui integração funcional com:

- `Sonarr` em `http://sonarr:8989`
- `Radarr` em `http://radarr:7878`

### 8.2 Indexers Atuais

- `Comet` (Cardigann)
- `Torrentio` (Cardigann)
- `MediaFusion` (Torznab)

### 8.3 Conclusão

A sincronização Prowlarr → Arr está operacional na produção atual, diferentemente do comportamento observado no Prowlarr do DUMB durante a homologação.

---

## 9. Padrão Atual de Symlinks da Biblioteca

### 9.1 Filmes

Foi confirmada ampla presença de symlinks em `/mnt/storage/media/movies/...` apontando para dois padrões principais:

- `/home/{{LINUX_USER}}/media/zurg/__all__/...`
- `/home/{{LINUX_USER}}/media/zurg/movies/...`

### 9.2 Séries

Amostra confirmada de série:

`/mnt/storage/media/shows/Bravest Warriors (2012) {imdb-tt2474952}/Season 04/Bravest Warriors (2012) - s04e33.mkv`

target:

`/home/{{LINUX_USER}}/media/zurg/__all__/Bravest Warriors/Bravest.Warriors.s04e33e34.1080p.WEBRip.mkv`

### 9.3 Conclusão

A biblioteca atual não usa um único padrão de target. Ela mistura:

- `__all__`
- subpastas temáticas como `movies`

Isso significa que a migração não deve depender de preservar targets idênticos; ela deve preservar o **path visível da biblioteca** e garantir que os novos targets sejam resolvíveis e estáveis.

---

## 10. Acoplamentos Críticos

### 10.1 Acoplamentos que Não Podem Quebrar

1. Jellyfin → `/media/movies`
2. Jellyfin → `/media/shows`
3. Radarr → `/media/movies/`
4. Sonarr → `/media/shows/`
5. Biblioteca física → `/mnt/storage/media/*`
6. Fonte remota atual → `/home/{{LINUX_USER}}/media/zurg`

### 10.2 Acoplamento Mais Sensível

O ponto mais sensível não é o mount `/zurg` em si, mas a correspondência entre:

- path final da biblioteca
- symlink visível no filesystem
- path que o Jellyfin já indexou

---

## 11. Riscos Concretos para a Migração

1. **Reimportação no Jellyfin** se o path visível mudar
2. **Inconsistência de targets** se o DUMB produzir layout divergente sem `prefix rewrite`
3. **Quebra de séries** se o padrão de symlink não respeitar a granularidade por temporada/episódio
4. **Dependência implícita do `/zurg` atual** em partes da stack ainda não substituídas
5. **Sincronização do Prowlarr do DUMB** ainda não confiável para produção sem estratégia explícita

---

## 12. Conclusão da Fase A

### 12.1 Conclusão Principal

A migração para DUMB é arquiteturalmente viável, mas **não deve ser modelada como troca de origem remota** e sim como **substituição controlada do backend de symlink mantendo o mesmo contrato de biblioteca**.

### 12.2 Regra de Ouro para a Fase B

O objetivo da próxima fase deve ser:

> preservar `/media/movies` e `/media/shows` como contrato absoluto, enquanto o DUMB passa a abastecer os symlinks por trás desses caminhos com `symlink repair` e `prefix rewrite`.

### 12.3 Próximo Passo

Executar a **Fase B — Desenho de Compatibilidade**, definindo:

- layout final de symlink
- regra de rewrite
- convivência temporária entre stack antiga e DUMB
- estratégia de cutover sem reimportação no Jellyfin

---
*Assinado: Gaff, Zelador de Infraestrutura.*
