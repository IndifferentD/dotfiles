{ pkgs, ... }:

let
  programEntries = builtins.readDir ./modules/programs;
  programNames = builtins.filter
    (name: programEntries.${name} == "directory")
    (builtins.attrNames programEntries);
in
{
  imports = [ ./modules/desktop/background ]
    ++ builtins.map (name: ./modules/programs + "/${name}") programNames;

  home.sessionPath = [ "$HOME/go/bin" ];
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Terminal and development tools without separate configuration.
    fastfetch
    ripgrep
    fd
    eza
    jq
    uv
    tree-sitter
    gnutar
    gcc
    curl
    wl-clipboard

    # Install Codex together with RTK and OpenSpec.
    (symlinkJoin {
      name = "codex-system-bwrap-${codex.version}";
      paths = [ codex rtk openspec ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        # Prefer Ubuntu's bwrap, whose path matches its AppArmor profile.
        # Codex added /usr/bin/bwrap preference, then switched to PATH lookup:
        # https://github.com/openai/codex/pull/14963
        # https://github.com/openai/codex/pull/15791
        # Override nixpkgs' wrapper, which puts Nix bubblewrap first on PATH.
        rm "$out/bin/codex"
        makeWrapper ${codex}/bin/.codex-wrapped "$out/bin/codex" \
          --prefix PATH : "/usr/bin:${lib.makeBinPath [ ripgrep bubblewrap ]}"
      '';
      inherit (codex) meta;
    })

    # Languages.
    nodejs
    pnpm
    go
    bun
    rustc
    cargo
    rustfmt
    clippy

    # Infrastructure and GitHub.
    kubectl
    k9s
    gh

    nerd-fonts.jetbrains-mono
  ];

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
