#!/bin/bash

typeset workspace=`hyprctl activeworkspace -j | jq '.id'`

if [[ `hyprctl activeworkspace -j | jq '.hasfullscreen'` == true ]]; then
  case $1 in
    l|r) hyprctl dispatch focusmonitor $1 ;;
    u) hyprctl dispatch layoutmsg cycleprev ;;
    d) hyprctl dispatch layoutmsg cyclenext ;;
  esac

  # FIX: cycle window based on screen position
  #
  # could use `general:no_focus_fallback false` temporarily, though this doesn't
  # cycle left/right properly
  #
  # ex cycle down:
  # 1. go down  | same x cord but higher y cord
  # 2. go right | same y cord but higher x cord
  # 3. go first | lowest x and Y cord
  #
  # special case:
  # window below + window right should cycle right

  # typeset addr=`hyprctl activewindow -j | jq -r '.address'`
  # typeset clients=`hyprctl clients -j | jq -c "map(select(.workspace.id == $workspace)) | map(.address) | index(\"$addr\") as \\\$x | [.[\\\$x-1], .[\\\$x+1]]"`
  #
  # case $1 in
  #   u) hyprctl dispatch focuswindow address:`printf '%s' "$clients" | jq -r '.[0]'` ;;
  #   d) hyprctl dispatch focuswindow address:`printf '%s' "$clients" | jq -r '.[1]'` ;;
  # esac
else
  hyprctl dispatch movefocus $1
fi
