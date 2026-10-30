{ pkgs, ... }:

{
  # Use Ubuntu's compiler from build-essential (installed by bootstrap).
  # A profile-wide Nix GCC can cause issues when loading host Wayland libraries.
  home.packages = [ pkgs.rustup ];
}
