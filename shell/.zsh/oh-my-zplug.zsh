plugins=(\
  gitalias archlinux docker git lxd \
  zsh-syntax-highlighting kubectl zsh-autosuggestions)

source "$ZSH/oh-my-zsh.sh"

if [[ -f "$_VENDOR/zplug/init.zsh" ]]; then
  export ZPLUG_LOADFILE="${HOME}/.zsh/zplug"
  source "$_VENDOR/zplug/init.zsh"

  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
      echo; zplug install
    fi
    echo
  fi
  zplug load
fi
