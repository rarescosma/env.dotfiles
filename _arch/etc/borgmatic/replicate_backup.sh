#!/usr/bin/env bash

DOT=$(cd -P "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))" && pwd)
MOUNTPOINT=/mnt/backup

set -e

# This is the file that will later contain UUIDs of registered backup drives
DISKS="${DOT}/backup.disks"

# Find whether the connected block device is a backup drive
for uuid in $(lsblk --noheadings --list --output uuid); do
    if grep --quiet --fixed-strings $uuid $DISKS; then
        break
    fi
    uuid=
done

if [ ! $uuid ]; then
    echo "No backup disk found, exiting"
    exit 0
fi

echo "Disk ${uuid} is a backup disk"
partition_path="/dev/disk/by-uuid/${uuid}"
(mount | grep $MOUNTPOINT) || mount $partition_path $MOUNTPOINT

drive=$(lsblk --inverse --noheadings --list --paths --output name "${partition_path}" | head --lines 1)
echo "Drive path: ${drive}"

rsync -avP --delete /home/karelian/backup/ "${MOUNTPOINT}/backup/"
sync
