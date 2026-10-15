{ pkgs, ... }:

{
  # Use Ubuntu's cc for rustup builds. A profile-wide Nix GCC selects Nix glibc
  # for linked binaries, so dlopen cannot find host Wayland libraries.
  home.packages = [ pkgs.rustup ];
}
