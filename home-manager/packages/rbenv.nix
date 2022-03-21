{ config, pkgs, inputs, ... }: let
  rbenv_root = "${config.xdg.dataHome}/rbenv";
  plugins = {
    ruby-build = inputs.ruby-build;
    rbenv-vars = inputs.rbenv-vars;
    rbenv-gemset = inputs.rbenv-gemset;
    rbenv-update = inputs.rbenv-update;
  };
  rbenv = (
    import ./xxenv.nix
    {
      inherit pkgs inputs;
      name = "rbenv";
      manPages = "share/man/man1/rbenv.1";
      completionFiles = "completions/{_rbenv,rbenv.bash}";
    }
  ).rbenv;
in {
  home.file = (pkgs.lib.listToAttrs (
    map
      (plugin: {
        name = "${rbenv_root}/plugins/${plugin.name}";
        value = {
          source = plugin.value;
          recursive = false;
        };
      })
      (pkgs.lib.attrsToList plugins)
  ));
  programs.rbenv = {
    enable = true;
    enableZshIntegration = false; # use the ohmyzsh rbenv plugin
    package = rbenv;
  };
  home.sessionVariables = {
    RBENV_ROOT = rbenv_root;
  };
  lib.packages.rbenv = rbenv;
}
