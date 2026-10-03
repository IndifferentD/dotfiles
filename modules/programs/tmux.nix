{ lib, pkgs, ... }:

let
  fastcopySrc = pkgs.fetchzip {
    url = "https://github.com/abhinav/tmux-fastcopy/archive/refs/tags/v0.14.1.tar.gz";
    hash = "sha256-j7Kk5uaC3vx4JifaAHXfLvXx6ask9YqlNKEiU5BYi+A=";
  };

  fastcopyBin = pkgs.buildGoModule {
    pname = "tmux-fastcopy";
    version = "0.14.1";
    src = fastcopySrc;
    vendorHash = "sha256-Jcx9/qJKR4q1EYUu6NsNkakJS/qtQLlhys0GKx5BLQk=";
    GOFLAGS = [ "-buildvcs=false" ];
  };

  fastcopyPlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "fastcopy";
    rtpFilePath = "fastcopy.tmux";
    version = "0.14.1";
    src = fastcopySrc;
    postInstall = ''
      mkdir -p "$target/bin"
      ln -s ${fastcopyBin}/bin/tmux-fastcopy "$target/bin/tmux-fastcopy"
      patchShebangs "$target/fastcopy.tmux"
    '';
  };
in
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      cpu
      extrakto
      fastcopyPlugin
      # Keep these last, in this order, for session restoration.
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          # zsh starts tmux on login. The continuum systemd service saves during
          # shutdown after the tmux server is gone, replacing `last` with an
          # empty snapshot.
          set -g @continuum-boot 'off'
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
