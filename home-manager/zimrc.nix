{ lib, pkgs, config, inputs, ... }: let
  zim_home = "${config.xdg.dataHome}/zim";
  writePlugin = name: text: pkgs.writeTextFile {
    inherit text;
    name = "my-zsh-plugin-${name}";
    destination = "/init.zsh";
  };
  my-zimfw-plugins = {
    atuin = writePlugin "atuin" ''
      local FOUND_ATUIN=$+commands[atuin]

      if [[ $FOUND_ATUIN -eq 1 ]]; then
        # https://docs.atuin.sh/configuration/key-binding/
        # source <(atuin init zsh)
        source <(atuin init zsh --disable-up-arrow)
      fi
    '';
    keep-aliases = idx: writePlugin "keep-aliases" ''
      echo ''${(k)aliases} > $ZIM_HOME/aliases_to_keep_${toString idx}
    '';
    unalias = idx: writePlugin "unalias" ''
      local file="''${ZIM_HOME:?}/aliases_to_keep_${toString idx}"
      [ ! -f "$file" ] && return 1
      local aliases_to_keep=$(cat "$file")
      aliases_to_keep=(''${(@s: :)aliases_to_keep})
      # echo ''${(k)aliases_to_keep}
      for a in ''${(k)aliases}; do
        if [ -n "$a" ] && ! (($aliases_to_keep[(Ie)$a])); then
          # echo "unalias $a"
          unalias $a
        fi
      done
      rm "$file"
    '';
    rbenv = writePlugin "rbenv" ''rbenv rehash'';
    mise = writePlugin "mise" ''
      # rustup is installed with nix, so mise path has to be after nix path
      export PATH="$PATH:$XDG_DATA_HOME/mise/shims"
    '';
    rust = writePlugin "rust" ''
      export RUSTUP_HOME=$XDG_DATA_HOME/rustup
      export CARGO_HOME=$XDG_DATA_HOME/cargo
      # mise uses asdf-rust, which sets these env vars. Be careful not to make problems.
      # [ -f "$CARGO_HOME/env" ] && . "$CARGO_HOME/env" # after mise to override PATH
    '';
  };
  zimfw-plugins = [
    "RobSis/zsh-completion-generator" # before compinit
    "clarketm/zsh-completions"
    # order?

    "Aloxaf/fzf-tab"
    # after compinit (but doesn't seem to cause problems if before);
    # before wraping widgets (zsh-autosuggestions, f-sy-h)
    # not working after f-sy-h; conflicting with `_zsh_highlight` ?

    { zmodule = "z-shell/F-Sy-H"; branch = "main"; }
    # if placed before `zsh-autocomplete` and `fzf-tab`, widgets defined there won't get highlighted.
    # if after `zsh-autocomplete`, will complain unrecognized widgets (may be fine)

    { zmodule = "marlonrichert/zsh-autocomplete"; branch = "main"; } # this does compinit
    # detects `_zsh_highlight_widget_orig...`, should be fine after `F-Sy-H` ?
    # needs INTERACTIVECOMMENTS; https://github.com/marlonrichert/zsh-autocomplete/issues/724

    # 'zsh-users/zsh-history-substring-search'
    "zsh-users/zsh-autosuggestions"

    "larkery/zsh-histdb"
    # { zmodule = "m42e/zsh-histdb-skim"; branch = "main"; }
    # { zmodule = "ellie/atuin"; branch = "main"; } # atuin is installed with flake
    "${my-zimfw-plugins.atuin}" # to disable arrow key bindings
    # zsh-users/zsh-syntax-highlighting
    # 'catppuccin/zsh-syntax-highlighting themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh --branch main' # hl theme
    { zmodule = "hlissner/zsh-autopair"; }

    { zmodule = "Sam-programs/zsh-calc"; }
    { zmodule = "zpm-zsh/clipboard"; } # helpers functions: clip open pbcopy pbpaste"
    { zmodule = "BlaineEXE/zsh-cmd-status"; branch = "main"; source = "cmd-status.plugin.zsh"; } # print return code & duration"

    # <----------
    # unalias the aliases defined between `keep_aliases` and `unalias`
    "${my-zimfw-plugins.keep-aliases 1}"
    # also completions
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/deno"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/docker"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/golang"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/npm"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/pip"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/pipenv"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/pylint"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/yarn"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/gem"; }
    # also functions
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/git"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/perl"; }

    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/rbenv"; }
    "${my-zimfw-plugins.rbenv}" # rehash
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/rvm"; }
    # above are plugins that defines aliases I don't want
    "${my-zimfw-plugins.unalias 1}"
    # ---------->

    # completions
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/autopep8"; fpath = "."; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/bun"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/nvm"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/pep8"; fpath = "."; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/poetry"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/redis-cli"; fpath = "."; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/cpanm"; fpath = "."; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/cabal"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/stack"; }
    # functions
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/battery"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/command-not-found"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/emoji"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/emoji-clock"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/ssh"; }
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/ssh-agent"; }

    # PATH override order: micromamba (by home-manager) < mise < pyenv/rust;
    # 'ohmyzsh/ohmyzsh --root plugins/mise'
    "${my-zimfw-plugins.mise}"
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/pyenv"; }
    "${my-zimfw-plugins.rust}"
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/rust"; } # completions for cargo, rustup, rustc; need rustup&cargo on PATH"
    { zmodule = "ohmyzsh/ohmyzsh"; root = "plugins/z"; }
  ];
  zmodule = mod:
    if builtins.isString mod
    then "zmodule ${mod}"
    else let
      special_options = ["name" "root"];
    in lib.strings.concatStringsSep " "
      (builtins.filter
        (elem: elem != "")
        ([ "zmodule ${mod.zmodule}" ] ++
          (map (attr: (if builtins.hasAttr attr mod then "--${attr} ${mod.${attr}}" else "")) special_options) ++
          lib.attrsets.mapAttrsToList
            (name: value: "--${name} ${value}")
            (removeAttrs mod ([ "zmodule" ] ++ special_options))));
  zimrc = pkgs.writeText "zimrc.zsh" (lib.strings.concatStringsSep "\n" (map zmodule zimfw-plugins));
in {
  home.sessionVariables = {
    ZIM_ROOT = "${inputs.zimfw}";
  };
  programs.zsh = {
    # mkAfter = mkOrder 1500
    initContent = lib.mkOrder 990 ''
      # export in `.zshrc` so every new shell gets the correct paths
      # `home.sessionVariables` are in `zprofile`
      export ZIM_CONFIG_FILE=${zimrc}
      export ZIM_HOME=${zim_home}
      # zstyle ':zim:zmodule' use 'degit'
      if [[ ! -d ${zim_home} ]]; then
        mkdir -p ${zim_home}
      fi
      if [[ ! -f ${zim_home}/init.zsh ]]; then
        # ${zimrc} nix-store doesn't keep create time;
        # so we have to delete `init.zsh` upon activation and re-compile the next login
        ${lib.getExe pkgs.zsh} ${inputs.zimfw}/zimfw.zsh init -v
      fi
    '';
  };
}
