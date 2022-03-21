{ pkgs, inputs, ... }@extraSpecialArgs:
(let
  packages = {
    neovim = extraSpecialArgs.pkgs-unstable.neovim.unwrapped.overrideAttrs {
      src = inputs.neovim-src;
      version = extraSpecialArgs.getRefFromLock "neovim-src";
    };
  } // (builtins.mapAttrs (name: f:
    f (builtins.getAttr name
      inputs).packages.${pkgs.stdenv.hostPlatform.system}.default)
    ((builtins.listToAttrs (builtins.map
      (name: pkgs.lib.attrsets.nameValuePair name pkgs.lib.trivial.id) [
        "atuin"
        # "isd"
        # "superfile"
        "xdg-ninja" # >v0.2.0.2
      ])) // {
        mise = pkg:
          ((pkg.override (pkgs.lib.trivial.const {
            rustPlatform = extraSpecialArgs.stableRustPlatform;
          })).overrideAttrs (prevAttrs: {
            nativeBuildInputs = prevAttrs.nativeBuildInputs ++ (with pkgs; [
              installShellFiles
              autoPatchelfHook
              rustPlatform.bindgenHook # finding libclang https://github.com/NixOS/nixpkgs/issues/52447
            ]);
            autoPatchelfIgnoreMissingDeps = [ "*" ]; # libgcc_s.so
            postInstall = ''
              installManPage ./man/man1/mise.1

              installShellCompletion \
                --bash ./completions/mise.bash \
                --fish ./completions/mise.fish \
                --zsh ./completions/_mise
            '';
            LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ openssl ]; # TODO
          }));
      }));
in {
  home.packages = pkgs.lib.attrsets.attrValues packages;
  lib.packages = packages;
  # Only need an environment variable pointing to the git directory
  home.sessionVariables = { TPM_ROOT = "${inputs.tpm}"; };
})

