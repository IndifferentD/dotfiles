{ pkgs, ... }:

{
  home.packages = [ pkgs.go ];
  home.sessionPath = [ "$HOME/go/bin" ];
}
