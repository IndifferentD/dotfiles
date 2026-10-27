# Dotfiles

Personal Ubuntu 26.04+ setup. Home Manager manages the user profile; Ubuntu
packages provide niri and DankMaterialShell so they use the system graphics
stack.

## Repository layout

- `flake.nix` defines the `personal` and `any` Home Manager profiles and pins
  their inputs through `flake.lock`. The `any` profile uses the current user's
  `USER` and `HOME` environment variables.
- `home.nix` holds shared packages and imports every directory under
  `modules/programs/` as a module. Each directory must contain a `default.nix`;
  adding one enables the program in both profiles.
- `modules/programs/<name>/` keeps a program's Home Manager settings and any
  config files together. The Kitty module manages config files only; the
  bootstrap installs Kitty through Ubuntu's `apt`.
- `modules/desktop/` contains desktop settings that are not a single program.

## Fresh installation

```bash
sudo apt update
sudo apt install -y git curl
git clone https://github.com/IndifferentD/dotfiles "$HOME/dotfiles"
cd "$HOME/dotfiles"
./bootstrap/ubuntu.sh
```

The bootstrap offers Zsh, Nix, Docker, Google Chrome, Telegram Desktop, and niri
with DankMaterialShell. Each installation is optional and defaults to no.
Chrome uses Google's official `.deb` package (amd64 or arm64), which adds its
apt repository for updates; Telegram uses the official `telegram-desktop` Snap.
Log out
and back in so the new shell, Nix, and group membership are available. Then
apply the Home Manager profile:

```bash
nix run github:nix-community/home-manager/master -- \
  switch --flake "path:$HOME/dotfiles#personal"
```

If you installed niri, select **Niri** in GDM. DMS starts with niri, and GNOME
remains available from the same session picker.

## Local SOCKS proxy with Xray

Requires Docker with Compose and a ready Xray JSON config.

```bash
./bootstrap/ubuntu-xray.sh /path/to/config.json
# Or use ~/opt/xray/config.json:
./bootstrap/ubuntu-xray.sh
```

The config must listen on `0.0.0.0:2080` inside the container.
Xray v26.7.28 runs with automatic restart; ports are published on `127.0.0.1:2080`
(TCP/UDP). Config and Compose files live in `~/opt/xray`.
Unchanged files are kept; replacement asks for confirmation and saves a backup.

```bash
docker compose -f "$HOME/opt/xray/compose.yaml" logs --tail=50
docker compose -f "$HOME/opt/xray/compose.yaml" down
```

## Updates

```bash
cd "$HOME/dotfiles"
home-manager switch --flake "path:$HOME/dotfiles#personal"
```

To apply the same shared configuration to the current user instead, select
`any`:

```bash
home-manager switch --impure --flake "path:$HOME/dotfiles#any"
```

The `any` profile requires `--impure` so Nix can read `USER` and `HOME`; without
it, evaluation fails. The `personal` profile keeps the fixed personal account
and Git identity.

The `path:` form also sees new files before they are added to Git. With
`--flake .#personal` or `--flake .#any`, Git-backed flakes ignore untracked
files; run `git add -N path/to/new/default.nix` or stage them before switching.
