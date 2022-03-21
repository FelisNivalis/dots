setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY
setopt INTERACTIVECOMMENTS
setopt TRANSIENTRPROMPT
setopt GLOBDOTS # lets files beginning with a . be matched without explicitly specifying the dot

setopt PROMPT_SUBST
setopt PROMPT_BANG
setopt PROMPT_PERCENT

bindkey -v # vi
# bindkey -l / bindkey -M
ulimit -n 4096


# antigen
export ADOTDIR=$XDG_DATA_HOME/antigen
export ANTIGEN_LOG=$ADOTDIR/antigen.log
export ANTIGEN_LOCK=$ADOTDIR/.lock
[ -d "$ADOTDIR" ] || mkdir -p $ADOTDIR
source $ANTIGEN_ROOT/antigen.zsh
ZSH_PYENV_QUIET=true # so that omz/pyenv won't complain
GENCOMPL_PY=$(command -v python || command -v python3) # zsh-completion-generator; apt python package has exe `python3` but no `python`
_ANTIGEN_WARN_DUPLICATES=false # so that my `keep_aliases` / `unalias` pairs can be used multiple times
plugins=(
	RobSis/zsh-completion-generator # before compinit
	clarketm/zsh-completions
	# order?
	'z-shell/F-Sy-H --branch=main' # if placed before `zsh-autocomplete` and `fzf-tab`, widgets defined there won't get highlighted.
	# needs INTERACTIVECOMMENTS; https://github.com/marlonrichert/zsh-autocomplete/issues/724
	'marlonrichert/zsh-autocomplete --branch=main' # this does compinit
	'Aloxaf/fzf-tab' # after compinit, before wraping widgets (zsh-autosuggestions, f-sy-h)
	# 'zsh-users/zsh-history-substring-search'
	'zsh-users/zsh-autosuggestions'

	larkery/zsh-histdb
	# 'm42e/zsh-histdb-skim --branch=main'
	# 'ellie/atuin --branch=main'
	"$ZDOTDIR --loc=plugins/atuin.zsh --no-local-clone" # to disable arrow key bindings; TODO: switch filter_mode on the fly

	# zsh-users/zsh-syntax-highlighting
	# 'catppuccin/zsh-syntax-highlighting themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh --branch=main' # hl theme
	hlissner/zsh-autopair

	arzzen/calc.plugin.zsh
	zpm-zsh/clipboard # helpers functions: clip open pbcopy pbpaste
	'BlaineEXE/zsh-cmd-status --branch=main' # print return code & duration

	# <----------
	# unalias the aliases defined between `keep_aliases` and `unalias`
	"$ZDOTDIR --loc=plugins/keep_aliases.zsh --no-local-clone"
	# also completions
	'ohmyzsh/ohmyzsh plugins/deno'
	'ohmyzsh/ohmyzsh plugins/docker'
	'ohmyzsh/ohmyzsh plugins/golang'
	'ohmyzsh/ohmyzsh plugins/npm'
	'ohmyzsh/ohmyzsh plugins/pip'
	'ohmyzsh/ohmyzsh plugins/pipenv'
	'ohmyzsh/ohmyzsh plugins/pylint'
	'ohmyzsh/ohmyzsh plugins/yarn'
	'ohmyzsh/ohmyzsh plugins/gem'
	# also functions
	'ohmyzsh/ohmyzsh plugins/git'
	'ohmyzsh/ohmyzsh plugins/perl'

	'ohmyzsh/ohmyzsh plugins/rbenv'
	"$ZDOTDIR --loc=plugins/rbenv.zsh --no-local-clone" # rehash
	'ohmyzsh/ohmyzsh plugins/rvm'
	# above are plugins that defines aliases I don't want
	"$ZDOTDIR --loc=plugins/unalias.zsh --no-local-clone"
	# ---------->

	# completions
	'ohmyzsh/ohmyzsh plugins/autopep8'
	'ohmyzsh/ohmyzsh plugins/bun'
	'ohmyzsh/ohmyzsh plugins/fd'
	'ohmyzsh/ohmyzsh plugins/nvm'
	'ohmyzsh/ohmyzsh plugins/pep8'
	'ohmyzsh/ohmyzsh plugins/poetry'
	'ohmyzsh/ohmyzsh plugins/redis-cli'
	'ohmyzsh/ohmyzsh plugins/ripgrep'
	'ohmyzsh/ohmyzsh plugins/cpanm'
	'ohmyzsh/ohmyzsh plugins/cabal'
	'ohmyzsh/ohmyzsh plugins/stack'
	# functions
	'ohmyzsh/ohmyzsh plugins/battery'
	'ohmyzsh/ohmyzsh plugins/command-not-found'
	'ohmyzsh/ohmyzsh plugins/emoji'
	'ohmyzsh/ohmyzsh plugins/emoji-clock'
	'ohmyzsh/ohmyzsh plugins/ssh'
	'ohmyzsh/ohmyzsh plugins/ssh-agent'

	# PATH override order: micromamba (by home-manager) < mise < pyenv/rust;
	# 'ohmyzsh/ohmyzsh plugins/mise'
	"$ZDOTDIR --loc=plugins/mise.zsh --no-local-clone"
	'ohmyzsh/ohmyzsh plugins/pyenv'
	"$ZDOTDIR --loc=plugins/rust.zsh --no-local-clone"
	'ohmyzsh/ohmyzsh plugins/rust' # completions for cargo, rustup, rustc; need rustup&cargo on PATH
	'ohmyzsh/ohmyzsh plugins/z'
)

