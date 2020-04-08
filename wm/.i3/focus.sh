#!/usr/bin/env bash

out=$(zenity --entry --title="Change focus" --text="Focus on: ")
if [[ "$?" == "0" ]];
then
    echo "$out" > /tmp/focus
fi
