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

if [ -s ~/.config/X11/Xresources ]; then
  xrdb -merge ~/.config/X11/Xresources
fi

dbus-update-activation-environment --systemd DISPLAY

env | sort > ${XDG_CONFIG_HOME}/systemd/user/xinitrc.env

exec i3
