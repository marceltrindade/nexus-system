# 🛠️ Manutenção e Saneamento do Sistema

Este documento descreve procedimentos recorrentes para manter a integridade e performance do Nexus.

## 1. Gestão de Permissões (Almox HDD)
Se houver erro de "Permission Denied" ou se você não conseguir importar arquivos para o Johnny.Decimal, rode o comando de "Cura":

```bash
# Corrige o proprietário recursivamente
sudo chown -R marcel:marcel /mnt/almox/JD

# Garante que novas pastas herdem o grupo (SGID) e permissões de escrita
sudo find /mnt/almox/JD -type d -exec chmod 2775 {} +

# Garante que arquivos sejam editáveis pelo usuário
sudo find /mnt/almox/JD -type f -exec chmod 664 {} +
```

## 2. Limpeza de Sistema (UBIK)
Para manter os SSDs respirando, execute mensalmente:

```bash
# Limpeza profunda do Docker (Imagens, Volumes e Cache de Build)
docker system prune -af --volumes

# Remocação de pacotes órfãos e limpeza do cache APT
sudo apt autoremove --purge && sudo apt clean

# Limpeza de Flatpaks não utilizados
flatpak uninstall --unused
```

## 3. Protocolo de Reinicialização Buster Friendly (PRIS)
Se o Jellyfin reportar erro de I/O (Zurg fora de sincronia):
1. `sudo systemctl restart zurg-app.service`
2. `sudo systemctl restart zurg.service`
3. `docker restart jellyfin`
