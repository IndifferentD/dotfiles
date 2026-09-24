{ config, pkgs, neovim-nightly, ... }:

{

  home.sessionPath = [
    "$HOME/go/bin"
  ];
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # terminal/dev tools
    atuin
    tmux
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

    # languages
    nodejs
    pnpm
    go
    golangci-lint
    bun

    # infra
    kubectl

    # git/github
    gh

    # sesh itself
    sesh

    # fonts
    nerd-fonts.jetbrains-mono

    # Neovim is added separately below
  ]
  ++ [
   neovim-nightly.packages.${pkgs.system}.default
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

  home.file.".golangci.toml".source =
    ./config/golangci.toml;

  home.file.".tmux.conf".source =
    ./config/tmux.conf;

  xdg.configFile."alacritty".source =
    ./config/alacritty;

  xdg.configFile."lazygit".source =
    ./config/lazygit;

  xdg.configFile."starship.toml".source =
    ./config/starship.toml;

  xdg.configFile."ubuntu-xdg-terminals.list".text = ''
    Alacritty.desktop
  '';


  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  fonts.fontconfig.enable = true;
  
  xdg.configFile."background".source = ./config/background;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/.config/background";
      picture-uri-dark = "file://${config.home.homeDirectory}/.config/background";
  };
};

}
