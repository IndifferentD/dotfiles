{ pkgs, neovim-nightly, ... }:

{
  home.username = "indifferent_d";
  home.homeDirectory = "/home/indifferent_d";

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # terminal/dev tools
    atuin
    tmux
    fastfetch
    ripgrep
    fd
    fzf
    jq
    uv
    lazygit
    zoxide

    # languages
    nodejs
    pnpm
    go
    golangci-lint

    # infra
    kubectl

    # git/github
    gh

    # sesh itself
    sesh

    # Neovim is added separately below
  ]
  ++ [
   neovim-nightly.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidget.command = "";
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
}
