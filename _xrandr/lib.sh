#!/usr/bin/env bash

do_math() {
  local exp="${1}"
  echo $exp | bc | awk '{printf("%d\n",$1 + 0.5)}'
}

# Internal monitor + its resolution
internal="eDP1"
IW="3200"
IH="1800"

# External monitor, its native resolution and the scaled resolution
# computed with `bc`
external="DP1"
EW="3440"
EH="1440"
SCALE="1"
EW_SCALED=$(do_math "${EW}*${SCALE}")
EH_SCALED=$(do_math "${EH}*${SCALE}")
