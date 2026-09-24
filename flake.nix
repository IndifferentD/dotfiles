{
  description = "Home configuration";

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
    { nixpkgs, home-manager, neovim-nightly, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkHome = { username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit system neovim-nightly;
          };

          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in
    {
      homeConfigurations = {
        personal = mkHome {
          username = "indifferent_d";
          homeDirectory = "/home/indifferent_d";
        };

        work = mkHome {
          username = "gleb.mozgunov";
          homeDirectory = "/home/gleb.mozgunov";
        };
      };
    };
}
