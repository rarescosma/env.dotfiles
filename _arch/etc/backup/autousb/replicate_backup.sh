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

_replica_backup() {
  mkdir -p "${MOUNTPOINT}/backup"
  rsync -avP --delete /home/karelian/backup/ "${MOUNTPOINT}/backup/"
}

_kindle_backup () {
  local ts
  ts="$(date "+%F@%T")"
  echo "Grabbing kindle notes at ${ts}"
  cp \
    "${MOUNTPOINT}/documents/My Clippings.txt" \
    "/home/karelian/backup/kindle/notes-${ts}.txt"
  chown -R karelian: /home/karelian/backup/kindle
  chmod -R 644 /home/karelian/backup/kindle/*
}

# Mount -> dispatch -> paranoia -> unmount
(mount | grep "$MOUNTPOINT") || mount "$PARTITION_PATH" "$MOUNTPOINT"
"_${DEV_TYPE}_backup"
sync
umount "${DRIVE}"
