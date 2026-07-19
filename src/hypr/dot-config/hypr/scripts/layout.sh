#!/bin/bash

function hypr-layout() {
  hyprctl activeworkspace -j | jq -r 'if .tiledLayout == "monocle" then "m" else "t" end'
}

hypr-layout

while IFS='>>' read -a REPLY; do
  case ${REPLY[0]} in
    # This fires far more often than it needs to; this is the only event that
    # fires when changing between layouts.
    activewindow) hypr-layout ;;
  esac
done < <(nc -U $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock 2>/dev/null)
