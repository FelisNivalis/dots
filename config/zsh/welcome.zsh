if [ "$(date '+%u')" -ge 5 ] && command -v ponysay >/dev/null; then
  ponysay -q
else;
  if command -v fortune >/dev/null && command -v chara >/dev/null; then
    if ([ "$(date '+%H')" -ge 17 ] || [ "$(date '+%H')" -lt 8 ]) && command -v lolcat >/dev/null; then
      cmd="lolcat"
    else;
      cmd="cat -"
    fi
    fortune | chara say --random | eval $cmd
    unset cmd
  fi
fi
