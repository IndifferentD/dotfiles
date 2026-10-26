{ ... }:

{
  # Kitty is installed by the system; Home Manager manages only its config.
  xdg.configFile = {
    "kitty/kitty.conf".source = ./files/kitty.conf;
    "kitty/startup.session".source = ./files/startup.session;
    "kitty/themes/jb-dark.conf".source = ./files/themes/jb-dark.conf;
  };
}
