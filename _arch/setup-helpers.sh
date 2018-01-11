#!/bin/bash

set -xe

net::enable_wifi() {
    IF="${IF:-wlp3s0}"
    SSID="${SSID:-getbetter}"

    ip link set $IF up

    echo -n "${SSID} passphrase:"
    read -s PASSPHRASE
    echo
    wpa_supplicant -i $IF -c <(wpa_passphrase "${SSID}" "${PASSPHRASE}") -B

    sleep 5
    dhcpcd $IF
}

pac::list() {
  # packages from groups
  comm -23 <(pacman -Qqet | sort) <(pacman -Qqg base base-devel xorg i3 | sort)
}

# Dispatch
"$@"
