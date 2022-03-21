nvim() {
  pyenv-install-if-not-exists
  if [ ! -d "$PYENV_ROOT/versions/neovim" ]; then
    echo "Installing Python provider..."
    pyenv virtualenv $(pyenv global 2>/dev/null) neovim
    "$PYENV_ROOT/versions/neovim/bin/pip" install neovim
  fi

  [ $(rbenv global) = "system" ] && rbenv-install-latest
  if [ ! -d "$RBENV_ROOT/versions/$(rbenv global 2>/dev/null)/gemsets/neovim" ]; then
    echo "Installing Ruby provider..."
    rbenv gemset create $(rbenv global 2>/dev/null) neovim
    RBENV_GEMSETS=neovim gem install neovim
    # rbenv-gemset doesn't rehash
    rbenv rehash
  fi

  local _ver=$(plenv install --list | grep -v - | sed -n 's/^[ \t]*//;s/[ \t]*$//;/[0-9]\+\.[0-9]\+\.[0-9]\+/p' | head -n 1)
  if [ -d "$PLENV_ROOT/versions/neovim" ] && [ ! -f "$PLENV_ROOT/versions/neovim/bin/perl$_ver" ]; then # not latest version
    echo "Detected latest Perl version: $_ver. (current: $(realpath "$PLENV_ROOT/versions/neovim/bin/perl" | sed "s/^.*perl//"))"
    plenv uninstall -f neovim
  fi
  if [ ! -d "$PLENV_ROOT/versions/neovim" ]; then
    echo "Installing Perl environment..."
    plenv install "$_ver" --as neovim
    PLENV_VERSION=neovim plenv install-cpanm
  fi
  if [ ! -d /home/feles/.local/share/plenv/versions/neovim/lib/perl"$(echo "$_ver" | cut -b 1)"/site_perl/"$_ver"/Neovim ]; then
    echo "Installing Perl provider..."
    PLENV_VERSION=neovim plenv install-cpanm
    PLENV_VERSION=neovim cpanm -n Neovim::Ext
  fi

  command nvim $@
}
pyenv-install-if-not-exists() {
  [ $(pyenv global) = "system" ] && pyenv-install-latest
}
pyenv-install-latest() {
  _ver=$(pyenv latest -k 3)
  if ! pyenv versions --bare | grep $_ver >/dev/null; then
    pyenv-install $_ver
  fi
  pyenv global $_ver
}
rbenv-install-latest() {
  _ver=$(rbenv install --list | grep -v - | tail -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
  if ! rbenv versions --bare | grep $_ver >/dev/null; then
    rbenv-install $_ver
  fi
  rbenv global $_ver
}
luaenv-install() {
  luaenv install $1
  LUAENV_VERSION=$1 luaenv luarocks
}
luaenv-install-latest() {
  _ver=$(luaenv install --list | grep -v - | tail -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
  if ! luaenv versions --bare | grep $_ver >/dev/null; then
    luaenv-install $_ver
  fi
  luaenv global $_ver
}
mise-install-all() {
  mise deactivate >/dev/null 2>&1
  local __mise=$(which mise)
  local __tmp=$(mktemp -d)
  ln -s $__mise $__tmp # some npm packages needs mise, link to a temp folder
  if $__mise ls --global >/dev/null 2>&1 && [ -z "$($__mise ls --global --missing --no-header)" ]; then
    echo "All mise packages are already installed."
  else
    echo "Installing mise packages..."
    # npm needs bash, so have to include `/usr/bin`
    # mise will only append paths of the tools to be installed. setting $PATH to force use the mise ones.
    local __path=$XDG_DATA_HOME/mise/shims:/usr/bin:$__tmp
    eval "$($__mise activate 2>/dev/null)"
    # we're in a script, so need to run the hook manually
    eval "$($__mise --cd $HOME hook-env -s zsh)"
    # https://github.com/asdf-community/asdf-nim creates a `tmp/nim/${ver}` folder inside `ASDF_DATA_DIR`
    # although the tool cleans up the folder, the upper levels (`ASDF_DATA_DIR`, `tmp`, `nim`) are not removed.
    ASDF_DATA_DIR=$__tmp PATH=$__path $__mise --cd $HOME install --verbose --yes && \
    PATH=$__path $__mise --cd $HOME upgrade --yes && \
    PATH=$__path $__mise --cd $HOME prune --yes && \
    $__mise reshim
    local _ret=$?
    eval "$($__mise deactivate 2>/dev/null)"
    return $_ret
    # pipx creates venvs with some python version
    # if the version is later deleted, mise won't check if the venv still exists.
    # and the venvs would be linking to a non-existing python.
  fi
}
install-completions() {
  # manually install completions
  completion_urls=(
    'https://raw.githubusercontent.com/jupyter/jupyter_core/main/examples/completions-zsh'
  )
  completion_names=(
    'jupyter'
  )
  for (( i=1; i<=${#completion_urls[*]}; ++i)); do
    # [ -f "$ZSH_COMPLETION_ROOT/_${completion_names[$i]}" ] || \
    wget "${completion_urls[$i]}" -O "$ZSH_COMPLETION_ROOT/_${completion_names[$i]}"
  done
  for i in juliaup; do
    # [ -f "$ZSH_COMPLETION_ROOT/_$i" ] || \
    ! command -v $i >/dev/null || \
    $i completions zsh > "$ZSH_COMPLETION_ROOT/_$i"
  done
  unset i completion_urls completion_names
}
install-all() {
  install-completions
  pyenv-install-latest
  rbenv-install-latest
  luaenv-install-latest
  mise-install-all
}
check-update-latest-git() {
  local RET
  RET=`gh api repos/$1/releases/latest --jq '.name' 2>/dev/null` || RET=`gh api repos/$1/tags --jq '.[0].name' 2>/dev/null` || RET=Unknown
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
