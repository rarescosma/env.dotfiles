#!/usr/bin/env bash

usage () {
  echo 'Installs a daemon found under ~/bin/${daemon}-daemon'
  echo ' -> the daemon name must be passed as the only argument'
  echo ' -> the ~/bin/${daemon}-daemon binary must exist'
}

if test -z "${1}" || ! test -x "${HOME}/bin/${1}-daemon"; then
  usage
  exit 1
fi 

set -e

export DAEMON="${1}"
DOT=$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)
UNIT="${HOME}/Library/LaunchAgents/ro.getbetter.${DAEMON}.daemon.plist"

envsubst <"${DOT}/template.plist" | tee "${UNIT}"
launchctl unload "${UNIT}" || true
launchctl load "${UNIT}"
