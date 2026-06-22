# Estratégia de Unificação de Escopo - Decypharr (PRIS)

**Data:** 28 de Março de 2026  
**Status:** Planejado  
**Autor:** Gaff

## 1. Problema Identificado
O sistema **BusterFriendlyV2** no nó **PRIS** apresenta uma falha de importação recorrente (Ex: *Kaiju No. 8*). O problema é causado pela "miopia" da configuração do Decypharr, que está restrito a subpastas específicas (`/zurg/shows` e `/zurg/movies`), enquanto o orquestrador Zurg frequentemente mantém arquivos novos ou de terceiros na raiz do mount (`/__all__`).

## 2. Objetivos
- Eliminar o ponto cego de importação mapeando a raiz do mount `/zurg` para o Decypharr.
- Manter a "Regra do 1" (serialização total de I/O) para proteger o hardware do nó PRIS (i5-5200U).
- Garantir a visibilidade instantânea de arquivos em qualquer subdiretório do Zurg.

## 3. Plano de Ação (Execução via SSH)

### Fase 1: Atualização de Configurações Internas (JSON)
Devido ao Decypharr utilizar arquivos JSON para definir a pasta do Debrid, precisamos alterar os campos `"folder"` de cada container:

- **Decypharr-Sonarr:** `/home/{{LINUX_USER}}/docker/media/config/decypharr-sonarr/config.json`
  - De: `"folder": "/zurg/shows"`
  - Para: `"folder": "/zurg"`
- **Decypharr-Radarr:** `/home/{{LINUX_USER}}/docker/media/config/decypharr-radarr/config.json`
  - De: `"folder": "/zurg/movies"`
  - Para: `"folder": "/zurg"`

### Fase 2: Atualização da Infraestrutura Docker (YAML)
Ajustar os volumes no arquivo `/home/{{LINUX_USER}}/docker/media/download/docker-compose.yml`:
- Mudar o bind mount de `${MEDIA_DEST}/zurg/movies` ou `${MEDIA_DEST}/zurg/shows` para `${MEDIA_DEST}/zurg:/zurg:ro`.
- Manter a variável de ambiente `ZURG_MOUNT_PATH=/zurg`.

### Fase 3: Reinicialização e Validação
1. Parar a stack de download: `docker compose down`.
2. Aplicar as mudanças via comando `ssh` injetando os arquivos completos (Heredoc).
3. Subir a stack: `docker compose up -d`.
4. Verificar se o symlink de conteúdos em `__all__` é criado automaticamente.

## 4. Medidas de Segurança
- **Backup Prévio:** Antes de sobrescrever, cada arquivo terá um backup gerado (ex: `config.json.bak_20260328`).
- **Integridade JSON:** O conteúdo será enviado de forma literal para evitar quebras de sintaxe por caracteres especiais.
- **Isolamento:** A mudança será feita apenas na stack de download, sem afetar o Jellyfin ou os Arrs.

## 5. Próximos Passos Sugeridos (Opcional)
- Implementar o `vfs/refresh` via Cron no nó PRIS para acelerar a sincronia entre o Real-Debrid e o mount local.

---
*Documento gerado como base para a execução técnica.*
