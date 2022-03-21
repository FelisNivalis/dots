{ lib, config, pkgs, system, inputs, ... }: let
  mise = inputs.mise.packages.${system}.default.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgs.installShellFiles ];
    postInstall = ''
      installManPage ./man/man1/mise.1

      installShellCompletion \
        --bash ./completions/mise.bash \
        --fish ./completions/mise.fish \
        --zsh ./completions/_mise
    '';
  });
in rec {
  home = {
    packages = [ mise ];
    activation = let
      mise_cmd = ''PATH=/usr/bin:${config.xdg.dataHome}/mise/shims "${lib.getExe mise}"'';
    in {
      ensureMise = lib.hm.dag.entryAfter ["installPackages" "onFilesChange"] ''
        ${mise_cmd} install
        ${mise_cmd} prune --yes
        ${mise_cmd} reshim
      '';
    };
  };
}
