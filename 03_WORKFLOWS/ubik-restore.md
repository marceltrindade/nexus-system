# UBIK — Restore Checklist

> Check-list pós-formatação para restaurar o nó UBIK do zero.
> Backup dos arquivos sensíveis está em `valis:~/backups/ubik/`.

---

## Fase 0 — Pré-requisitos

- [ ] Ubuntu 24.04 instalado
- [ ] Acesso SSH ao VALIS configurado
- [ ] `ping valis.home` resolvendo
- [ ] `sudo apt update && sudo apt upgrade -y`

---

## Fase 1 — Restaurar secrets

```bash
scp -r valis:~/backups/ubik/keys/* ~/.ssh/
scp valis:~/backups/ubik/dotenv/.env ~/
chmod 600 ~/.ssh/*
```

- [ ] Chaves SSH copiadas do VALIS
- [ ] `~/.env` com tokens copiado

---

## Fase 2 — Pacotes

```bash
sudo apt install -y \
  git curl wget unzip \
  build-essential \
  zsh tmux \
  fzf ripgrep bat fd-find \
  ffmpeg mpv \
  docker.io docker-compose-v2 \
  pipewire wireplumber \
  p7zip-full \
  neovim \
  htop btop \
  network-manager
```

- [ ] Todos os pacotes instalados

```bash
# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Ollama (GPU Vulkan)
curl -fsSL https://ollama.com/install.sh | sh

# Chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin

# Starship
curl -sS https://starship.rs/install.sh | sh

# Zinit (instalado na primeira vez que .zshrc rodar)

# Node (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install --lts

# gh CLI
(type -p wget >/dev/null || sudo apt install wget -y) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update && sudo apt install gh -y
```

- [ ] Tailscale instalado e conectado
- [ ] Ollama instalado
- [ ] Chezmoi instalado
- [ ] Starship instalado
- [ ] gh CLI instalado

---

## Fase 3 — Dotfiles

```bash
chezmoi init --apply marceltrindade
```

- [ ] `~/.zshrc` restaurado
- [ ] `~/.tmux.conf` restaurado
- [ ] `~/.config/` (nvim, ghostty, starship, etc.) restaurado
- [ ] `~/.ssh/config` restaurado (com servidores Nexus)

```bash
# Trocar shell padrão para zsh
chsh -s $(which zsh)
```

- [ ] Shell trocado para zsh

---

## Fase 4 — Projetos

```bash
mkdir -p ~/Projects

# Second Brain (privado)
gh auth login
git clone https://github.com/marceltrindade/second-brain.git ~/Documents/JD

# Nexus Docs (público)
git clone https://github.com/marceltrindade/nexus-system.git ~/Projects/nexus-system

# IIVA (público)
git clone https://github.com/marceltrindade/IIVA.git ~/Projects/IIVA

# Nexus-Agents (privado — copiar manual se necessário)
```

- [ ] gh autenticado
- [ ] Second Brain clonado
- [ ] Nexus Docs clonado
- [ ] IIVA clonado

---

## Fase 5 — Grupos Docker

```bash
sudo usermod -aG docker $USER
newgrp docker
```

- [ ] Usuário no grupo docker

---

## Fase 6 — Verificação final

- [ ] `ff` — fastfetch mostra info do sistema
- [ ] `tmux` — abre sem erro
- [ ] `nvim` — abre sem erro
- [ ] `ssh valis` — conecta sem senha
- [ ] `ssh pris-mesh` — conecta via tailscale
- [ ] `docker ps` — lista containers locais
- [ ] `ollama list` — modelos disponíveis
- [ ] `source ~/.env` — tokens carregados (sem erro)
- [ ] `baixarlegenda "teste"` — função existe (não precisa rodar)
- [ ] `hermes tunnel` — túnel do dashboard funciona
