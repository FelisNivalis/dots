export HISTFILE=${ZDOTDIR:-$HOME}/.histfile
export HISTDB_FILE="${ZDOTDIR:-$HOME}/.histdb/zsh-history.db"

export HISTSIZE=1000000000
export SAVEHIST=1000000000
export HIST_STAMPS="mm/dd/yyyy"

export PATH=$XDG_BIN_HOME:$PATH

# `DISPLAY=:x` uses wslg; `DISPLAY=host.docker.internal:x` uses X11
# wslg works well with GUI apps, without VcXsrv,
# but running a desktop environment e.g. gnome/KDE
# only works when VcXsrv is running with "One large window"
# and with `XDG_SESSION_TYPE=x11`.
export DISPLAY=:0
if grep WSL /proc/version >/dev/null; then
    export WIN_USER="$(echo "$(/mnt/c/Windows/system32/cmd.exe /c echo %USERNAME% 2>/dev/null)" | tr -d '[:space:]')"
    export XAUTHORITY="/mnt/c/Users/$WIN_USER/.Xauthority"
    export BROWSER=$(command -v "firefox.exe")
else
    export XAUTHORITY=${XDG_CONFIG_HOME:-$HOME/.config}/.Xauthority
fi

export SQLITE_HISTORY=${XDG_DATA_HOME:-$HOME/.local/share}/.sqlite_history
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export WGETRC=${XDG_CONFIG_HOME}/wgetrc
export SHIV_ROOT="$XDG_CACHE_HOME"/shiv # used by pipx
export ZSHZ_DATA="$XDG_DATA_HOME"/z
export ASDF_DATA_DIR="$XDG_DATA_HOME"/asdf

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine

export JULIAUP_DEPOT_PATH=$XDG_DATA_HOME/julia
export JULIA_DEPOT_PATH=$XDG_DATA_HOME/julia

export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history

export GOPATH=$XDG_DATA_HOME/go

# micromamba
export MAMBA_ROOT_PREFIX=$XDG_DATA_HOME/conda
export CONDARC=$XDG_CONFIG_HOME/condarc # also works for micromamba

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYTHON_HISTORY="$XDG_DATA_HOME/python/.python_history" # only >=3.13
export PIPENV_IGNORE_VIRTUALENVS=1
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"

export PERL_CPANM_HOME="$XDG_CACHE_HOME/cpanm"

# until https://github.com/sestrella/asdf-ghcup/pull/39 is merged,
export GHCUP_INSTALL_BASE_PREFIX="$XDG_DATA_HOME/ghcup"
# until mise supports a ghc backend,
export CABAL_DIR="$XDG_DATA_HOME/cabal" # https://cabal.readthedocs.io/en/3.4/installing-packages.html#environment-variables
export STACK_ROOT="$XDG_DATA_HOME/stack" # https://docs.haskellstack.org/en/v2.15.7/stack_root/

if command -v xdg-user-dirs-update >/dev/null; then
    for name in DESKTOP DOCUMENTS DOWNLOAD MUSIC PICTURES PUBLICSHARE TEMPLATES VIDEOS; do
        xdg_path=$HOME/My/${name[1]}${(L)name[2,-1]}
        if [ ! -d "$xdg_path" ]; then
            mkdir -pv "$xdg_path"
        fi
        xdg-user-dirs-update --set $name $xdg_path
    done
    [ -d "$APP_HOME" ] || mkdir -pv "$APP_HOME"
    [ -d "$PROJECT_HOME" ] || mkdir -pv "$PROJECT_HOME"
    xdg-user-dirs-update --set APPLICATIONS $APP_HOME
    xdg-user-dirs-update --set CODE $PROJECT_HOME
    unset name xdg_path
    . $XDG_CONFIG_HOME/user-dirs.dirs
    for name in DESKTOP DOCUMENTS DOWNLOAD MUSIC PICTURES PUBLICSHARE TEMPLATES VIDEOS APPLICATIONS CODE; do
        export XDG_${name}_DIR
    done
fi

alias ls=lsd
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER="less -R --use-color -Dd+y -Du+c -DE+r"
