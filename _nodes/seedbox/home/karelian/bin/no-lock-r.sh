#!/bin/bash

rm -f $HOME/rtorrent/session_2/rtorrent.lock
exec /usr/bin/rtorrent -D -I -n -o import=$HOME/rtorrent/config.rc

