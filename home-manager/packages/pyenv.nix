{ lib, config, pkgs, inputs, ... }: let
  pyenv_root = "${config.xdg.dataHome}/pyenv";
  pyenv = (
    import ./xxenv.nix
    {
      inherit pkgs inputs;
      name = "pyenv";
      manPages = "man/man1/pyenv.1";
    }
  ).pyenv;
in {
  home.file = {
    "${pyenv_root}/plugins/pyenv-virtualenv" = {
      source = inputs.pyenv-virtualenv;
      recursive = false;
    };
    "${pyenv_root}/plugins/pyenv-doctor" = {
      source = inputs.pyenv-doctor;
      recursive = false;
    };
  };
  programs.pyenv = {
    enable = true;
    enableZshIntegration = false; # use ohmyzsh
    package = pyenv;
    rootDirectory = pyenv_root;
  };
  programs.zsh.initContent = lib.mkOrder 950 ''
    # related issue: https://github.com/pyenv/pyenv/pull/1644
    . ${pyenv}/share/zsh/site-functions/_pyenv
  '';
  home.sessionVariables = {
    PYENV_ROOT = pyenv_root;
  };
  lib.packages.pyenv = pyenv;
}
