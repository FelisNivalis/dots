#!/usr/bin/env bash

export XDG_STATE_HOME=$HOME/.local/state \
	NIX_CONFIG=$'use-xdg-base-directories = true\nexperimental-features = nix-command flakes' \
	NIX_PATH=$XDG_STATE_HOME/nix/defexpr/channels
sh <(curl -L https://nixos.org/nix/install) --no-daemon --no-modify-profile
. $XDG_STATE_HOME/nix/profile/etc/profile.d/nix.sh # to have `nix` in `$PATH`

nix build 'github:felisnivalis/dots/main?dir=home-manager#homeConfigurations."feles@ubuntu-wsl".activationPackage' \
	--out-link $XDG_STATE_HOME/hm-build --refresh --no-write-lock-file

nix build 'github:felisnivalis/dots/main?dir=home-manager#systemConfigs.default' \
	--out-link $XDG_STATE_HOME/sm-build --refresh --no-write-lock-file

nix-collect-garbage -d
