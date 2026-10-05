{ pkgs, ... }:

{
  home.packages = [ pkgs.lazygit ];
  xdg.configFile."lazygit/config.yml".source = ./config.yml;
}
