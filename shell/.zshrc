[[ -f ~/.local/env ]] && source ~/.local/env
source ~/.zsh/oh-my-vendor.zsh
source ~/.zsh/fzf.zsh

source ~/.zsh/prompt.zsh

source ~/.zsh/opts.zsh
source ~/.zsh/keybindings.zsh
source ~/.zsh/functions.zsh

source ~/.zsh/devel.zsh
source ~/.zsh/misc.zsh

[[ -f ~/.local/functions ]] && source ~/.local/functions

if [[ "$TTY" == /dev/tty* ]]; then
  export GPG_TTY="$TTY"
  systemctl --user import-environment GPG_TTY
fi

if [[ "$TTY" == "/dev/tty1" ]]; then
  exec systemd-cat -t startx startx -- -dpi 110
else 
  if (( ${+TMUX} )); then
    source ~/.zsh/fortune.zsh
  fi
fi
