#!/usr/bin/env bash
set -euo pipefail

confirm() {
  read -r -p "$1 [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

echo "Ubuntu bootstrap"

if confirm "Install base packages and Zsh?"; then
  sudo apt update
  sudo apt install -y \
    curl \
    ca-certificates \
    git \
    zsh \
    alacritty

  echo "Base packages installed."
fi

if ! command -v nix >/dev/null 2>&1; then
  if confirm "Install Nix?"; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
  fi
fi

if confirm "Enable Nix flakes?"; then
  sudo mkdir -p /etc/nix
  echo 'experimental-features = nix-command flakes' \
    | sudo tee -a /etc/nix/nix.conf >/dev/null

  sudo systemctl restart nix-daemon
fi

ZSH_PATH="$(command -v zsh || true)"

if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
  if confirm "Change your login shell to $ZSH_PATH?"; then
    chsh -s "$ZSH_PATH"
    echo "Login shell changed. Log out and back in later."
  fi
fi

if confirm "Install Docker Engine from Docker's official apt repository?"; then
  echo "Removing potentially conflicting Docker packages..."

  sudo apt remove -y \
    docker.io \
    docker-compose \
    docker-compose-v2 \
    docker-doc \
    docker-buildx \
    podman-docker \
    containerd \
    runc \
    2>/dev/null || true

  echo "Adding Docker apt repository..."

  sudo apt update
  sudo apt install -y ca-certificates curl

  sudo install -m 0755 -d /etc/apt/keyrings

  sudo curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt update

  if confirm "Install Docker Engine packages now?"; then
    sudo apt install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

    sudo systemctl enable --now docker

    echo "Docker installed."
  fi

  if confirm "Add current user to docker group?"; then
    sudo usermod -aG docker "$USER"
    echo "Added $USER to docker group."
    echo "Log out and back in before using docker without sudo."
  fi
fi

echo
echo "Bootstrap finished."
echo "Recommended next steps:"
echo "  1. log out / log back in if shell or docker group changed"
echo "  2. clone dotfiles"
echo "  3. nix flake check"
echo "  4. nix build .#homeConfigurations.personal.activationPackage"
echo "  5. ./result/activate"
