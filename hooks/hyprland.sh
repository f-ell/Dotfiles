#!/bin/bash

# Creates necessary unit files for a Hyprland session.
#
# https://wiki.hypr.land/Useful-Utilities/Systemd-start/#hyprland-sessiontarget

if [[ -z $XDG_CONFIG_HOME ]]; then
  logInfo r "\$XDG_CONFIG_HOME not set - \e[1${C[r]}aborting\e[0m"
  exit 1
fi

typeset file="$XDG_CONFIG_HOME/systemd/user/hyprland-session.target"

if [[ -f $file ]]; then
  logInfo r "Unit file exists - \e[1${C[r]}aborting\e[0m"
  exit 1
fi

logInfo c 'Creating unit file'
cat << EOF > $file
[Unit]
Description=Hyprland session
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
PropagatesStopTo=graphical-session.target
EOF
