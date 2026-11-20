{ pkgs, ... }:

let
  ghidra = pkgs.ghidra-bin.overrideAttrs (previousAttrs: {
    preFixup = (previousAttrs.preFixup or "") + ''
      # Java AWT otherwise leaves Ghidra windows blank under Sway.
      substituteInPlace "$out/lib/ghidra/support/launch.properties" \
        --replace-fail '#ENVVARS_LINUX=_JAVA_AWT_WM_NONREPARENTING=1' \
        'ENVVARS_LINUX=_JAVA_AWT_WM_NONREPARENTING=1'
    '';
  });
  pyghidraPython = pkgs.python3.withPackages (ps: [ ps.pyghidra ]);
in
{
  home.packages = [
    ghidra
    pyghidraPython
  ];

  home.sessionVariables = {
    GHIDRA_INSTALL_DIR = "${ghidra}/lib/ghidra";
    JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
  };
}
