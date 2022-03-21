# antigen
export ADOTDIR=$XDG_DATA_HOME/antigen
export ANTIGEN_LOG=$ADOTDIR/antigen.log
export ANTIGEN_LOCK=$ADOTDIR/.lock

if [[ ! -d $APP_HOME/antigen ]]; then
	git clone https://github.com/zsh-users/antigen.git $APP_HOME/antigen
fi

if [[ ! -d $ADOTDIR ]]; then
	mkdir -p $ADOTDIR
fi
echo ${(k)aliases} > $ADOTDIR/aliases_to_keep
source $APP_HOME/antigen/antigen.zsh
plugins=(
	'ohmyzsh/ohmyzsh plugins/git'
	'ohmyzsh/ohmyzsh plugins/docker'
	'ohmyzsh/ohmyzsh plugins/yarn'
	'ohmyzsh/ohmyzsh plugins/pip'
	'ohmyzsh/ohmyzsh plugins/perl'
	'ohmyzsh/ohmyzsh plugins/npm'
	'ohmyzsh/ohmyzsh plugins/golang'
	'ohmyzsh/ohmyzsh plugins/gem'
	'ohmyzsh/ohmyzsh plugins/rvm'
	"$ZDOTDIR --loc=unalias.zsh --no-local-clone"
	${(k)plugins}
	'ellie/atuin --branch=main'
	'marlonrichert/zsh-autocomplete --branch=main'
	hlissner/zsh-autopair
	zpm-zsh/clipboard
	'm42e/zsh-histdb-skim --branch=main' # TODO: customize
	'BlaineEXE/zsh-cmd-status --branch=main'
	RobSis/zsh-completion-generator # requires python
	larkery/zsh-histdb
	'ohmyzsh/ohmyzsh plugins/fd'
	'ohmyzsh/ohmyzsh plugins/emoji-clock'
	'ohmyzsh/ohmyzsh plugins/ripgrep'
	'ohmyzsh/ohmyzsh plugins/battery'
	'ohmyzsh/ohmyzsh plugins/command-not-found'
	'catppuccin/zsh-syntax-highlighting themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh --branch=main'
	zsh-users/zsh-syntax-highlighting
	'axililsz/zsh-stderr-highlighting --branch=main'
	arzzen/calc.plugin.zsh
	clarketm/zsh-completions
)

for plugin in "${plugins[@]}"; do
	antigen bundle $plugin
done

antigen theme romkatv/powerlevel10k

export ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
# some omz plugins use the folder. need to set `$ZSH_CACHE_DIR` by hand
# alternatively could try `source oh-my-zsh.sh`, carefully...
[[ ! -d "$ZSH_CACHE_DIR/completions" ]] && mkdir -p "$ZSH_CACHE_DIR/completions"

antigen apply
antigen update
autoload -Uz add-zsh-hook
# antigen
. $ZDOTDIR/p10k.zsh


# marlonrichert/zsh-autocomplete
zstyle ':autocomplete:*' insert-unambiguous yes
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char


export COMPLETION_ROOT=$XDG_DATA_HOME/zsh-complete
[ ! -d "$COMPLETION_ROOT" ] && mkdir $COMPLETION_ROOT
[ ! -f "$COMPLETION_ROOT/_rustup" ] && command -v rustup >/dev/null && rustup completions zsh > $COMPLETION_ROOT/_rustup
completion_urls=(
	'https://raw.githubusercontent.com/jupyter/jupyter_core/main/examples/completions-zsh'
	'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh'
)
completion_names=(
	'jupyter'
	'git'
)
for (( i=1; i<=${#completion_urls[*]}; ++i)); do
	if [ ! -f "$COMPLETION_ROOT/_${completion_names[$i]}" ]; then
        wget "${completion_urls[$i]}" -O "$COMPLETION_ROOT/_${completion_names[$i]}"
	fi
done
fpath=($COMPLETION_ROOT $fpath)
