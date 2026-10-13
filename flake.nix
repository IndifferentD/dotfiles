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

      mkHome = { username, homeDirectory, profile }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit system neovim-nightly profile;
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
          profile = "personal";
        };

        any =
          let
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
          in
          if username == "" || homeDirectory == "" then
            throw "The any profile needs USER and HOME; pass --impure to Home Manager"
          else
            mkHome {
              inherit username homeDirectory;
              profile = "any";
            };
      };
    };
}
