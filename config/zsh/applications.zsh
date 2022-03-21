export MANPATH="/usr/local/man:$MANPATH"

export PATH=$XDG_BIN_HOME:$PATH

if [[ ! -d "$XDG_DATA_HOME/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tpm
fi

# `DISPLAY=:x` uses wslg; `DISPLAY=host.docker.internal:x` uses X11
# wslg works well with GUI apps, without VcXsrv,
# but running a desktop environment e.g. gnome/KDE
# only works when VcXsrv is running with "One large window"
# and with `XDG_SESSION_TYPE=x11`.
export DISPLAY=:0
export XAUTHORITY=${XDG_CONFIG_HOME:-$HOME/.config}/.Xauthority
if [[ $(grep -i WSL /proc/version) ]] && [[ -f "${XDG_BIN_HOME:-$HOME/.local/bin}/firefox.exe" ]]; then
    export BROWSER="${XDG_BIN_HOME:-$HOME/.local/bin}/firefox.exe"
fi

export SQLITE_HISTORY=${XDG_DATA_HOME:-$HOME/.local/share}/.sqlite_history

export WGETRC=${XDG_CONFIG_HOME}/wgetrc

export CONDA_ROOT=$APP_HOME/miniconda3
if [[ -d "$CONDA_ROOT" ]]; then
    export CONDARC=${XDG_CONFIG_HOME}/condarc
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('$CONDA_ROOT/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$CONDA_ROOT/etc/profile.d/conda.sh" ]; then
            . "$CONDA_ROOT/etc/profile.d/conda.sh"
        else
            export PATH="$CONDA_ROOT/bin:$PATH"
        fi
    fi
    unset __conda_setup

    if [ -f "$CONDA_ROOT/envs/tools/etc/profile.d/mamba.sh" ]; then
        . "$CONDA_ROOT/envs/tools/etc/profile.d/mamba.sh"
    fi
    # <<< conda initialize <<<
    if [ -f "$CONDA_EXE" ]; then
        conda activate --stack base
        (conda env list | grep tools) && conda activate --stack tools
    fi
    plugins+=('conda-incubator/conda-zsh-completion')
fi

# pyenv # after conda so overwrite its path
if command -v pyenv >/dev/null; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    pyenv_plugins=()
    for plugin in $pyenv_plugins; do
        if [[ ! -d $(pyenv root)/plugins/$plugin ]]; then
            git clone https://github.com/pyenv/$plugin.git $(pyenv root)/plugins/$plugin
        fi
    done
    unset pyenv_plugins
    # `home-manager` will handle ...
    # eval "$(pyenv init -)"
    # the omz plugin will handle ...
    # eval "$(pyenv virtualenv-init -)"
    plugins+=('ohmyzsh/ohmyzsh plugins/pyenv')
fi
export PYTHON_HISTORY="$XDG_DATA_HOME/python/.python_history" # only >=3.13

# pipenv
export PIPENV_IGNORE_VIRTUALENVS=1

export PIPX_BIN_DIR=$XDG_BIN_HOME
export PIPX_MAN_DIR=$XDG_DATA_HOME/man
pack=register-python-argcomplete
if ! command -v $pack >/dev/null && command -v pipx > /dev/null; then
    pipx install argcomplete
fi
# completions https://pipx.pypa.io/stable/installation/
if command -v $pack >/dev/null; then
    eval "$($pack pipx)"
fi
unset pack

export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
jupyter_path=(
    # "$PYENV_ROOT/versions/playground/share/jupyter"
    "$XDG_DATA_HOME/jupyter"
    "$CONDA_ROOT/envs/jupyter-kernels/share/jupyter"
)
export JUPYTER_PATH=${(j.:.)jupyter_path}
unset jupyter_path

export NVM_DIR="$XDG_DATA_HOME/nvm"
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
plugins+=('ohmyzsh/ohmyzsh plugins/nvm')
[ -d "$HOME/.local/npm/node_modules" ] && export PATH="$PATH:$HOME/.local/npm/node_modules/.bin"
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history


export RUSTUP_HOME=$APP_HOME/rust/rustup
export CARGO_HOME=$XDG_DATA_HOME/cargo
[ -f "$CARGO_HOME/env" ] && . "$CARGO_HOME/env"
plugins+=('ohmyzsh/ohmyzsh plugins/rust')


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$APP_HOME/sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"


# export GHCUP_USE_XDG_DIRS=1
export GHCUP_INSTALL_BASE_PREFIX=$APP_HOME/haskell
export CABAL_DIR="$GHCUP_INSTALL_BASE_PREFIX/cabal"
export STACK_ROOT="$GHCUP_INSTALL_BASE_PREFIX/stack"
[ -f "$GHCUP_INSTALL_BASE_PREFIX/.ghcup/env" ] && source "$GHCUP_INSTALL_BASE_PREFIX/.ghcup/env" # ghcup-env
plugins+=('ohmyzsh/ohmyzsh plugins/cabal')


export GOPATH=$APP_HOME/golang/gopath
export PATH="$PATH:$APP_HOME/golang/go/bin:$GOPATH/bin"


export PERLBREW_ROOT="$APP_HOME/perl5/perlbrew"
export PERLBREW_HOME="$XDG_CONFIG_HOME/perlbrew"
export PERL_CPANM_HOME="$XDG_DATA_HOME/cpanm"
[ -f "$PERLBREW_ROOT/etc/bashrc" ] && source $PERLBREW_ROOT/etc/bashrc
plugins+=('ohmyzsh/ohmyzsh plugins/cpanm')


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export rvm_path=$APP_HOME/ruby/rvm
export PATH="$PATH:$rvm_path/bin"
[ -s "$rvm_path/scripts/rvm" ] && source "$rvm_path/scripts/rvm" # Load RVM into a shell session *as a function*


export JULIA_DEPOT_PATH="$XDG_DATA_HOME/julia:$JULIA_DEPOT_PATH"
# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in *:$APP_HOME/julia/juliaup/bin:*);; *)
    export PATH=$APP_HOME/julia/juliaup/bin${PATH:+:${PATH}};;
esac

# <<< juliaup initialize <<<

# mise
eval "$(mise activate zsh)"

export LUAENV_ROOT="$APP_HOME/lua/luaenv"
export PATH="$LUAENV_ROOT/bin:$PATH"
command -v luaenv >/dev/null && eval "$(luaenv init -)"


export ASDF_DIR=$APP_HOME/asdf
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/asdfrc"
export ASDF_DATA_DIR="${XDG_DATA_HOME}/asdf"
fpath=(${ASDF_DIR}/completions $fpath)
[ -f "$ASDF_DIR/asdf.sh" ] && . $ASDF_DIR/asdf.sh
plugins+=('ohmyzsh/ohmyzsh plugins/asdf')


export KERL_BASE_DIR=${XDG_CACHE_HOME}/kerl
export KERL_CONFIG=${XDG_CONFIG_HOME}/kerlrc

# home directory todo: `.local/state/wireplumber`, `.gtkrc-2.0`, `.pcsc10`
# https://superuser.com/questions/874901/what-are-the-step-to-move-all-your-dotfiles-into-xdg-directories
