if [ "$(date '+%u')" -ge 5 ] && command -v ponysay >/dev/null; then
  ponysay -q
else;
  if command -v fortune >/dev/null && command -v cowsay >/dev/null; then
    if ([ "$(date '+%H')" -ge 17 ] || [ "$(date '+%H')" -lt 8 ]) && command -v lolcat >/dev/null; then
      cmd="lolcat"
    else;
      cmd="cat -"
    fi
    fortune | cowsay --random | eval $cmd
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

local plugins=()
. $ZDOTDIR/settings.zsh
. $ZDOTDIR/applications.zsh
. $ZDOTDIR/plugins.zsh # some plugins need python
. $ZDOTDIR/aliases.zsh

ulimit -n 4096
