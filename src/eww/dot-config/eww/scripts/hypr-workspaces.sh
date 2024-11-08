#!/bin/bash

function hypr-workspaces() {
  typeset -i active=`hyprctl -j activeworkspace | jq '.id'`
  typeset templ
  read -d '' templ <<-EOF
  {
    id: .id,
    icon: .id,
    state: (if .id == $active then "focused" elif .windows? > 0 then "occupied" else "empty" end),
    command: "hyprctl dispatch workspace \\\\(.id)"
  }
EOF

  typeset bound=`hyprctl binds -j | jq "map(select(.dispatcher == \"workspace\") | { id: .arg | tonumber } | $templ)"`
  hyprctl workspaces -j | jq -c "map($templ) | sort_by(.id) | . + $bound | unique_by(.id)" --argjson bound "$bound"
}

hypr-workspaces

while IFS='>>' read -a REPLY; do
  case ${REPLY[0]} in
    focusedmon|workspace)              ;&
    createworkspace|destroyworkspace)  ;&
    openwindow|closewindow|movewindow) hypr-workspaces ;;
  esac
done < <(socat $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock STDOUT 2>/dev/null)
