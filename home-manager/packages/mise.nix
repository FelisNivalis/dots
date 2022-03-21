{ lib, config, pkgs, system, inputs, stableRustPlatform, ... }: let
  mise = inputs.mise.packages.${system}.default
    .overrideAttrs (prevAttrs: {
      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgs.installShellFiles ];
      postInstall = ''
        installManPage ./man/man1/mise.1

        installShellCompletion \
          --bash ./completions/mise.bash \
          --fish ./completions/mise.fish \
          --zsh ./completions/_mise
      '';
      doCheck = false;
    });
in {
  home.packages = [ mise ];
  lib.packages.mise = mise;
}
