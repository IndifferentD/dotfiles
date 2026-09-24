{
  description = "indifferent_d home configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly.url =
      "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { nixpkgs, home-manager, neovim-nightly, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.indifferent_d =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs neovim-nightly;
          };

          modules = [
            ./home.nix
          ];
        };
    };
}
