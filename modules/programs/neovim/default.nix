{ pkgs, neovim-nightly, ... }:

{
  home.packages = [
    neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
