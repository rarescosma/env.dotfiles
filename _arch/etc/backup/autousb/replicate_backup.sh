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

_update_env() {
  local f var val
  f="${1}"; shift
  var="${1}"; shift
  val="${@}"
  if grep -qs "export $var" "$f" ; then
    sed -i "s|^export $var=.*$|export $var=\"${val}\"|" "$f"
  else
    echo "export $var=\"$val\"" >> "$f"
  fi
}

_handle_replica() {
  mkdir -p "${MOUNTPOINT}/backup"
  rsync -avP --delete /home/karelian/backup/ "${MOUNTPOINT}/backup/"
}

_handle_kindle() {
  local ts backup_dir home_dir kindle_id

  ts="$(date "+%F@%T")"
  home_dir="/home/karelian"

  kindle_id=$($home_dir/bin/,kindle ,usb_id)
  echo "Updating kindle id to: ${kindle_id}"
  _update_env "${home_dir}/.local/env" KINDLE_ID "${kindle_id}"

  echo "Grabbing kindle notes at ${ts}"
  backup_dir="${home_dir}/backup/kindle"
  mkdir -p "$backup_dir"
  cp \
    "${MOUNTPOINT}/documents/My Clippings.txt" \
    "${backup_dir}/notes-${ts}.txt"
  chown -R karelian: "$backup_dir"
  chmod -R 644 "${backup_dir}"/*

  if test -d "${home_dir}/src/pkm/kindle_read_queue"; then
    mkdir -p "${MOUNTPOINT}/documents/_Queue"
    rsync -rvP "${home_dir}/src/pkm/kindle_read_queue/" "${MOUNTPOINT}/documents/_Queue/"
  fi
}

# Mount -> dispatch -> paranoia -> unmount
mkdir -p "$MOUNTPOINT"
(mount | grep "$MOUNTPOINT") || mount "$PARTITION_PATH" "$MOUNTPOINT"
"_handle_${DEV_TYPE}"
sync
umount "$MOUNTPOINT"
