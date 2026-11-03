{ pkgs, ... }:

{
  # Switch back to pkgs.go once it defaults to Go 1.27 or newer.
  home.packages = [ pkgs.go_1_27 ];
  home.sessionPath = [ "$HOME/go/bin" ];
}
