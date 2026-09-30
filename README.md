# Dotfiles

Personal Ubuntu 26.04+ setup. Home Manager manages the user profile; Ubuntu
packages provide niri and DankMaterialShell so they use the system graphics
stack.

## Fresh installation

```bash
sudo apt update
sudo apt install -y git curl
git clone https://github.com/IndifferentD/dotfiles "$HOME/dotfiles"
cd "$HOME/dotfiles"
./bootstrap/ubuntu.sh
```

The bootstrap offers Zsh, Nix, Docker, and niri with DankMaterialShell. Log out
and back in so the new shell, Nix, and group membership are available. Then
apply the Home Manager profile:

```bash
nix run github:nix-community/home-manager/master -- \
  switch --flake "path:$HOME/dotfiles#personal"
```

If you installed niri, select **Niri** in GDM. DMS starts with niri, and GNOME
remains available from the same session picker.

## Updates

```bash
cd "$HOME/dotfiles"
home-manager switch --flake "path:$HOME/dotfiles#personal"
```
