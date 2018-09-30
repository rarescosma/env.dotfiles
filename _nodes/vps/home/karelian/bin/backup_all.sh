#!/usr/bin/env bash

set -xeo pipefail

TMPD='/tmp/backup'
SITES_ROOT='/srv/sites'
GB_ROOT='/srv/getbetter'
DOMAINS='mihaimateiu.ro rarescosma.com'

mkdir -p $TMPD

# Backup the entire MySQL cluster
mysqldump -u root -p"<SUPERSECRET>" --all-databases > $TMPD/my.sql

# Backup the site roots
while read domain; do
  echo "> Backing up $domain";
  TARGET="$TMPD/sites/$domain"
  mkdir -p $TARGET
  rsync -az --delete $SITES_ROOT/$domain/htdocs/ $TARGET/
done < <(echo $DOMAINS | tr ' ' '\n')

# Backup getbetter
mkdir -p $TMPD/getbetter/
rsync -az --exclude ".deploy" --exclude ".git" --exclude "node_modules" --delete $GB_ROOT/ $TMPD/getbetter/

# Tar the whole shenanigan
BACKUP_TAR="/tmp/backup_$(date -u '+%Y-%m-%dT%H-%M-%SZ').tgz"
tar -c $TMPD | pigz -9 > $BACKUP_TAR

# Destination based on weekday
DROPBOX_DEST="Backup/VPS/weekly_rotation_0$(date '+%u').tgz"
/srv/bin/dropbox_uploader.sh upload "${BACKUP_TAR}" "${DROPBOX_DEST}"

