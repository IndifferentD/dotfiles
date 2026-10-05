{ ... }:

{
  xdg.configFile."alacritty".source = ./files;
  xdg.configFile."autostart/alacritty.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Alacritty
    Exec=sh -c "sleep 6; exec /usr/bin/alacritty"
    Terminal=false
    OnlyShowIn=GNOME;
    X-GNOME-Autostart-enabled=true
  '';
}
