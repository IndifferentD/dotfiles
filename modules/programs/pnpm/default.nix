{ pkgs, ... }:

{
  home.packages = [ pkgs.pnpm ];
  home.sessionPath = [ "$HOME/.local/share/pnpm/bin" ];
}
