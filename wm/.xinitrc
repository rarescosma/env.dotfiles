#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

if [ -s ~/.Xmodmap ]; then
  xmodmap ~/.Xmodmap
fi

dbus-update-activation-environment --systemd DISPLAY
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID

exec i3
