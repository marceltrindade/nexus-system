# BusterFriendlyV3: The Quiet Node Project (Specification)

## 1. Visão Geral
O projeto **BusterFriendlyV3** visa a estabilidade absoluta do ecossistema de mídia do Nexus através da descentralização funcional. O nó **PRIS** deixará de atuar como orquestrador (Brain) e passará a ser um **Cofre de Mídia (Storage Node)** dedicado, focado apenas em playback e gestão de dados.

## 2. Arquitetura de Rede (Nexus Mesh Bridge)
Para eliminar latência e congestionamento no Wi-Fi doméstico, os nós principais serão conectados via malha física isolada:
- **Hardware:** Roteador D-Link (Bridge) + Hub de 2 portas.
- **Topologia:** Conexão direta via cabo entre VALIS, PRIS e os Novos Nós (Brain Nodes).
- **Vantagem:** Tráfego de I/O massivo (Scans, Streaming, Imports) isolado da rede externa.

## 3. Estratégia de Transporte e Sincronização
A entrega de arquivos entre os nós seguirá um modelo de **Isolamento de Falha**:
- **Leitura Massiva (NFSv4):** A PRIS exportará o HDD (`/mnt/storage`) e o Zurg via NFSv4. É o protocolo mais leve para a CPU da PRIS e nativo para os novos nós Linux.
- **Entrega de Ponteiros (Syncthing):** Os novos nós criarão links simbólicos e o Syncthing os entregará na PRIS. Isso garante que, se um nó de gestão cair, o Jellyfin continue funcionando com os links locais sincronizados.
- **Resiliência:** Uso de mounts do tipo `soft` no NFS para evitar travamentos de Kernel (Estado D) em caso de queda de rede.

## 4. Contrato de Simetria (Path Parity)
A estabilidade depende da paridade absoluta de caminhos entre todos os nós do Nexus:
- **Padrão de Biblioteca:** `/mnt/storage/media/shows` e `/mnt/storage/media/movies`.
- **Padrão de Fonte (Zurg):** `/zurg` ou `/home/{{LINUX_USER}}/media/zurg`.
- **Implementação Docker:** Uso obrigatório de **Bind Mounts Diretos** para os caminhos físicos (Tier 3), eliminando a dependência de links simbólicos dentro do `/home/marcel` para o funcionamento do container.

## 5. Metas de Performance
- **PRIS CPU Load:** Manter abaixo de 40% durante playback de 4K (transcoding offloaded via QuickSync).
- **I/O Wait:** Zerar ocorrências de "Transport endpoint not connected" através de monitoramento proativo do mount FUSE.
