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


ZSH_PYENV_QUIET=true # so that omz/pyenv won't complain
GENCOMPL_PY=$(command -v python || command -v python3) # zsh-completion-generator; apt python package has exe `python3` but no `python`

export ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
export ZSH_COMPLETION_ROOT=${ZSH_COMPLETION_ROOT:-$ZSH_CACHE_DIR/completions}
# some omz plugins use `$ZSH_CACHE_DIR/completions/_*`. `ZSH_COMPLETION_ROOT` is just for convenience.
# or could try `source oh-my-zsh.sh`, carefully...?
[ ! -d "$ZSH_COMPLETION_ROOT" ] && mkdir -p "$ZSH_COMPLETION_ROOT"
fpath=($ZSH_COMPLETION_ROOT $fpath)

source ${ZIM_HOME}/init.zsh


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
	export fpath=($fpath[@] ${ZIM_HOME?}/modules/ohmyzsh/plugins/z)
	zstyle ':completion:*' completer _complete _expand _correct _approximate _complete:-fuzzy _prefix _z `# _autocomplete__recent_paths` _ignored
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
# after `complete-word` widget when autocomplete is active
if zle -l toggle-fzf-tab 2>/dev/null; then
	bindkey '^F' fzf-tab-complete
	zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

	# `fzf-tab` && `zsh-autocomplete`
	if [[ -n $_autocomplete__comp_opts ]]; then
		# patch `autocomplete:_main_complete:new:post`
		# so that `fzf-tab` works with `zsh-autocomplete`

		# https://github.com/marlonrichert/zsh-autocomplete/blob/cfc3fd9a75d0577aa9d65e35849f2d8c2719b873/Functions/Init/.autocomplete__compinit#L104-L110
		__patch_autocomplete:_main_complete:new:post() {
			functions[compadd]=$functions[-ftb-compadd]
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


# auto rename zellij panes
_zellij_dirname() {
	# https://web.archive.org/web/20241129141342/https://github.com/zellij-org/zellij/issues/2284
	# https://archive.ph/gccgR https://web.archive.org/web/20240909152551/https://old.reddit.com/r/zellij/comments/10skez0/does_zellij_support_changing_tabs_name_according/
	local tab_name=''
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		tab_name+="$(basename "$(git rev-parse --show-toplevel)")/"
		tab_name+="$(git rev-parse --show-prefix)"
		tab_name="${tab_name%/}"
	else
		tab_name="${PWD//${HOME}/~}"
	fi
	# echo " $tab_name"
	echo "$tab_name"
}
_zellij_command_name() {
	# pane names don't accept nerdfont characters
	# echo "$(tmux-window-name "$(basename "$2" | cut -d' ' -f1)")"
	echo "$(basename "$2" | cut -d' ' -f1)"
}
_zellij_pane_rename_precmd() {
	if [[ -n "$ZELLIJ" ]]; then
		zellij action rename-pane "$(_zellij_dirname)"
	fi
}
_zellij_pane_rename_preexec() {
	if [[ -n "$ZELLIJ" ]]; then
		zellij action rename-pane "$(_zellij_command_name "$@") @ $(_zellij_dirname)"
	fi
}
add-zsh-hook precmd _zellij_pane_rename_precmd
add-zsh-hook preexec _zellij_pane_rename_preexec


if zle -l atuin-up-search-viins 2>/dev/null; then
	atuin-only-when-empty-buffer() {
		if (( $#BUFFER == 0 )); then
			zle up-line-or-search
		else
			zle atuin-up-search-viins
		fi
	}
	zle -N atuin-only-when-empty-buffer
	bindkey "^[[A" atuin-only-when-empty-buffer
	bindkey "^[OA" atuin-only-when-empty-buffer
fi


my-debug() {
	# adapted from `fzf-tab`'s `fzf-tab-debug`
	_my-debug-preexec() {
		(( $+_my_debug_cnt )) || typeset -gi _my_debug_cnt
		local tmp=${TMPPREFIX:-/tmp/zsh}-$$-my-$(( ++_my_debug_cnt )).log
		local -i debug_fd=-1
		{
			exec {debug_fd}>&2 2>| $tmp
		} always {
			if (( $TRY_BLOCK_ERROR == 0 && $debug_fd != -1 )); then
				{
					echo $ZSH_NAME $ZSH_VERSION
					echo "debug_fd: $debug_fd"
					echo "\$@: $@"
					echo "old PS4: $PS4"
				} >&2

				local -a debug_indent; debug_indent=( '%'{3..20}'(e. .)' )
				typeset -g __my_debug_OLD_PS4=$PS4
				export PS4="${(j::)debug_indent}+%N:%i> "

				local -A _functions
				_functions=(${(kv)functions})
				functions -t -- ${(k)_functions}

				eval "_my-debug-precmd() {
					functions +t -- ${(k)_functions}

					export PS4=\$__my_debug_OLD_PS4; unset __my_debug_OLD_PS4

					local -i debug_fd=$debug_fd
					if (( $debug_fd != -1 )); then
						echo \"my-debug: Trace output left in $tmp\"
						exec 2>&$debug_fd {debug_fd}>&-
					fi
				}"
				add-one-time-zsh-hook precmd _my-debug-precmd
			else
				echo "my-debug: Failed to allocate a debug_fd."
				(( $debug_fd != -1 )) && exec 2>&$debug_fd {debug_fd}>&-
			fi
		}
	}
	add-one-time-zsh-hook preexec _my-debug-preexec
}

if [[ -n "$CALC_CMD" ]]; then
	# https://github.com/Sam-programs/zsh-calc#highlighting
	typeset -A ZSH_HIGHLIGHT_REGEXP
	ZSH_HIGHLIGHT_REGEXP+=('[0-9]' fg=cyan)
	ZSH_HIGHLIGHT_HIGHLIGHTERS+=(main regexp)
fi

# if command -v carapace >/dev/null; then
# 	# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
# 	source <(carapace _carapace)
# fi


if command -v lsd >/dev/null; then
    alias ls=lsd
fi
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER="less -R --use-color -Dd+y -Du+c -DE+r"
