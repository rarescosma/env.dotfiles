#!/usr/bin/env bash

#
# Debian Server installation
#
# Run installation:
#
# TODO - shorten this via getbetter ingress
# - Run: `# bash <(curl -sL https://github.com/rarescosma/env.dotfiles/server-install.sh)`

# Dialog
BACKTITLE="Debian Server installation"

get_input() {
    title="$1"
    description="$2"

    input=$(dialog --clear --stdout --backtitle "$BACKTITLE" --title "$title" --inputbox "$description" 0 0)
    echo "$input"
}

main() {
  set -uo pipefail
  trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

  exec 1> >(tee -a "/tmp/server-install.out")
  exec 2> >(tee -a "/tmp/server-install.err" >&2)

  echo -e "\n### Setting up clock"
  timedatectl set-ntp true
  timedatectl set-timezone CET

  echo -e "\n### Installing essential packages"
  apt update
  apt install --yes \
    sudo zsh stow curl wget git rsync neovim mc ncdu htop screen tig \
    dnsutils net-tools make fzf ripgrep fd-find

  # god mode
  grep -q $user /etc/sudoers || {
    echo "$user ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
  }

  setup_dotfiles
}

setup_dotfiles() {
  # very important
  vim_colors="/usr/share/nvim/runtime/colors/gruvbox.vim"
  test -f $vim_colors || wget https://raw.githubusercontent.com/morhetz/gruvbox/master/colors/gruvbox.vim -O $vim_colors

  # set up dotfiles
  dotfiles_dir="/home/$user/src/env/dotfiles"
  dotfiles_setup=(
    "mkdir -p $dotfiles_dir;"
    "test -f $dotfiles_dir/setup-user.sh || git clone --recursive https://github.com/rarescosma/env.dotfiles.git $dotfiles_dir || true;"
    "pushd $dotfiles_dir;"
    "./setup-user.sh stow::bin;"
    "./setup-user.sh stow devel;"
    "./setup-user.sh stow shell;"
    "./setup-user.sh stow misc || true;"
    "echo -e \"enable_devel=(kubectl python)\nenable_ssh_agent=0\n\" > /home/$user/.local/env;"
    "mkdir -p /home/$user/.ssh;"
    "test -f /home/$user/.ssh/authorized_keys || wget https://static.getbetter.ro/$user.pub -O /home/$user/.ssh/authorized_keys;"
    "mkdir -p /home/$user/.local/share/vim/files/backup"
  )
  sudo -u $user bash -c "${dotfiles_setup[*]}"
  chsh -s /bin/zsh $user
  ln -sf /bin/fdfind /home/$user/bin/fd
}

# ask for username
if test -z "$DEBBIE_USER"; then
    apt update
    apt install --yes dialog
    user=$(get_input "User" "Enter username") || exit 1
    clear
    : ${user:?"user cannot be empty"}
else
    user="$DEBBIE_USER"
fi

if [[ "$@" == "" ]]; then
  main
else
  "$@"
fi
