export HISTFILE=${ZDOTDIR:-$HOME}/.histfile
export HISTDB_FILE="${ZDOTDIR:-$HOME}/.histdb/zsh-history.db"

export HISTSIZE=1000000000
export SAVEHIST=1000000000
export HIST_STAMPS="mm/dd/yyyy"
bindkey -v # vi

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
# setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
unsetopt APPEND_HISTORY

setopt PROMPT_SUBST
setopt PROMPT_BANG
setopt PROMPT_PERCENT

bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char
bindkey -v '^?' backward-delete-char
# bindkey -l / bindkey -M
