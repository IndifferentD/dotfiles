{ pkgs, ... }:

let
  programEntries = builtins.readDir ./modules/programs;
  programNames = builtins.filter
    (name: programEntries.${name} == "directory")
    (builtins.attrNames programEntries);
  pyghidraPython = pkgs.python3.withPackages (ps: [ ps.pyghidra ]);
in
{
  imports = [ ./modules/desktop/background ]
    ++ builtins.map (name: ./modules/programs + "/${name}") programNames;

  home.stateVersion = "26.05";
  home.sessionVariables = {
    GHIDRA_INSTALL_DIR = "${pkgs.ghidra-bin}/lib/ghidra";
    JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
  };

  home.packages = with pkgs; [
    # Terminal and development tools without separate configuration.
    fastfetch
    ripgrep
    fd
    eza
    jq
    uv
    tree-sitter
    gnutar
    curl
    wl-clipboard

    # Reverse engineering tools.
    ghidra-bin
    pyghidraPython
    detect-it-easy

    # Languages.
    nodejs
    bun

    # Infrastructure and GitHub.
    kubectl
    k9s
    gh

    nerd-fonts.jetbrains-mono
  ];

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
