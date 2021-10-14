#!/usr/bin/env bash

set -e

"${HOME}"/bin/rsync-mirror "${HOME}"/media

export PATH="$PATH:/usr/bin/vendor_perl"
MTGLACIER="mtglacier sync --config ${HOME}/.config/aws/$(hostname -s).cfg --dir ${HOME}/media/.rsync_mirror --concurrency 16"

$MTGLACIER --dry-run
$MTGLACIER
