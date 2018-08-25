#!/bin/bash

set -x

# 0. Pacman + upgrade + reqs
do_packages() {
  pacman-key --init
  pacman-key --populate archlinuxarm
  pacman -Syu --noconfirm
  pacman -Sy --noconfirm --needed base-devel sudo git alsa-utils
}

# 1. User
do_user() {
  local user="${1:-karelian}"
  local home="/home/$user"

  # create it
  id -u "$user" || (
    read -srp "Enter Password: " userpass
    set +x
    useradd -m "$user" -p $userpass
    set -x
  )

  # give it sudo
  grep "$user" /etc/sudoers || \
    echo "$user ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
  mkdir -p "$home/.ssh"

  # setup authorized_keys
  test -f "$home/.ssh/authorized_keys" || (
    curl https://static.getbetter.ro/karelian.pub > "$home/.ssh/authorized_keys"
    chown "$user": -R "$home/.ssh"
  )

  # secure ssh
  </etc/ssh/sshd_config sed -E 's|#+PasswordAuthentication .+|PasswordAuthentication no|' | sed -E 's|#+PermitRootLogin .+|PermitRootLogin no|' >/etc/ssh/sshd_config.new
  mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config
  systemctl daemon-reload
  systemctl restart sshd.service
}

# 2. Install gmrender
do_gmrender() {
  local user="${1:-karelian}"
  local tmppath='/tmp/gmrender'
  local uuid

  mkdir -p $tmppath
  git clone https://aur.archlinux.org/gmrender-resurrect-git.git $tmppath
  sed -i -E 's|arch=(.+)|arch=("armv6h")|' "$tmppath/PKGBUILD"
  chown -R "$user": $tmppath
  su "$user" -c "cd $tmppath && makepkg -si --noconfirm"
}

# 3. Configure gmrender
do_gmrender_conf() {
  local uuid
  uuid=$(uuidgen)
  cat <<EOF >/etc/conf.d/gmediarender
friendly=Raspi
uuid=$uuid
EOF
  systemctl enable gmediarender
  systemctl daemon-reload
  systemctl restart gmediarender
}

"$@"
