{ lib, config, pkgs, inputs, ... }: let
  plenv_root = "${config.xdg.dataHome}/plenv";
  plugins = {
    perl-build = inputs.perl-build;
  };
  plenv = (
    import ./xxenv.nix
    {
      inherit pkgs inputs;
      name = "plenv";
      manPages = "";
    }
  ).plenv.overrideAttrs (prev: {
    phases = [ "unpackPhase" "installPhase" ];
    postInstall = ''
      cp -R completions "$out/completions"
      cp -R plenv.d "$out/plenv.d"
    '' + prev.postInstall;
  });
in {
  home.packages = [ plenv ];
  home.file = (pkgs.lib.listToAttrs (
    map
      (plugin: {
        name = "${plenv_root}/plugins/${plugin.name}";
        value = {
          source = plugin.value;
          recursive = false;
        };
      })
      (pkgs.lib.attrsToList plugins)
  ));
  home.sessionVariables = {
    PLENV_ROOT = plenv_root;
  };
  programs.zsh.initContent = lib.mkOrder 950 ''
    # `plenv init -` will source completions
    eval "$(${plenv}/bin/plenv init -)"
    ${plenv}/bin/plenv rehash
  '';
  programs.bash.initExtra = ''
    eval "$(${plenv}/bin/plenv init -)"
    ${plenv}/bin/plenv rehash
  '';
  lib.packages.plenv = plenv;
}
