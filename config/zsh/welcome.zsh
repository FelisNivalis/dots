wttr_dir="$XDG_CACHE_HOME/wttr.in"
wttr_file="$wttr_dir/cache"
if [[ ! -d "$wttr_dir" ]]; then
  mkdir -p "$wttr_dir"
fi
if (( $(cat "$wttr_dir/time" 2>/dev/null || echo "0") + 3600 < $(date +%s) )); then
  # cache 1h
  printf "---------%s---------\n" "$(date +%Y/%m/%d\ %H:%M:%S)" >>"$wttr_dir"/err
  ret=$(curl --max-time 5 v2n.wttr.in 2>>"$wttr_dir/err" | head -n -2)
  if [[ -z "$ret" ]]; then
    if [[ -f "$wttr_file" ]]; then
      rm "$wttr_file"
    fi
    if [[ -f "$wttr_dir/time" ]]; then
      rm "$wttr_dir/time"
    fi
  else
    echo "$ret" > "$wttr_file"
    date +%s > "$wttr_dir/time"
  fi
fi
unset wttr_dir

if [ "$(date '+%u')" -ge 5 ] && command -v ponysay >/dev/null; then
  if [[ -f "$wttr_file" ]]; then
    # ponysay doesn't correctly recognize `\x0f`
    cat "$wttr_file" | sed -e 's/\x0f//g' | ponysay --wrap 200 2>/dev/null
  else
    ponysay -q 2>/dev/null
  fi
else
  if command -v chara >/dev/null; then
    chara_sed='chara say --random | sed s/$/"$(echo -e \\u3000)"/'
    # work around https://github.com/zellij-org/zellij/issues/3820
    # Ideographic space: https://en.wikipedia.org/wiki/Whitespace_character#:~:text=U+3000
    if [[ -f "$wttr_file" ]]; then
      cat "$wttr_file" | eval "$chara_sed"
    elif command -v fortune >/dev/null; then
      if ([ "$(date '+%H')" -ge 17 ] || [ "$(date '+%H')" -lt 8 ]) && command -v lolcat >/dev/null; then
        cmd="lolcat"
      else;
        cmd="cat -"
      fi
      fortune | eval "$chara_sed" | eval $cmd
      unset cmd
    fi
    unset chara_sed
  fi
fi
unset wttr_file
