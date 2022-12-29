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

  copy "etc/NetworkManager/conf.d/20-connectivity.conf"
  copy "etc/asd.conf"
  copy "etc/conf.d/snapper"
  copy "etc/containers/registries.conf"
  copy "etc/default/grub-btrfs/config"
  copy "etc/depmod.d/00-extra.conf"
  copy "etc/dns-over-https/doh-client.conf"
  copy "etc/fonts/conf.d/75-noto-color-emoji.conf"
  copy "etc/fonts/conf.d/30-font-aliases.conf"
  copy "etc/interception/udevmon.yaml"
  copy "etc/interception/dual-function-keys/modifiers.yaml"
  copy "etc/libvirt/qemu.conf"
  copy "etc/pacman.d/hooks"
  copy "etc/profile.d/freetype2.sh"
  copy "etc/profile.d/jre.sh"
  copy "etc/snap-pac.ini"
  copy "etc/snapper/configs/root"
  copy "etc/sudoers.d/override"
  copy "etc/sysctl.d/99-sysctl.conf"
  copy "etc/systemd/logind.conf"
  copy "etc/systemd/system/closetomb.service"
  copy "etc/systemd/system/getty@tty2.service.d/override.conf"
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
  copy "etc/systemd/system/autoborg@home.timer"
  copy "etc/systemd/system/autoborg@home.service"
  copy "etc/systemd/system/autoborg@root.timer"
  copy "etc/systemd/system/autoborg@root.service"
  copy "etc/systemd/system/autoglacier.timer"
  copy "etc/systemd/system/autoglacier.service"
  link "etc/backup/autousb/replicate_backup@.service" "etc/systemd/system/replicate_backup@.service"
  link "etc/backup/autousb/65-replicate_backup.rules" "etc/udev/rules.d/65-replicate_backup.rules"
}

setup::_node() {
  local hostname=$(head -1 /etc/hostname)
  export HOSTNAME="$hostname"

  copy_host "etc/environment"

  if [[ $hostname == shrewd ]]; then
    copy_host "etc/modprobe.d/i915.conf"
    copy_host "etc/X11/xorg.conf.d/20-synaptics.conf"
    copy_host "etc/mkinitcpio.conf"
  fi

  if [[ $hostname == ufo ]]; then
    copy_host "etc/modprobe.d/i915.conf"
    copy_host "etc/modprobe.d/nouveau.conf"
    copy_host "etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf"
    copy_host "etc/X11/xorg.conf.d/20-synaptics.conf"
    copy_host "etc/X11/xinit/xinitrc.d/10-nvidia-modeset.sh"
    copy_host "etc/mkinitcpio.conf"
    copy_host "etc/default/grub"
  else
      copy "etc/default/grub"
  fi

  if [[ $hostname == mac ]]; then
    copy_host "etc/modprobe.d/hid_apple.conf"
    copy_host "etc/X11/xorg.conf.d/20-intel.conf"
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
  systemctl_enable_start "autoborg@home.timer"
  systemctl_enable_start "autoborg@root.timer"
  systemctl_enable_start "autoglacier.timer"
  systemctl_enable_start "btrfs-scrub@-.timer"
  systemctl_enable_start "btrfs-scrub@home.timer"
  systemctl_enable_start "btrfs-scrub@snapshots.timer"
  systemctl_enable_start "btrfs-scrub@var_log.timer"
  systemctl_enable_start "doh-client.service"
  systemctl_enable_start "fstrim.timer"
  systemctl_enable_start "snapper-cleanup.timer"
  systemctl_enable_start "udevmon.service"

  if is_chroot; then
    echo >&2 "=== Running in chroot, skipping turtles..."
  else
    echo ""
    echo "================================"
    echo "Enabling and starting turtles..."
    echo "================================"

    systemctl_enable_start "libvirtd.service" || true
    systemctl_enable_start "lxd.service" || true
    systemctl_enable_start "podman.service" || true
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

  echo "Configuring sleep"
  copy "etc/tlp.d/10-ac-governor.conf"
  copy "usr/lib/systemd/system-sleep/udevm"
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
