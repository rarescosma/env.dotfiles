if [[ "$TTY" == /dev/tty* ]]; then
  export GPG_TTY="$TTY"
  if command -v systemctl &>/dev/null; then
    systemctl --user import-environment GPG_TTY
  fi
fi

if ! test -z "$SSH_CLIENT"; then
  command -v tty >/dev/null && export GPG_TTY=$(tty)
  export DBUS_SESSION_BUS_ADDRESS=/dev/null
  export XDG_SESSION_TYPE=pts
fi

if [[ "$TTY" == "/dev/tty1" ]]; then
  exec systemd-cat -t startx startx -- -dpi 110 && exit
fi

source ~/.config/zsh/oh-my-vendor.zsh

[[ -f ~/.config/zsh/nix.zsh ]] && source ~/.config/zsh/nix.zsh
source ~/.config/zsh/fzf.zsh

source ~/.config/zsh/aws.zsh
source ~/.config/zsh/prompt.zsh

source ~/.config/zsh/opts.zsh
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/functions.zsh

source ~/.config/zsh/devel.zsh
source ~/.config/zsh/misc.zsh

[[ -f ~/.local/functions ]] && source ~/.local/functions

if [[ $(uname) == "Darwin" ]] && [[ -f ~/.config/zsh/mac.zsh ]]; then
 source ~/.config/zsh/mac.zsh
fi

if (( ${+TMUX} )); then
  source ~/.config/zsh/fortune.zsh
fi
