{ config, pkgs, neovim-nightly, ... }:

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
}
