{
  description = "Home Manager configurations";

  inputs = {
    # building tools
    nixpkgs.url = "flake:nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";
    homeManager = { url = "github:nix-community/home-manager/release-24.05"; inputs.nixpkgs.follows = "nixpkgs"; };
    system-manager = { url = "github:numtide/system-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # https://archive.ph/4Te43
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };

    # flakes
    superfile = { url = "github:MHNightCat/superfile/v1.1.4"; inputs.nixpkgs.follows = "nixpkgs"; };
    mise = { url = "github:jdx/mise/v2024.8.5"; inputs.nixpkgs.follows = "nixpkgs"; };
    xdg-ninja = { url = "github:b3nj5m1n/xdg-ninja"; inputs.nixpkgs.follows = "nixpkgs"; };
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    atuin = { url = "github:atuinsh/atuin/v18.3.0"; inputs.nixpkgs.follows = "nixpkgs"; inputs.fenix.follows = "fenix"; };

    # sources for overriding
    neovim-src = { url = "github:neovim/neovim/v0.10.1"; flake = false; };
    micromamba = { url = "github:mamba-org/mamba/micromamba-1.5.8"; flake = false; };
    starship = { url = "github:starship/starship/v1.20.1"; flake = false; };

    # git clone
    antigen = { url = "github:zsh-users/antigen/v2.2.3"; flake = false; };
    tpm = { url = "github:tmux-plugins/tpm/v3.1.0"; flake = false; };

    pyenv = { url = "github:pyenv/pyenv"; flake = false; };
    pyenv-virtualenv = { url = "github:pyenv/pyenv-virtualenv"; flake = false; };
    pyenv-doctor = { url = "github:pyenv/pyenv-doctor"; flake = false; };

    rbenv = { url = "github:rbenv/rbenv"; flake = false; };
    ruby-build = { url = "github:rbenv/ruby-build"; flake = false; };
    rbenv-vars = { url = "github:rbenv/rbenv-vars"; flake = false; };
    rbenv-gemset = { url = "github:jf/rbenv-gemset"; flake = false; };
    rbenv-update = { url = "github:rkh/rbenv-update"; flake = false; };

    luaenv = { url = "github:cehoffman/luaenv"; flake = false; };
    lua-build = { url = "github:cehoffman/lua-build"; flake = false; };
    luaenv-luarocks = { url = "github:Sharparam/luaenv-luarocks"; flake = false; };
    luaenv-update = { url = "github:Sharparam/luaenv-update"; flake = false; };
    luaenv-vars = { url = "github:cehoffman/luaenv-vars"; flake = false; };

    plenv = { url = "github:tokuhirom/plenv"; flake = false; };
    perl-build = { url = "github:tokuhirom/perl-build"; flake = false; };
  };

  outputs = inputs @ { self, nixpkgs, homeManager, ... }: let
    getBits = bits: let
      allBits = [ "WSL" ];
    in nixpkgs.lib.listToAttrs
      (map ( bit: { name = bit; value = nixpkgs.lib.any (_bit: _bit == bit) bits; } ) allBits);
    getPkgs = system: nixpkgs.legacyPackages.${system};
    overrideSrc = pkg: input: pkg.overrideAttrs {
      src = input; version = input.rev;
    };
  in {
    systemConfigs.default = inputs.system-manager.lib.makeSystemConfig {
      modules = [
        ({ config, lib, pkgs, ... }: {
          config = {
            nixpkgs.hostPlatform = "x86_64-linux";

            environment = {
              etc = {
                "xrdp/sesman.ini".source = ../etc/xrdp/sesman.ini;
              };
              systemPackages = [];
            };
          };
        })
      ];
    };
    homeConfigurations = let
      system = "x86_64-linux";
      username = "feles";
      bits = getBits [ "WSL" ];
    in {
      "feles@ubuntu-wsl" = homeManager.lib.homeManagerConfiguration rec {
        # https://nixos.wiki/wiki/Overlays
        pkgs = getPkgs system;
        modules = [
          ./home.nix # env vars
          ./programs.nix ./shell.nix # configurations
          ./activations.nix

          ./packages.nix
          {
            home.packages = with inputs; [
              superfile.packages.${system}.default
              xdg-ninja.packages.${system}.default # >v0.2.0.2
              atuin.packages.${system}.default
            ];
          }

          ./packages/pyenv.nix ./packages/rbenv.nix ./packages/luaenv.nix ./packages/plenv.nix
          ./packages/neovim.nix
          ./packages/micromamba.nix
          ./packages/mise.nix
          ./packages/scripts.nix
          # Only need an environment variable pointing to the git directory
          { home.sessionVariables = { ANTIGEN_ROOT = "${inputs.antigen}"; }; }
          { home.sessionVariables = { TPM_ROOT = "${inputs.tpm}"; }; }
        ];
        extraSpecialArgs = {
          inherit system inputs username bits overrideSrc;
          stableRustPlatform = let
            # toolchain = inputs.fenix.packages.${system}.stable.toolchain;
            toolchain = inputs.fenix.packages.${system}.toolchainOf {
              # static.rust-lang.org/dist/channel-rust-stable
              # https://releases.rs/
              channel = "stable";
            };
          in pkgs.makeRustPlatform {
            cargo = toolchain.cargo;
            rustc = toolchain.rustc;
          };
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
          };
        };
      };
    };
  };
}
