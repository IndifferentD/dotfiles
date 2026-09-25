## Ubuntu setup

Tested on Ubuntu 26.04.1 LTS.

### 1. Install base tools

```bash
sudo apt update
sudo apt install -y git curl
```

### 2. Clone this repository
```bash
git clone https://github.com/IndifferentD/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 3. Run the Ubuntu bootstrap
```bash
bootstrap/ubuntu.sh
```

The bootstrap currently handles:
- Zsh installation
- Nix installation
- enabling nix-command and flakes
- changing the login shell to Zsh
- optional Docker installation
### 4. Build and validate the Nix configuration

```
nix flake check```

### 5. Apply the Home Manager configuration
For the first run:
```
nix run github:nix-community/home-manager/master -- \
  switch --flake ~/dotfiles#personal```

After Home Manager is installed into the environment, future updates can be applied with:
```home-manager switch --flake ~/dotfiles#personal```

### 6. Log out and log back in
This is required after changing the login shell and may also be required after Docker group changes.
