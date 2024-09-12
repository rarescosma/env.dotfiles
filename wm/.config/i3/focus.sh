#!/usr/bin/env bash

out=$(zenity --entry --title="Change focus" --text="Focus on: ")
if [[ "$?" == "0" ]];
then
  mkdir -p /tmp/i3
  echo "$out" > /tmp/i3/focus
fi
