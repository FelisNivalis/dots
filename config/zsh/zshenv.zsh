export BYOBU_CONFIG_DIR=$XDG_CONFIG_HOME/byobu

# https://discourse.nixos.org/t/where-is-nix-path-supposed-to-be-set/16434/10
# https://github.com/NixOS/nixpkgs/issues/149791
export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$XDG_STATE_HOME/nix/defexpr/channels
export NIX_CONF_DIR=$XDG_CONFIG_HOME

# Below are for desktop environments
# should match `/etc/xrdp/sesman.ini`
export XAUTHORITY=${XDG_CONFIG_HOME:-$HOME/.config}/Xsession/.Xauthority

export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
# ~/.shiv
export SHIV_ROOT="$XDG_DATA_HOME/shiv"

# ~/.cache
export QML_DISK_CACHE_PATH="$XDG_CACHE_HOME/qmlcache"
export KDE_PREP_CACHE="$XDG_CACHE_HOME/KDE"

# /etc/X11/Xsession
export ERRFILE=${XDG_DATA_HOME:-$HOME/.local/share}/Xsession/xsession-errors

# gnupg
export GNUPGHOME=$XDG_CONFIG_HOME/gnupg

# ICEauthority
export ICEAUTHORITY=$XDG_DATA_HOME/ICEauthority

# less
export LESSHISTFILE="$XDG_CONFIG_HOME/less/history"
export LESSKEY="$XDG_CONFIG_HOME/less/keys"

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine
