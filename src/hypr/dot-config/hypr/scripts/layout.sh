#!/bin/bash

function hypr-layout() {
  hyprctl activeworkspace -j | jq -r 'if .hasfullscreen then "m" else "t" end'
}

hypr-layout

while IFS='>>' read -a REPLY; do
  case ${REPLY[0]} in
    focusedmon|workspace)   ;&
    fullscreen) hypr-layout ;;
  esac
done < <(socat $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock STDOUT 2>/dev/null)
