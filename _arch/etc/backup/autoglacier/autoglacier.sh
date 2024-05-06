#!/usr/bin/env bash

set -e

HOST="$(hostname -s)"

if [[ "$HOST" == "seedbox" ]]; then
  "${HOME}"/bin/rsync-mirror /mnt/media
  rclone sync /mnt/media/.rsync_mirror/ turris-backup:turris-backup/media/ \
 --transfers=4`           # a little parallelism`\
 --size-only`             # it's media so size-only comparison suffices`\
 --links`                 # create .rclonelink for symlinks`\
 --no-update-modtime`     # don't spam the API for no reason`\
 --dry-run`               # development mode`
elif [[ "$HOST" == "vps" ]]; then
  rclone sync "${HOME}/backup/" vps-borg-backup:vps-borg-backup/ \
 --transfers=8`           # more parallelism`\
 --dry-run`               # development mode`
fi
