#!/bin/sh

LISTMONITORS=$(xrandr --current --listmonitors | grep -v '^Monitors' | awk '{print $NF}' | sort | tr '\n' ' ' | sed 's/ $//g')
[ -f /proc/acpi/button/lid/LID0/state ] && LID_STATE=$(grep -oE '[^ ]+$' /proc/acpi/button/lid/LID0/state)

case "${LISTMONITORS}" in
'DP-0 HDMI-0')
  RES_DP0=$(xrandr --current | grep -A1 DP-0 | tail -1 | awk '{print $1}')
  RES_HDMI0=$(xrandr --current | grep -A1 HDMI-0 | tail -1 | awk '{print $1}')
  # Home AOC +Benq
  if [ "x${RES_DP0}" = "x2560x1440" ] && [ "x${RES_HDMI0}" = "x1920x1080" ]; then
    xrandr --dpi 96 \
      --output HDMI-0 --mode ${RES_HDMI0} --pos 0x0 --rotate right \
      --output DP-0 --primary --mode ${RES_DP0} --pos 1080x0 --rotate normal
    i3-msg "workspace 1, move workspace to output DP-0"
    i3-msg "workspace 2, move workspace to output HDMI-0"
  fi
  ;;
'DP1-1 DP3 eDP1')
  RES_DP11=$(xrandr --current | grep -A1 DP1-1 | tail -1 | awk '{print $1}')
  RES_DP3=$(xrandr --current | grep -A1 DP3 | tail -1 | awk '{print $1}')

  # Home AOC +Benq / laptop docked on dell
  #if [ "x${RES_DP3}" = "x2560x1440" ] && [ "x${RES_DP11}" = "x1920x1080" ] && [ "x${LID_STATE}" = "xclosed" ]; then
    xrandr --dpi 96 --output eDP1 --off \
      --output DP1-1 --mode ${RES_DP11} --pos  0x0 --rotate right \
      --output DP3 --primary --mode ${RES_DP3} --pos 1080x0 --rotate normal
    i3-msg "workspace 1, move workspace to output DP3"
    i3-msg "workspace 2, move workspace to output DP1-1"
    pkill xautolock ; xset s off ; xset -dpms ; xset s noblank
    #nmcli radio wifi off
  #fi
  ;;
'eDP1')
  DPI=144
  echo "Xft.dpi: ${DPI}" | xrdb -merge
  xrandr --dpi ${DPI}
  ;;
*)
  echo ${LISTMONITORS}
  ;;
esac

if [ $# -eq 1 ]; then
  i3-msg $1
fi

nitrogen --restore
