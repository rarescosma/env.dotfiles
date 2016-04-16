#!/bin/sh

i3-msg "workspace $1"

tmux has-session -t $1

RETVAL=$?

if [ $RETVAL -eq 0 ]; then
    URXVT_C="tmux a -t $1"
    urxvt -e bash -c "$URXVT_C" &
else
    URXVT_C="tmux new -s $1"
    urxvt -e zsh -c "$URXVT_C" &
    while [ $RETVAL -ne 0 ]; do
        tmux has-session -t $1
        RETVAL=$?
    done
    tmux send-keys -t ${1}.0 "teamocil $1 --here" Enter
fi
