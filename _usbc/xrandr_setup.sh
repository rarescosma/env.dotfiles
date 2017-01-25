#!/usr/bin/env bash

MAINOUTPUT="eDP1"  # Obtained from xrandr --current
MAINPROVIDER="0"   # Obtained from xrandr --listproviders
WIDTH="3440"       # Width of DisplayPort monitor in pixels
HEIGHT="1440"      # Height of DisplayPort monitor in pixels

# Behave like `echo`, but print the first arg in blue, and subsequent args in
# regular font. Purely for eyecandy.
function blueprint() {
    tput setaf 6
    tput bold
    for arg in "$@"; do
        printf "$arg "
        tput sgr0
    done
    echo
}

# Print in bold red text to stderr and exit the program with status 1.
function fail() {
    tput setaf 1
    tput bold
    for arg in "$@"; do
        echo "$arg" > /dev/stderr
        tput sgr0
    done
    tput sgr0
    exit 1
}

# Obtain the dimensions of the main provider.
mainstatus=$(xrandr --current | grep "$MAINOUTPUT" | cut -d ' ' -f 4)

if [ -z "$mainstatus" ]; then
    fail "<< Couldn't get status of main output $MAINOUTPUT >>"
fi

# Get the width, height, and position of the main provider from $mainstatus
# so we can place the DisplayPort output next to it.
attributes=($(sed \
            's/\([0-9]\+\)x\([0-9]\+\)+\([0-9]\+\)+\([0-9]\+\)/\1 \2 \3 \4/g' \
            <<< "$mainstatus"))

# Break attributes into component parts so we can use nice descriptive names.
mainwidth="${attributes[0]}"
mainheight="${attributes[1]}"
mainx="${attributes[2]}"
mainy="${attributes[3]}"

blueprint ">> Main output config:"\
          "$mainwidth"x"$mainheight" 'resolution'\
          'at position ('"$mainx"','"$mainy"')'

dpoutput=$(xrandr | grep "^DP1 connected" | cut -d ' ' -f 1)
[ "$dpoutput" ] || fail "<< Failed to find the DisplayPort output >>";

blueprint ">> DisplayPort output: " "$dpoutput"

# The payoff. If this passes, we're in business.
xrandr --output "$MAINOUTPUT" \
       --mode "$mainwidth"x"$mainheight" \
       --pos "$mainx"x"$mainy" --rotate normal \
       --output "$dpoutput" \
       --pos "$mainwidth"x"$mainy" --rotate normal \
 || fail "<< Couldn't configure xrandr outputs - try doing it manually >>"
