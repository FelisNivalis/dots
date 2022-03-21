export MULTIPLEXER=zellij # byobu / zellij
export BYOBU_CONFIG_DIR=$XDG_CONFIG_HOME/byobu

# https://discourse.nixos.org/t/where-is-nix-path-supposed-to-be-set/16434/10
# https://github.com/NixOS/nixpkgs/issues/149791
export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$XDG_STATE_HOME/nix/defexpr/channels
export NIX_CONF_DIR=$XDG_CONFIG_HOME
