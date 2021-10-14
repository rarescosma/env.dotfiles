#!/usr/bin/env bash

if test -f /tmp/caffeine; then
  echo "had caffeine, will not lock"
  exit 0
fi

if [[ -z "$(pidof i3lock)" ]]; then
  i3lock -i ~/.i3/congruent_outline.png --tiling && sleep 1
else
  echo "i3lock is already running"
fi
