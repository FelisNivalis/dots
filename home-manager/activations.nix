{ lib, config, pkgs, ... }: {
  home.activation = {
    # `[[ file1 -nt file2 ]]` not working for symlinks.
    # so just delete the `.zwc` files...
    clearZDotDirCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ -n "''${ADOTDIR:-}" ]] && [[ -f "$ADOTDIR/init.zsh" ]]; then
        run rm -fv "$ADOTDIR/init.zsh" # use `run` instead of `$DRY_RUN_CMD` for hm > 23.11
      fi
      if [[ -n "''${ZDOTDIR:-}" ]]; then
        run rm -fv "$ZDOTDIR/.zcompdump" "$ZDOTDIR"/.*.zwc "$ZDOTDIR"/*.zwc
      fi
    '';

    # needs sudo
    chsh = lib.hm.dag.entryAfter ["installPackages"] ''
      /usr/bin/grep $XDG_STATE_HOME/nix/profile/bin/zsh /etc/shells >/dev/null || /usr/bin/sudo sh -c "echo $XDG_STATE_HOME/nix/profile/bin/zsh >> /etc/shells"
      [ $(/usr/bin/getent passwd $USER | /usr/bin/rev | /usr/bin/cut -d: -f1 | /usr/bin/rev) = "$XDG_STATE_HOME/nix/profile/bin/zsh" ] || /usr/bin/chsh -s $XDG_STATE_HOME/nix/profile/bin/zsh
    '';
  };
}
