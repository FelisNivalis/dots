local FOUND_ATUIN=$+commands[atuin]

if [[ $FOUND_ATUIN -eq 1 ]]; then
  # https://docs.atuin.sh/configuration/key-binding/
  # source <(atuin init zsh)
  source <(atuin init zsh --disable-up-arrow)
fi
