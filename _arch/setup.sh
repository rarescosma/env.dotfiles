#!/usr/bin/env bash

set -e

PACKAGE_GROUPS="base base-devel xorg i3"

net::enable_wifi() {
  IF="${IF:-wlp3s0}"
  SSID="${SSID:-getbetter}"

  ip link set $IF up

  echo -n "${SSID} passphrase:"
  read -s PASSPHRASE
  echo
  wpa_supplicant -i $IF -c <(wpa_passphrase "${SSID}" "${PASSPHRASE}") -B

  sleep 5
  dhcpcd $IF
}

pac::list_aur() {
  pacman -Qqm | sort
}

pac::list_non_group() {
  # packages from groups
  comm -23 <(pacman -Qqe | sort) <(pacman -Qqg $PACKAGE_GROUPS | sort)
}

pac::list_non_group_non_aur() {
  comm -23 <(pac::list_non_group) <(pac::list_aur)
}

pac::list() {
  echo $PACKAGE_GROUPS | tr " " "\n" > package.groups
  pac::list_non_group_non_aur > packages
  pac::list_aur > packages.aur
}

bootstrap() {
  local dot make
  dot=$(cd -P "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))" && pwd)
  make="make -C ${dot}/.."

  export USER_NAME="${1}"
  read -s -p "Pass: " USER_PASS </dev/tty

  # Install base packages via make
  pacman -Sy --noconfirm --needed make
  $make base

  # Setup user
  SALT="\$1\$$(pwgen -1 8)\$"
  export USER_PASS=$(python -c "import crypt; print(crypt.crypt(\"${USER_PASS}\", \"${SALT}\"))")
  $make PLAYBOOK=bootstrap

  sudo -u $USER_NAME $make PLAYBOOK=user ANSIBLE_NOCOWS=1
}

_completion() {
  local fun_list=$(declare -F | cut -d ' ' -f3 | grep "^[^_]" | xargs)
  cat <<EOF
_completion() {
  if (( \$COMP_CWORD < 2 )); then
    COMPREPLY=( \$(compgen -W "${fun_list}" -- "\${COMP_WORDS[COMP_CWORD]}") )
  else
    COMPREPLY=""
  fi
  return 0
}

complete -F _completion $(basename $0)
EOF
}

# Dispatch
"$@"
