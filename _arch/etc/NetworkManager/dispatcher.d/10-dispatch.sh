#!/usr/bin/env bash

IF="wlp58s0"

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>/tmp/nm-dispatch.log 2>&1

(echo "$@" | grep -Eq "^${IF} up.*\$") && {
  echo "Wireless connected. Restarting DNS proxy..."
  systemctl restart https_dns_proxy.service
}

