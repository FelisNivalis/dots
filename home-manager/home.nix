{ lib, config, username, ... }: rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = /home/${username};

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  home.activation = {
    # `[[ file1 -nt file2 ]]` not working for symlinks.
    # so just delete the `.zwc` files...
    clearZDotDirCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ -n "''${ADOTDIR:-}" ]] && [[ -f "$ADOTDIR/init.zsh" ]]; then
        run rm -fv "$ADOTDIR/init.zsh" # use `run` instead of `$DRY_RUN_CMD` for hm > 23.11
      fi
      if [[ -n "''${ZDOTDIR:-}" ]]; then
        run rm -fv "$ZDOTDIR/.zcompdump" "$ZDOTDIR/.*.zwc" "$ZDOTDIR/*.zwc"
      fi
    '';
    profileZshEnv = let
      zDotDir = "${config.home.homeDirectory}/${config.programs.zsh.dotDir}";
    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      file=$HOME/.profile
      if [[ -w "$file" ]] && ! grep 'zshenv' $file >/dev/null; then
        # sed -i --follow-symlinks -e ':a;/[^\s]/{H;1{x;s/^\n//;x};$!{d;ba}};x;/\. "\$HOME\/\.zshenv"/d' $file
        echo "" >> $file
        # `$HOME/.zshenv` says `source ...`, which doesn't work with Bourne shell
        echo '. "${zDotDir}/.zshenv"' >> $file
      fi
      unset file
    '';
    ensureUserDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      . ${config.xdg.configHome}/user-dirs.dirs
      for name in DESKTOP DOCUMENTS DOWNLOAD MUSIC PICTURES PUBLICSHARE TEMPLATES VIDEOS; do
        dir=$(eval echo \''${XDG_''${name}_DIR})
        if [ -n "$dir" ] && [ ! -d "$dir" ]; then
          run mkdir -pv "$dir"
        fi
      done
      unset dir
    '';
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/xdg/var/cache";
    configHome = "${config.home.homeDirectory}/xdg/etc";
    dataHome = "${config.home.homeDirectory}/xdg/usr/share";
    stateHome = "${config.home.homeDirectory}/xdg/var/lib";
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "${config.xdg.configHome}" = {
      source = ./../config;
      recursive = true;
    };
    "${home.sessionVariables.XDG_BIN_HOME}" = {
      source = ./../bin;
      recursive = true;
    };
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/user99/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    XDG_BIN_HOME = "${config.home.homeDirectory}/xdg/bin";
    APP_HOME = "${config.home.homeDirectory}/applications";
    PROJECT_HOME = "${config.home.homeDirectory}/projects";
    MYDOTDIR = "${config.home.homeDirectory}/projects/dotfiles";
  };
}
