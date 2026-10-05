{ config, pkgs, neovim-nightly, ... }:

{

  imports = [
    ./modules/programs/git.nix
    ./modules/programs/tmux.nix
  ];

  home.sessionPath = [
    "$HOME/go/bin"
  ];
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # terminal/dev tools
    atuin
    fastfetch
    ripgrep
    fd
    fzf
    eza
    jq
    uv
    lazygit
    zoxide
    tree-sitter
    gnutar
    gcc
    delta
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

    # languages
    nodejs
    pnpm
    go
    golangci-lint
    bun
    rustc
    cargo
    rustfmt
    clippy

    # infra
    kubectl
    k9s

    # git/github
    gh

    # sesh itself
    sesh

    # fonts
    nerd-fonts.jetbrains-mono
    # Neovim is added separately below
  ]
  ++ [
   neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = builtins.readFile ./config/zsh/custom.zsh;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.shellAliases = {
    ls = "eza -lh --group-directories-first --icons=auto";
    lsa = "eza -lha --group-directories-first --icons=auto";
    lt = "eza --tree --level=2 --long --icons --git";
    lta = "eza --tree --level=2 --long --icons --git -a";
    nv = "nvim";
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
 
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidget.command = "";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings.mgr.show_hidden = true;
  };

  home.file.".golangci.toml".source =
    ./config/golangci.toml;

  xdg.configFile."alacritty".source =
    ./config/alacritty;

  xdg.configFile."lazygit".source =
    ./config/lazygit;

  xdg.configFile."starship.toml".source =
    ./config/starship.toml;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  fonts.fontconfig.enable = true;
  xdg.configFile."autostart/alacritty.desktop".text = ''
  [Desktop Entry]
  Type=Application
  Name=Alacritty
  Exec=sh -c "sleep 6; exec /usr/bin/alacritty"
  Terminal=false
  OnlyShowIn=GNOME;
  X-GNOME-Autostart-enabled=true
'';

  xdg.configFile."background".source = ./config/background;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/.config/background";
      picture-uri-dark = "file://${config.home.homeDirectory}/.config/background";
    };
  };

}
