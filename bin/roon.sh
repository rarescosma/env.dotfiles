#!/usr/bin/env bash

VM_NAME="roon"
VM_PROFILE="roon"
HOSTNAME=$(hostname -s)
VM_IFACE="eth0"
LXD_BRIDGE="lxdbr0"

DOT=$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)
ME="${0##*/}"

_log_call() {
  local src
  local kwargs="$*"

  src="$(basename "${BASH_SOURCE[1]}")"
  [[ "$src" =~ ^"$HOME"(/|$) ]] && src="~${src#$HOME}"
  printf "%s | %s | %s(%s) @ %s:%s\\n" "$(date +%F@%T)" "${HOSTNAME}" \
    "${FUNCNAME[1]}" "$kwargs" "$src" "${BASH_LINENO[0]}" >&2
}

_vm_exec() {
  _log_call "$*"
  lxc exec "$VM_NAME" -- "/dot/${ME}" "$@"
}

_wait_ip() {
  local ip
  while true; do
    ip=$(_get_ip)
    if [[ "${ip}" != "" ]]; then
      echo "$ip" && break
    fi
    sleep 1
  done
}

_get_ip() {
  ip addr show dev "$VM_IFACE" \
  | grep -v inet6 | grep inet \
  | cut -d"/" -f1 \
  | sed 's/[^0-9.]*//g'
}

start() {
  _log_call "$*"

  set -e
  echo "> create/update LXD profile..."
  lxc profile create ${VM_PROFILE} || true
  show_profile | lxc profile edit ${VM_PROFILE}

  echo "> stopping upmpd"
  systemctl --user stop upmpdcli.service

  echo
  echo "> start LXC container..."
  if lxc ls --format json | jq -e '.[] | select(.name == "roon")' >/dev/null; then 
    lxc start $VM_NAME || true
  else
    lxc launch ubuntu:22.04 $VM_NAME --profile ${VM_PROFILE} || true
  fi
  _vm_exec install_roon
  set +e

  echo
  echo "> forwarding ports..."
  port_forward
}

stop() {
  _log_call "$*"

  port_forward clear
  lxc stop $VM_NAME

  echo "> restarting upmpd"
  sleep 1
  systemctl --user start upmpdcli.service
}

show_profile() {
  _log_call "$*"

  cat << EOF
name: ${VM_PROFILE}
description: Roon LXD profile
config:
  security.nesting: "true"
  security.privileged: "true"
devices:
  dotdir:
    path: /dot
    source: ${DOT}
    type: disk
  ${VM_IFACE}:
    name: ${VM_IFACE}
    nictype: bridged
    parent: ${LXD_BRIDGE}
    type: nic
  root:
    path: /
    pool: default
    type: disk
EOF

  for dev in $(find /dev/snd -type c); do
    cat << EOF
  $(basename "$dev"):
    path: $dev
    type: unix-char
EOF
  done
}

install_roon() {
  _log_call "$*"

  test -x /opt/RoonServer/Server/RoonServer && return

  apt-get update && apt-get install --no-install-recommends --yes ffmpeg cifs-utils bzip2 net-tools
  wget -qO roon-setup.sh https://download.roonlabs.net/builds/roonserver-installer-linuxx64.sh
  yes | bash roon-setup.sh
}

port_forward() {
  _log_call "$*"

  local ip
  ip=$(_vm_exec _wait_ip)

  forward_acc="FORWARD -o $VM_IFACE -d $ip -j ACCEPT"
  udp="PREROUTING -t nat -p udp --dport 9003 -j DNAT --to-destination $ip:9003"
  tcp_1="PREROUTING -t nat -p tcp --dport 9100:9200 -j DNAT --to-destination $ip:9100-9200"
  tcp_2="PREROUTING -t nat -p tcp --dport 9300:9339 -j DNAT --to-destination $ip:9300-9339"

  if [[ "$1" == "clear" ]]; then
    sudo iptables -D $forward_acc
    sudo iptables -D $udp
    sudo iptables -D $tcp_1
    sudo iptables -D $tcp_2
  else
    sudo iptables -C $forward_acc || sudo iptables -I $forward_acc
    sudo iptables -C $udp || sudo iptables -I $udp
    sudo iptables -C $tcp_1 || sudo iptables -I $tcp_1
    sudo iptables -C $tcp_2 || sudo iptables -I $tcp_2
  fi
}

if [[ "$@" == "" ]]; then
    start
else
    $@
fi
