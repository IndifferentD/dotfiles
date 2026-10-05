{ pkgs, ... }:

{
  home.packages = [ pkgs.golangci-lint ];
  home.file.".golangci.toml".source = ./golangci.toml;
}
