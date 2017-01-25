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
SCALE="1.25"
EW_SCALED=$(do_math "${EW}*${SCALE}")
EH_SCALED=$(do_math "${EH}*${SCALE}")

xrandr --output $external --scale "${SCALE}x${SCALE}" --mode "${EW}x${EH}" \
	--fb "$(($IW + $EW_SCALED))x${EH_SCALED}" --pos "0x0" \
	--output $internal --scale "1x1" --pos "${EW_SCALED}x0"
