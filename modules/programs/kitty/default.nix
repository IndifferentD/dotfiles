{ ... }:

{
  # Kitty is installed by the system; Home Manager manages only its config.
  xdg.configFile."kitty".source = ./files;
}
