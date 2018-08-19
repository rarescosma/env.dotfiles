# -- Omz + Zplug ---------------------------------------------------------------
source "$ZSH/oh-my-zsh.sh"

if [[ -f "$ZSH/../zplug/init.zsh" ]]; then
  export ZPLUG_LOADFILE="${HOME}/.zplug.zsh"
  source "$ZSH/../zplug/init.zsh"

  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
      echo; zplug install
    fi
    echo
  fi
  zplug load
fi

# -- Options + Keys ------------------------------------------------------------
unsetopt correct_all
unsetopt correct
unalias z
bindkey \^U backward-kill-line

# -- Dispatch ------------------------------------------------------------------
for mod in "$HOME"/.zsh.*; do
  source "$mod"
done

[[ -f "$HOME/.local/env" ]] && source "$HOME/.local/env"
[[ -f "$HOME/.local/functions" ]] && source "$HOME/.local/functions"

# -- X11 -----------------------------------------------------------------------
if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx -- -dpi 144
else
  clear
  read -r -d '' OK_COWS <<'EOF'
moose
daemon
three-eyes
bunny
kitty
elephant
small
skeleton
dragon
koala
bud-frogs
vader
default
tux
EOF
  fortune -n 300 -s | cowsay -W 80 -f $(echo "$OK_COWS" | shuf -n 1)
fi
