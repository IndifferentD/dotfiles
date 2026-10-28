{ config, ... }:

let
  niriConfigDir = "${config.home.homeDirectory}/.config/niri";
in
{
  # Niri itself comes from Ubuntu; Home Manager owns only portable settings.
  xdg.configFile."niri/common.kdl".source = ./files/common.kdl;

  # Home Manager links this file from the Nix store, so includes must use
  # absolute paths to reach the user's and DMS's writable config files.
  xdg.configFile."niri/config.kdl".text = ''
    include "${niriConfigDir}/common.kdl"
    include optional=true "${niriConfigDir}/dms/layout.kdl"
    include optional=true "${niriConfigDir}/dms/outputs.kdl"
    include optional=true "${niriConfigDir}/dms/input.kdl"
  '';
}
