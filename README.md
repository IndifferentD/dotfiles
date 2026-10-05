# Dotfiles

Personal Ubuntu 26.04+ setup. Home Manager manages the user profile; Ubuntu
packages provide niri and DankMaterialShell so they use the system graphics
stack.

## Repository layout

- `flake.nix` defines the `personal` and `work` Home Manager profiles and pins
  their inputs through `flake.lock`.
- `home.nix` holds shared packages and imports every directory under
  `modules/programs/` as a module. Each directory must contain a `default.nix`;
  adding one enables the program in both profiles.
- `modules/programs/<name>/` keeps a program's Home Manager settings and any
  config files together. The Alacritty and Kitty modules manage config files
  only; their applications are installed outside Home Manager.
- `modules/desktop/` contains desktop settings that are not a single program.

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

The `path:` form also sees new files before they are added to Git. With
`--flake .#personal`, Git-backed flakes ignore untracked files; run
`git add -N path/to/new/default.nix` or stage them before switching.
