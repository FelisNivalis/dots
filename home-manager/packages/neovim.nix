{ pkgs, ... }: {
  nixpkgs.overlays = [ (final: prev: {
    neovim-unwrapped = let
      version = "0.10.0";
    in prev.neovim-unwrapped.overrideAttrs {
      version = version;
      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "v${version}";
        hash = "sha256-FCOipXHkAbkuFw9JjEpOIJ8BkyMkjkI0Dp+SzZ4yZlw=";
      };
    };
  }) ];
  home.packages = [
    ((pkgs.neovim.override {
      withRuby = false; withPython3 = false;
    }).overrideAttrs {
      generatedWrapperArgs = []; # nixpkgs nightly; maybe release 24.11?
    })
  ];
}
