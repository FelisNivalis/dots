{
  description = "Home Manager configurations";

  inputs = {
    # I'd like to pin a released version, but need nightly now
    nixpkgs.url = "flake:nixpkgs/a4ab96ff235c2100f5e1d82b079ce5364958c0db";
    # flake-utils.url = "github:numtide/flake-utils";
    homeManager = {
      url = "github:nix-community/home-manager/44677a1c96810a8e8c4ffaeaad10c842402647c1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    superfile.url = "github:MHNightCat/superfile/v1.1.2";
    mise.url = "github:jdx/mise/v2024.5.11";
  };

  outputs = inputs @ { self, nixpkgs, homeManager, ... }: {
    homeConfigurations = (
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        args = {
          inherit system inputs;
          username = "feles";
        };
      in {
        "feles@ubuntu-wsl" = homeManager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./packages.nix
            ./programs.nix
            ./activations.nix
            ./packages/git.nix
            ./packages/neovim.nix
            ./packages/pyenv.nix
            ./packages/mise.nix
            ./packages/wsl.nix
            {
              home.packages =
                map
                (pkg: inputs.${pkg}.packages.${system}.default)
                [ "superfile" ];
            }
          ];
          extraSpecialArgs = args // { wsl = true; };
        };
      } //
      # let ; in
      {}
    );
  };
}
