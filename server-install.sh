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

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "/tmp/stdout.log")
exec 2> >(tee "/tmp/stderr.log" >&2)

echo -e "\n### Setting up clock"
timedatectl set-ntp true
timedatectl set-timezone CET

echo -e "\n### Setting up APT proxy"
echo -e 'Acquire::http { Proxy "http://10.0.17.1:3142"; }' > /etc/apt/apt.conf.d/30autoproxy

echo -e "\n### Installing essential packages"
apt update
apt install --yes \
  sudo curl wget git rsync iptables neovim mc ncdu htop screen \
  snapd dnsutils net-tools golang-cfssl uuid-runtime make \
  openvpn fail2ban tig \
  zsh stow dialog \
  borgbackup rclone \
  fzf ripgrep fd-find

snap install lxd

# very important
vim_colors="/usr/share/nvim/runtime/colors/gruvbox.vim"
test -f $vim_colors || wget https://raw.githubusercontent.com/morhetz/gruvbox/master/colors/gruvbox.vim -O $vim_colors

# ask for username
user=$(get_input "User" "Enter username") || exit 1
clear
: ${user:?"user cannot be empty"}

# add user to proper groups
usermod -aG lxd $user

# god mode
grep -q $user /etc/sudoers || {
  echo "$user ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
}

# set up dotfiles
sudo -u $user mkdir -p "/home/$user/src/env/dotfiles"
sudo -u $user bash -c "git clone --recursive https://github.com/rarescosma/env.dotfiles.git /home/$user/src/env/dotfiles || true"
dotfiles_setup=(
  "pushd /home/$user/src/env/dotfiles;"
  "./setup-user.sh stow::bin;"
  "./setup-user.sh stow devel;"
  "./setup-user.sh stow shell;"
  "./setup-user.sh stow misc || true;"
  "mkdir -p /home/$user/.local/state/autoenv;"
  "echo -e \"enable_devel=(kubectl python)\nenable_ssh_agent=0\n\" > /home/$user/.local/env;"
  "echo -e 'PATH=\$PATH:/snap/bin' >> /home/$user/.local/env;"
  "mkdir -p /home/$user/.ssh;"
  "wget https://static.getbetter.ro/$user.pub -O /home/$user/.ssh/authorized_keys;"
  "mkdir -p /home/$user/.local/share/vim/files/backup"
)
sudo -u $user bash -c "${dotfiles_setup[*]}"
chsh -s /bin/zsh $user
ln -sf /bin/fdfind /home/$user/bin/fd
