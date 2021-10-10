#!/usr/bin/env bash

set -e
exec 2> >(while read line; do echo -e "\e[01;31m$line\e[0m"; done)

script_name="$(basename "$0")"
dotfiles_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if (("$EUID")); then
  sudo -s "$dotfiles_dir/$script_name" "$@"
  exit 0
fi

if [ "$1" = "-r" ]; then
  echo >&2 "Running in reverse mode!"
  export reverse=1
  shift
fi

source "$dotfiles_dir/inc-system.sh"

setup::etc() {
  echo ""
  echo "=========================="
  echo "Setting up /etc configs..."
  echo "=========================="

  copy "etc/NetworkManager/dispatcher.d/10-dispatch.sh"
  copy "etc/default/docker"
  copy "etc/default/grub"
  copy "etc/depmod.d/00-extra.conf"
  copy "etc/fonts/conf.d/75-joypixels.conf"
  copy "etc/fonts/conf.d/30-font-aliases.conf"
  copy "etc/libvirt/qemu.conf"
  copy "etc/pacman.d/hooks"
  copy "etc/profile.d/freetype2.sh"
  copy "etc/profile.d/jre.sh"
  copy "etc/sudoers.d/override"
  copy "etc/sysctl.d/99-sysctl.conf"
  copy "etc/systemd/logind.conf"
  copy "etc/systemd/system/closetomb.service"
  copy "etc/systemd/system/docker.service.d"
  copy "etc/systemd/system/getty@tty1.service.d/override.conf"
  copy "etc/systemd/system/https_dns_proxy.service.d/override.conf"
  copy "etc/systemd/system/powertop.service"
  copy "etc/locale.nopurge"
  copy "etc/pacman.conf"
}

setup::backup() {
  echo ""
  echo "===================="
  echo "Setting up backup..."
  echo "===================="

  link "etc/backup"
  copy "etc/systemd/system/autoborg@home.timer.d/override.conf"
  copy "etc/systemd/system/autoborg@root.timer.d/override.conf"
  link "etc/backup/autoborg/autoborg@.service" "etc/systemd/system/autoborg@.service"
  link "etc/backup/autoborg/autoborg@.timer" "etc/systemd/system/autoborg@.timer"
  link "etc/backup/autoborg/autoborg@.timer" "etc/systemd/system/autoborg@home.timer"
  link "etc/backup/autoborg/autoborg@.timer" "etc/systemd/system/autoborg@root.timer"
  link "etc/backup/autoglacier/autoglacier.service" "etc/systemd/system/autoglacier.service"
  link "etc/backup/autoglacier/autoglacier.timer" "etc/systemd/system/autoglacier.timer"
  link "etc/backup/autousb/replicate_backup@.service" "etc/systemd/system/replicate_backup@.service"
  link "etc/backup/autousb/65-replicate_backup.rules" "etc/udev/rules.d/65-replicate_backup.rules"
}

setup::_node() {
  if [[ $HOSTNAME == shrewd ]]; then
    copy_host "etc/modprobe.d/i915.conf"
    copy_host "etc/X11/xorg.conf.d/20-synaptics.conf"
    copy_host "etc/environment"
  fi

  if [[ $HOSTNAME == mac ]]; then
    copy_host "etc/modprobe.d/hid_apple.conf"
    copy_host "etc/X11/xorg.conf.d/20-synaptics.conf"
  fi
}

setup::services() {
  echo ""
  echo "================================="
  echo "Enabling and starting services..."
  echo "================================="

  sysctl --system > /dev/null

  systemctl daemon-reload
  systemctl_enable_start "NetworkManager.service"
  systemctl_enable_start "btrfs-scrub@-.timer"
  systemctl_enable_start "btrfs-scrub@home.timer"
  systemctl_enable_start "btrfs-scrub@snapshots.timer"
  systemctl_enable_start "btrfs-scrub@var_log.timer"
  systemctl_enable_start "fstrim.timer"
  systemctl_enable_start "autoborg@home.timer"
  systemctl_enable_start "autoborg@root.timer"
  systemctl_enable_start "autoglacier.timer"

  if is_chroot; then
    echo >&2 "=== Running in chroot, skipping turtles..."
  else
    echo ""
    echo "================================"
    echo "Enabling and starting turtles..."
    echo "================================"

    systemctl_enable_start "docker.socket"
    systemctl_enable_start "libvirtd.service"
    systemctl_enable_start "lxd.service"
  fi
}

setup::var() {
  echo ""
  echo "=========================================="
  echo "Finishing various system configurations..."
  echo "=========================================="

  echo "Creating top level Trash dir"
  mkdir --parent /.Trash
  chmod a+rw /.Trash
  chmod +t /.Trash

  echo "Configuring NTP"
  timedatectl set-ntp true

  echo "Locking firefox settings"
  copy "usr/lib/firefox/defaults/pref/local-settings.js"
  copy "usr/lib/firefox/mozilla.cfg"
}

main() {
  setup::etc
  setup::backup
  setup::_node
  (("$reverse")) && exit 0
  setup::services
  setup::var
}

if test -z "${1:-}"; then
  main
else
  for target in "${@}"; do
    $target
  done
fi
