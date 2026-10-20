{ pkgs, ... }:

let
  # patchelf 0.19.2 from nixpkgs#569010 corrupts Ghidra's decompile binary.
  # Use 0.15.2 until nixpkgs includes the fix from NixOS/patchelf#672.
  # https://github.com/NixOS/nixpkgs/pull/569010
  # https://github.com/NixOS/patchelf/pull/672
  patchelf015 = pkgs.patchelf.overrideAttrs (finalAttrs: _previousAttrs: {
    version = "0.15.2";
    src = pkgs.fetchurl {
      url = "https://github.com/NixOS/patchelf/releases/download/${finalAttrs.version}/patchelf-${finalAttrs.version}.tar.bz2";
      hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
    };
  });
  ghidra = pkgs.lib.warn
    "Ghidra uses a temporary patchelf 0.15.2 workaround; remove it once https://github.com/NixOS/patchelf/pull/672 reaches nixpkgs."
    (pkgs.ghidra-bin.overrideAttrs (previousAttrs: {
      nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ patchelf015 ];
      preFixup = (previousAttrs.preFixup or "") + ''
        export PATH="${patchelf015}/bin:$PATH"
      '';
    }));
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
