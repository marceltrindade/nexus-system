# BusterFriendlyV3: Roadmap de Implementação

## Fase 1: Estabilização e Auditoria (Atual)
- [x] Mapeamento exato de volumes e links simbólicos na PRIS.
- [x] Identificação do gargalo de I/O e links absolutos quebrados.
- [ ] Planejamento da transição "Nexus Portátil".

## Fase 2: Sanetização da PRIS (Pre-Expansion)
- [ ] Backup de estado dos Arrs (DUMB).
- [ ] Migração de Bind Mounts no Docker: Mudar `/home/{{LINUX_USER}}/media` para `/mnt/storage/media` diretamente.
- [ ] Execução de Scan Total no Jellyfin (Aceite de custo para limpeza de DB).
- [ ] Validação de estabilidade do Zurg com o novo mapeamento.

## Fase 3: Expansão de Hardware
- [ ] Setup físico da Bridge D-Link.
- [ ] Atribuição de IPs estáticos na malha isolada.
- [ ] Inclusão dos Novos Nós no Tailscale (Nexus Mesh).

## Fase 4: Descentralização Funcional
- [ ] Migração do Buster Friendly (Sonarr, Radarr, Decypharr) para os novos nós.
- [ ] Configuração do Servidor NFSv4 na PRIS.
- [ ] Configuração do Syncthing para entrega unidirecional de links simbólicos (Brain -> Muscle).

## Fase 5: Homologação e Operação Final
- [ ] Teste de "Failover": Desligar nós de gestão e validar playback contínuo na PRIS.
- [ ] Otimização de scans do Jellyfin via Webhooks (n8n).
- [ ] Documentação final do "Golden Path" V3.
