#!/usr/bin/env bash

UUID="$1"
if [ ! "$UUID" ]; then
  echo "Invoked without a UUID parameter, exiting"
  exit 0
fi
if [[ "$UUID" =~ ^sys-.* ]]; then
  exit 0
fi

sleep 1
set -e

DOT=$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)
DEVICES="${DOT}/replicate_backup.devices"
USER="karelian"

if ! grep --quiet --fixed-strings "$UUID" "$DEVICES"; then
  echo "No backup disk found, exiting"
  exit 0
fi

DEV_TYPE=$(grep "$UUID" "$DEVICES" | cut -d" " -f2)
echo "Device with UUID ${UUID} is a ${DEV_TYPE}"

PARTITION_PATH="/dev/disk/by-uuid/${UUID}"
MOUNTPOINT="/mnt/${DEV_TYPE}"
DRIVE=$(lsblk --inverse --noheadings --list --paths --output name "${PARTITION_PATH}" | head --lines 1)

_umount_on_err() {
  umount -f "$MOUNTPOINT"
}
trap _umount_on_err ERR


_handle_replica() {
  mkdir -p "${MOUNTPOINT}/backup"
  rsync -avP --delete /home/${USER}/backup/ "${MOUNTPOINT}/backup/"
}

_handle_kindle() {
  local kindle_cmds

  kindle_cmds=(
    "source /home/${USER}/.zshenv;"
    "source /home/${USER}/bin/,kindle;"
    ",update_id; ,backup; ,pull_queue"
  )
  sudo -H -u ${USER} bash -c "${kindle_cmds[*]}"
}

# Mount -> dispatch -> paranoia -> unmount
mkdir -p "$MOUNTPOINT"
(mount | grep "$MOUNTPOINT") || mount "$PARTITION_PATH" "$MOUNTPOINT" -o uid=$(id -u $USER),gid=$(id -g $USER),umask=002
"_handle_${DEV_TYPE}"
sync
umount "$MOUNTPOINT"