for plugin in "${plugins[@]}"; do
	antigen bundle $plugin
done
unset plugin plugins

export ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
export ZSH_COMPLETION_ROOT=$ZSH_CACHE_DIR/completions
# some omz plugins use the folder. need to set `$ZSH_CACHE_DIR` by hand
# or could try `source oh-my-zsh.sh`, carefully...?
[ ! -d "$ZSH_COMPLETION_ROOT" ] && mkdir -p "$ZSH_COMPLETION_ROOT"
fpath=($ZSH_COMPLETION_ROOT $fpath)

antigen apply


bindkey -v "^[[H"   beginning-of-line
bindkey -v "^[[F"   end-of-line
bindkey -v "^[[3~"  delete-char
bindkey -v '^?' backward-delete-char


autoload -Uz add-zsh-hook
add-one-time-zsh-hook() {
	local __hook=$1 __func=$2
	eval "$(echo "function __${__func}__one-time() {
		add-zsh-hook -d $__hook __${__func}__one-time
		$__func \$@
		unfunction $__func __${__func}__one-time
	}")"
	add-zsh-hook $__hook __"$__func"__one-time
}


# marlonrichert/zsh-autocomplete
if (( ${+_autocomplete__mods} )) 2>/dev/null; then # has zsh-autocomplete
	zstyle ':completion:*' completer _complete _autocomplete__recent_paths _expand _correct _approximate _complete:-fuzzy _prefix _ignored
	zstyle ":autocomplete:fzf-tab-*:" ignore true
	zstyle ':autocomplete:*' insert-unambiguous no
	# insert-unambiguous sometimes causes last char deleted e.g. test/123.abc test/1234.abc
	zstyle ':autocomplete:*' add-space '*'
	zstyle -e ':autocomplete::' list-lines 'reply=( $(( LINES / 2 )) )' # max lines for completion
	# `menu-select` wrapped below
	# bindkey              '^I' menu-select
	# bindkey "$terminfo[kcbt]" menu-select
	bindkey -M menuselect              '^I'         menu-complete
	bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
	bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
	bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char
	bindkey -M menuselect '^C' undo # exit
fi


