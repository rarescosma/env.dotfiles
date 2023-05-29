[[ -f ~/.local/env ]] && source ~/.local/env
source ~/.config/zsh/oh-my-vendor.zsh
source ~/.config/zsh/fzf.zsh

source ~/.config/zsh/aws.zsh
source ~/.config/zsh/prompt.zsh

source ~/.config/zsh/opts.zsh
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/functions.zsh

source ~/.config/zsh/devel.zsh
[[ -f ~/.config/zsh/gcloud.zsh ]] && source ~/.config/zsh/gcloud.zsh
source ~/.config/zsh/misc.zsh

[[ -f ~/.local/functions ]] && source ~/.local/functions

if [[ $(uname) == "Darwin" ]] && [[ -f ~/.config/zsh/mac.zsh ]]; then
 source ~/.config/zsh/mac.zsh
fi

if [[ "$TTY" == /dev/tty* ]]; then
  export GPG_TTY="$TTY"
  systemctl --user import-environment GPG_TTY
fi

if ! test -z "$SSH_CLIENT"; then
  export GPG_TTY=$(tty)
  export DBUS_SESSION_BUS_ADDRESS=/dev/null
  export XDG_SESSION_TYPE=pts
fi

if [[ "$TTY" == "/dev/tty1" ]]; then
  exec systemd-cat -t startx startx -- -dpi 110
else
  if (( ${+TMUX} )); then
    source ~/.config/zsh/fortune.zsh
  fi
fi
