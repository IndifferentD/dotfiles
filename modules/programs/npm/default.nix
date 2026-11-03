{ config, ... }:

let
  npmPrefix = "${config.home.homeDirectory}/.local/share/npm";
in
{
  # Keep global npm installs in a writable directory outside the Nix store.
  home.sessionVariables.NPM_CONFIG_PREFIX = npmPrefix;
  home.sessionPath = [ "${npmPrefix}/bin" ];
}
