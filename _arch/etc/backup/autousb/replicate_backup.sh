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
  # backup first, then wait for net and pull read queue
  _exec_kindle ",update_id; ,backup"
  _wait_for_net 30
  _exec_kindle ",pull_queue"
}

_exec_kindle() {
  local script
  script=(
    "source /home/${USER}/.zshenv;"
    "source /home/${USER}/bin/,kindle;"
    "$@"
  )
  sudo -H -u ${USER} bash -c "${script[*]}"
}

_wait_for_net() {
  local tries max_tries
  tries=1
  max_tries=${1:-10}

  while ! ping -c1 www.google.com &>/dev/null; do
    if [ $tries -ge "$max_tries" ]; then
      return 1
    fi
    tries=$(( tries + 1 ))
    sleep 1
  done
}

# Mount -> dispatch -> sync
mkdir -p "$MOUNTPOINT"
"_handle_${DEV_TYPE}"
(mount | grep "$MOUNTPOINT") || mount "$PARTITION_PATH" "$MOUNTPOINT" -o uid="$(id -u $USER)",gid="$(id -g $USER)",umask=002
sync
