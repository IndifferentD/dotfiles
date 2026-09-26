{ lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      cpu
      # Keep these last, in this order, for session restoration.
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-boot 'on'
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
  };

  # Home Manager puts extraConfig after plugins. Load our settings between
  # its defaults (order 500) and plugins (order 1000), so status-right is set
  # before cpu/continuum update it and restoration runs after our bindings.
  xdg.configFile."tmux/tmux.conf".text =
    lib.mkOrder 600 (builtins.readFile ../../config/tmux.conf);

}
