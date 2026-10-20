{ pkgs, ... }:

let
  ghidra = pkgs.ghidra-bin;
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
