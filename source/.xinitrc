#!/bin/sh
xrandr --output DP-2 --primary --mode 1920x1080 --rate 144.00 --dpi 92 --output DP-0 --mode 1920x1080 --rate 144.00 --dpi 92 --right-of DP-2 &
xrdb -merge ~/.Xresources &

setxkbmap de -option caps:swapescape &
xsetroot -cursor_name left_ptr &
xset r rate 250 55 &
# xset m 1 0 &

polkit-dumb-agent &

exec bspwm
# exec qtile start
