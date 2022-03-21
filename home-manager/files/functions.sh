check-update-latest-git() {
  local RET
  RET=`gh api repos/$1/releases/latest --jq '.name + " " + .created_at' 2>/dev/null` || \
  RET="$(gh api repos/$1/tags --jq '.[0].name' 2>/dev/null) $(gh api repos/$1/commits/$(gh api repos/$1/tags --jq '.[0].commit.sha' 2>/dev/null) --jq '.commit.committer.date' 2>/dev/null)" || \
  RET=Unknown
  echo $RET
}
check-update() {
  echo "----------\n$1\n- latest:`check-update-latest-git $2`\n- current:$3"
}
check-updates() {
  mise ls --global
  check-update superfile MHNightCat/superfile "`superfile -v`"
  check-update mise jdx/mise "`mise version`"
  check-update xdg-ninja b3nj5m1n/xdg-ninja Unknown
  check-update atuin atuinsh/atuin "`atuin -V`"
  check-update neovim neovim/neovim "`nvim -v | head -n 1`"
  check-update micromamba mamba-org/mamba "`micromamba --version`"
  check-update starship starship/starship "`starship -V`"
  check-update antigen zsh-users/antigen "`antigen version`"
  check-update tpm tmux-plugins/tpm Unknown
}
install-completions() {
  # manually install completions
  local completion_urls=(
    'https://raw.githubusercontent.com/jupyter/jupyter_core/main/examples/completions-zsh'
  )
  local completion_names=(
    'jupyter'
  )
  for (( i=1; i<=${#completion_urls[*]}; ++i)); do
    [ -f "$ZSH_COMPLETION_ROOT/_${completion_names[$i]}" ] || \
    wget "${completion_urls[$i]}" -O "$ZSH_COMPLETION_ROOT/_${completion_names[$i]}"
  done
  for i in juliaup; do
    [ -f "$ZSH_COMPLETION_ROOT/_$i" ] || \
    ! command -v $i >/dev/null || \
    $i completions zsh > "$ZSH_COMPLETION_ROOT/_$i"
  done
}
install-all() {
  install-completions
  rustup show # rustup show will install latest if none was installed
  pyenv-install-latest
  rbenv-install-latest
  luaenv-install-latest
  mise-install-all
  nvim-install-env
}
