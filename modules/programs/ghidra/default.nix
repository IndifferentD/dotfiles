{ lib, pkgs, ... }:

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
    "GHIDRA WORKAROUND ACTIVE: patchelf 0.15.2 is pinned until https://github.com/NixOS/patchelf/pull/672 reaches nixpkgs."
    (pkgs.ghidra-bin.overrideAttrs (previousAttrs: {
      nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ patchelf015 ];
      preFixup = (previousAttrs.preFixup or "") + ''
        export PATH="${patchelf015}/bin:$PATH"
        # Java AWT otherwise leaves Ghidra windows blank under Sway.
        substituteInPlace "$out/lib/ghidra/support/launch.properties" \
          --replace-fail '#ENVVARS_LINUX=_JAVA_AWT_WM_NONREPARENTING=1' \
          'ENVVARS_LINUX=_JAVA_AWT_WM_NONREPARENTING=1'
      '';
    }));
  pyghidraPython = pkgs.python3.withPackages (ps: [ ps.pyghidra ]);
in
{
  home.activation.ghidraPatchelfNotice = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    printf '\033[1;31mGHIDRA WORKAROUND ACTIVE: patchelf 0.15.2 is pinned; remove it after nixpkgs includes the fix.\033[0m\n' >&2
  '';

  home.packages = [
    ghidra
    pyghidraPython
  ];

  home.sessionVariables = {
    GHIDRA_INSTALL_DIR = "${ghidra}/lib/ghidra";
    JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
  };
}
