#!/usr/bin/env bash

# nuke saved gpg + ssh keys
if [[ "$1" == "--clear-keys" ]]; then
  shift
  gpg-connect-agent reloadagent /bye
  ssh-add -D
fi

if test -f /tmp/i3/caffeine; then
  echo "had caffeine, will not lock"
  exit 0
fi

if [[ "$1" == "--start" ]]; then
  i3lock -i "${XDG_CONFIG_HOME}/i3/leafy_green.png" --tiling
  exit 0
fi

if [[ -z "$(pidof i3lock)" ]]; then
  i3lock -i "${XDG_CONFIG_HOME}/i3/leafy_green.png" --tiling && sleep 1
else
  echo "i3lock is already running"
fi
