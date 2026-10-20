{ lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "rtk";

  home.packages = [
    (pkgs.symlinkJoin {
      name = "codex-system-bwrap-${pkgs.codex.version}";
      paths = [ pkgs.codex pkgs.rtk pkgs.openspec ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        # Prefer Ubuntu's bwrap, whose path matches its AppArmor profile.
        # Codex added /usr/bin/bwrap preference, then switched to PATH lookup:
        # https://github.com/openai/codex/pull/14963
        # https://github.com/openai/codex/pull/15791
        rm "$out/bin/codex"
        makeWrapper ${pkgs.codex}/bin/codex "$out/bin/codex" \
          --prefix PATH : "/usr/bin:${pkgs.lib.makeBinPath [ pkgs.ripgrep pkgs.bubblewrap ]}"
      '';
      inherit (pkgs.codex) meta;
    })
  ];
}
