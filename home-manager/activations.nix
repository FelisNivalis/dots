{ lib, config, ... }: {
  home.activation = {
    # dirty things
    chsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      /usr/bin/grep $XDG_STATE_HOME/nix/profile/bin/zsh /etc/shells >/dev/null || /usr/bin/sudo sh -c "echo $XDG_STATE_HOME/nix/profile/bin/zsh >> /etc/shells"
      [ $(/usr/bin/getent passwd $USER | /usr/bin/rev | /usr/bin/cut -d: -f1 | /usr/bin/rev) = "$XDG_STATE_HOME/nix/profile/bin/zsh" ] || /usr/bin/chsh -s $XDG_STATE_HOME/nix/profile/bin/zsh
    '';
    # copyEtc = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   /usr/bin/sudo cp -r "${./../etc}" /etc
    # '';
    jupyterKernels = let
      pyenv_root = config.programs.pyenv.rootDirectory;
      path = ''PATH=/usr/bin:${pyenv_root}/shims:${config.xdg.dataHome}/mise/shims'';
    in lib.hm.dag.entryAfter ["ensureMise" "ensurePyenv"] ''
      . ${pyenv_root}/versions/playground/bin/activate
      # `ijavascript` invokes `jupyter kernelspec install`
      (${pyenv_root}/shims/jupyter-kernelspec list | /usr/bin/grep javascript >/dev/null) || \
      ${path} ijsinstall

      # https://github.com/evcxr/evcxr/blob/main/evcxr_jupyter/README.md
      # `evcxr` doesn't recognise `:` in `JUPYTER_PATH`. Let's just install to the default path, `$XDG_DATA_HOME/jupyter`
      (${pyenv_root}/shims/jupyter-kernelspec list | /usr/bin/grep rust > /dev/null) || \
      (unset JUPYTER_PATH; ${path} evcxr_jupyter --install)
      deactivate
    '';
  };
}