# zsh-users/zsh-autosuggestions &&
# marlonrichert/zsh-autocomplete
if (( ${+_autocomplete__mods} )) 2>/dev/null && (( ${+ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE} )); then
	# clear autosuggestions for `menu-select` widget
	_autosuggest_bind_widget__clear() {
		for widget in ${__clear_widgets[@]}; do
			ZSH_AUTOSUGGEST_IGNORE_WIDGETS=${ZSH_AUTOSUGGEST_IGNORE_WIDGETS:#$widget} # remove `menu-select` from ignored widgets
			ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=($widget) # clear autosuggestions when `menu-select`
			# `zsh-autocomplete` sets `ZSH_AUTOSUGGEST_MANUAL_REBIND`, so `zsh-autosuggest` will hook precmd only once.
			# and we have to bind widget manually

			# `menu-select` widget is initilized in `zsh-autocomplete`'s precmd,
			# so we have to bind in precmd too.

			# call a completion widget from a `-N` widget will lose `$WIDGETSTYLE`
			# https://github.com/marlonrichert/zsh-autocomplete/blob/cfc3fd9a75d0577aa9d65e35849f2d8c2719b873/Functions/Init/.autocomplete__widgets#L38C38-L38C50
			# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
			# so bind `menu_select` won't work
			_zsh_autosuggest_bind_widget $widget clear
		done
		unset widget __clear_widgets
	}
	__clear_widgets=(clear-autosuggest)
	add-one-time-zsh-hook precmd _autosuggest_bind_widget__clear

	# instead, we bind a empty widget
	clear-autosuggest() {}
	zle -N clear-autosuggest

	# and define a new widget to wrap `menu-select`
	clear-autosuggest-and-menu-select() {
		zle clear-autosuggest
		zle menu-select -w
	}
	# this cannot be a completion widget. because a completion widget cannot e.g. modify `POSTDISPLAY`.
	zle -N clear-autosuggest-and-menu-select

	# then bind the new widget
	bindkey              '^I' clear-autosuggest-and-menu-select
	bindkey "$terminfo[kcbt]" clear-autosuggest-and-menu-select

	# P.S.
	# the trick here is to create a new widget,
	# what `zsh-autosuggest` does is equivalent to ```
	# 	# `zsh-autosuggest` has to use `-N` because of said above
	# 	# has to re-define `$widget` so that users don't have to modify their code.
	# 	zle -N $widget wrapper_func
	# 	zle -C orig_$widget ...
	# 	wrapper_func() {
	# 		clear-autosuggest
	# 		# cannot `-w` here because that will change `$WIDGET`
	# 		# but without `$WIDGET`, things like `$WIDGETSTYLE` will lose
	# 		zle orig_$widget
	# 	}
	# ```
fi


# Aloxaf/fzf-tab
if zle -l toggle-fzf-tab 2>/dev/null; then
	bindkey '^F' fzf-tab-complete
	zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

	# `fzf-tab` && `zsh-autocomplete`
	if zle -l menu-select 2>/dev/null; then
		# patch `autocomplete:_main_complete:new:post`
		# so that `fzf-tab` works with `zsh-autocomplete`

		# https://github.com/marlonrichert/zsh-autocomplete/blob/cfc3fd9a75d0577aa9d65e35849f2d8c2719b873/Functions/Init/.autocomplete__compinit#L104-L110
		__patch_autocomplete:_main_complete:new:post() {
			autocomplete:_main_complete:new:post() {
				# don't unfunction `fzf-tab`'s `compadd`
				# the code seems unnecessary since commit
				# https://github.com/marlonrichert/zsh-autocomplete/commit/6a80e62dd4a1c78e00932f9b02537b526ab2fcce
				# only `_approximate` patches `compadd` in the latest version

				# [[ $WIDGET != _complete_help ]] &&
				# 	unfunction compadd 2> /dev/null
				_autocomplete__unambiguous
				compstate[list_max]=0
				MENUSCROLL=0
			}
		}
		add-one-time-zsh-hook precmd __patch_autocomplete:_main_complete:new:post
	fi
fi


_remove_conda_prompt() {
	PS1=${PS1#$CONDA_PROMPT_MODIFIER} # I want $CONDA_PROMPT_MODIFIER, but don't want conda to mess with my $PS1
}
add-zsh-hook precmd _remove_conda_prompt


if zle -l atuin-up-search-viins 2>/dev/null; then
	atuin-only-when-empty-buffer() {
		if (( $#BUFFER == 0 )); then
			zle up-line-or-search;
		else
			zle atuin-up-search-viins;
		fi
	}
	zle -N atuin-only-when-empty-buffer
	bindkey "^[[A" atuin-only-when-empty-buffer
	bindkey "^[OA" atuin-only-when-empty-buffer
fi
