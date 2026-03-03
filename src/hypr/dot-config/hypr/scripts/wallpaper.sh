#!/bin/bash

typeset set=0
if [[ $1 == --set ]]; then
  set=1
  shift
fi

if [[ $1 == -- ]]; then
  shift
fi

typeset file=
if [[ -f $1 ]]; then
  file="$1"
else
  typeset -a files=(${XDG_PICTURE_HOME:-~/Pictures}/Wallpapers/ivan_shishkin/*)
  typeset -i i=$((RANDOM % ${#files[@]}))

  file="${files[$i]}" 
fi

cp "$file" ~/.wallpaper

if command -v magick &>/dev/null; then
  magick ~/.wallpaper \
    -gravity center -crop 16:9 -scale 1920x1080 \
    -gravity northwest -region 640x1080+0+0 -blur 0x20 \
    -fill black -colorize 10% \
    +repage ~/.wallpaper-lock

  magick ~/.wallpaper \
    -gravity center -crop 16:9 -scale 1920x1080\> \
    -scale 40% \
    +repage ~/.wallpaper-lowres
else
  cp ~/.wallpaper{,-lock}
  cp ~/.wallpaper{,-lowres}
fi

if (( $set == 1 )); then
  while read; do
    hyprctl hyprpaper wallpaper "$REPLY","$HOME/.wallpaper",contain
  done < <(hyprctl -j monitors | jq -r '.[] | .name')
fi
