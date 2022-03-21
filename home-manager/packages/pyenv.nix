{ lib, config, pkgs, ... }: let
  pyenv = pkgs.pyenv.overrideAttrs (attrs: {
    # https://discourse.nixos.org/t/how-to-create-package-with-multiple-sources/9308/3
    srcs = [
      (pkgs.fetchFromGitHub {
        owner = "pyenv";
        repo = "pyenv";
        rev = "3ff54e89bc82687ff880d1e2d5a37f101cbfa63e";
        name = "pyenv";
        hash = "sha256-l7NrDpScSRg9Mqj+0zzWDjzXqRSghq1O1cRdPb4vW80=";
      })
      (pkgs.fetchFromGitHub {
        owner = "pyenv";
        repo = "pyenv-virtualenv";
        rev = "37917069ecba16602decd3dd2c8b09121c673a41";
        name = "pyenv-virtualenv";
        hash = "sha256-AnHU7BSERnTWV7lTvfloptCk4flPvGGbm1GGmju4OnU=";
      })
      (pkgs.fetchFromGitHub {
        owner = "pyenv";
        repo = "pyenv-doctor";
        rev = "bad83e51e1409665de6cb37537cfc1e02e154bec";
        name = "pyenv-doctor";
        hash = "sha256-U4nfLBUTi+VaalQqtC/iB3wZgYiNwwZd19aKltI/Maw=";
      })
    ];
    sourceRoot = "pyenv";
    postInstall = ''
      cp -R ../pyenv-virtualenv "$out/plugins"
      cp -R ../pyenv-doctor "$out/plugins"
      ${attrs.postInstall}
    '';
  });
  py_extra_vers = [];
  py_virtualenvs = {
    neovim = {
      ver = "latest";
      packages = [ "pynvim" ];
    };
    playground = {
      ver = "latest";
      packages = [
        "jupyterlab"
        "notebook"
        "euporie"
        "voila"
        "nteract-on-jupyter"
      ];
    };
  };
  py_global = "latest";
  py_locals = {
    # "$HOME/playground" = [ "playground" ];
  };
in rec {
  home.activation = {
    ensurePyenv = let
      getVer = (
        ver:
          if ver == "latest"
          then "$LATEST_VER"
          else ver
      );
      join = (s: l: lib.strings.concatStrings (lib.strings.intersperse s l));
    in lib.hm.dag.entryAfter ["installPackages" "onFilesChange"] (
      let pyenv_cmd = ''PATH=/usr/bin "${lib.getExe pyenv}"'';
      in ''
        PYENV_ROOT=${config.xdg.dataHome}/pyenv
        LATEST_VER=$(${pyenv_cmd} latest -k 3)
        ${pyenv_cmd} install --skip-existing ${join " " (
          lib.lists.unique (
            py_extra_vers ++
            (lib.lists.flatten (builtins.attrValues py_locals)) ++
            (builtins.attrValues (builtins.mapAttrs (name: value: getVer value.ver) py_virtualenvs))
          )
        )}
      '' +
      (lib.strings.concatStrings
        (builtins.attrValues (builtins.mapAttrs (name: value: ''
          ${pyenv_cmd} virtualenv ${getVer value.ver} ${name} || true
          ${config.xdg.dataHome}/pyenv/versions/${name}/bin/pip install -q ${
            lib.strings.concatStrings (lib.strings.intersperse " " value.packages)
          }
        '') py_virtualenvs))) +
      (lib.strings.concatStrings
        (builtins.attrValues (builtins.mapAttrs (name: value: ''
          [ ! -d "${name}" ] && mkdir -p "${name}"
          echo "${join " " (builtins.map getVer value)}" > "${name}/.python-version"
        '') py_locals))
      ) +
      ''
        ${pyenv_cmd} global ${getVer py_global}
        unset PYENV_ROOT LATEST_VER
      ''
    );
  };
  programs.pyenv = {
    enable = true;
    package = pyenv;
    rootDirectory = "${config.xdg.dataHome}/pyenv";
  };
  home.packages = [ pyenv ];
  programs.zsh.initExtra = ''
    # related issue: https://github.com/pyenv/pyenv/pull/1644
    . ${pyenv}/share/zsh/site-functions/_pyenv
  '';
}
