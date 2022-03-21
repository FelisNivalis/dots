{
  description = "Home Manager configurations";

  inputs = {
    # flakes
    nixpkgs.url = "flake:nixpkgs/release-25.11";
    nixpkgs-unstable.url = "flake:nixpkgs/nixpkgs-unstable";
    homeManager = { url = "github:nix-community/home-manager/release-25.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    system-manager = { url = "github:numtide/system-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # https://archive.ph/4Te43
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    rust-overlay = { url = "github:oxalica/rust-overlay"; inputs.nixpkgs.follows = "nixpkgs"; };

    superfile = { url = "github:yorukot/superfile/v1.4.0"; inputs.nixpkgs.follows = "nixpkgs"; };
    mise = { url = "github:jdx/mise/v2025.12.12"; inputs.nixpkgs.follows = "nixpkgs"; };
    xdg-ninja = { url = "github:b3nj5m1n/xdg-ninja/"; inputs.nixpkgs.follows = "nixpkgs"; };
    atuin = { url = "github:atuinsh/atuin/v18.10.0"; inputs.nixpkgs.follows = "nixpkgs"; inputs.fenix.follows = "fenix"; };
    jj = { url = "github:jj-vcs/jj/v0.36.0"; inputs.nixpkgs.follows = "nixpkgs"; inputs.rust-overlay.follows = "rust-overlay"; };
    nur = { url = "github:nix-community/NUR"; inputs.nixpkgs.follows = "nixpkgs"; };
    isd = { url = "github:isd-project/isd/v0.6.1"; inputs.nixpkgs.follows = "nixpkgs"; };
    doxx = { url = "github:bgreenwell/doxx"; inputs.nixpkgs.follows = "nixpkgs"; inputs.rust-overlay.follows = "rust-overlay"; }; # TUI .docx viewer

    # sources for overriding
    neovim-src = { url = "github:neovim/neovim/v0.11.5"; flake = false; };
    starship = { url = "github:starship/starship/v1.24.1"; flake = false; };

    # git clone
    zimfw = { url = "github:zimfw/zimfw/v1.20.0"; flake = false; };
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

    toolgit = { url = "github:ahmetsait/toolgit"; flake = false; };

    ansi = { url = "https://github.com/NNBnh/ansi"; flake = false; };

		sdkman-cli = { url = "github:sdkman/sdkman-cli/5.20.0"; flake = false; };
		sdkman-cli-native = { url = "github:sdkman/sdkman-cli-native/v0.7.14"; flake = false; };
    sdkman-candidates-all = { url = "https://api.sdkman.io/2/candidates/all"; flake = false; };

    nanorc = { url = "github:scopatz/nanorc"; flake = false; };

    jupyter-zsh-completion = { url = "https://raw.githubusercontent.com/jupyter/jupyter_core/main/examples/completions-zsh"; flake = false; };
    jupyter-bash-completion = { url = "https://raw.githubusercontent.com/jupyter/jupyter_core/main/examples/jupyter-completion.bash"; flake = false; };
    ollama-zsh-completion = { url = "https://raw.githubusercontent.com/Katrovsky/zsh-ollama-completion/refs/heads/main/_ollama"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, homeManager, ... }:
    let
      machines = (import ../private/machines.nix);
      all-features =
        (import ../private/all-features.nix { lib = nixpkgs.lib; });
      getFeatures = features:
        nixpkgs.lib.listToAttrs (map (feature: {
          name = feature;
          value = nixpkgs.lib.any (_feature: _feature == feature) features;
        }) all-features);
      # https://web.archive.org/web/20241010072933/https://nixos.wiki/wiki/Overlays
      # https://web.archive.org/web/20241118225800/https://nixos.org/manual/nixpkgs/stable/#sec-overlays-argument
      # https://web.archive.org/web/20241119235448/https://noogle.dev/f/pkgs/appendOverlays
      # getPkgs = system: nixpkgs.legacyPackages.${system}.extend inputs.nur.overlay;
      getPkgs = system: pkgs: config:
        import pkgs {
          inherit system;
          overlays = [ inputs.nur.overlays.default ];
          config = config;
        };
      getRefFromLock =
        let lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);
        in name: (builtins.getAttr name lockfile.nodes).original.ref;
    in {
      systemConfigs.default = let system = "x86_64-linux";
      in inputs.system-manager.lib.makeSystemConfig {
        modules = [
          ({ config, lib, pkgs, ... }: {
            config = {
              nixpkgs.hostPlatform = system;

              environment = {
                etc = { "xrdp/sesman.ini".source = ../etc/xrdp/sesman.ini; };
                systemPackages = [ ];
              };
            };
          })
        ];
      };
      homeConfigurations = let
        system = "x86_64-linux";
        getConfig = machine:
          homeManager.lib.homeManagerConfiguration rec {
            pkgs = getPkgs system nixpkgs { };
            extraSpecialArgs = rec {
              inherit inputs getRefFromLock;
              username = machine.username;
              features = getFeatures machine.features;
              versions = {
                sdkman-cli = "5.20.0";
                sdkman-cli-native = "v0.7.14";
              };
              pkgs-unstable = getPkgs system inputs.nixpkgs-unstable { };
              pkgs-unfree = getPkgs system nixpkgs { allowUnfree = true; };
              stableRustPlatform = let
                toolchain =
                  inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.stable;
                # toolchain = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.toolchainOf {
                #   # static.rust-lang.org/dist/channel-rust-stable
                #   # https://releases.rs/
                #   channel = "stable";
                #   sha256 = "sha256-yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
                # };
              in pkgs-unstable.makeRustPlatform {
                cargo = toolchain.cargo;
                rustc = toolchain.rustc;
              };
            };
            modules = [
              ../home-manager/home.nix # env vars
              ../home-manager/programs.nix ../home-manager/shell.nix ../home-manager/zimrc.nix # configurations
              ../home-manager/activations.nix

              ../home-manager/packages.nix

              ../home-manager/packages/custom.nix

              ../home-manager/packages/pyenv.nix ../home-manager/packages/rbenv.nix ../home-manager/packages/luaenv.nix ../home-manager/packages/plenv.nix
              ../home-manager/packages/sdkman.nix
              ../home-manager/packages/scripts.nix
            ] ++ (let
              filename = ../private/machines/${machine.name}/modules.nix;
            in nixpkgs.lib.optional (builtins.pathExists filename) filename);
          };
      in nixpkgs.lib.listToAttrs (map (name: {
        name = name;
        value = getConfig
          ((builtins.getAttr name machines) // { name = name; });
      }) (nixpkgs.lib.attrsets.attrNames machines));
    };
}
