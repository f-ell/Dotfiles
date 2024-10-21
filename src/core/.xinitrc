#!/bin/sh
if [ $MACHINE = 'DT' ]; then
  xrandr --output DP-2 --primary --mode 1920x1080 --rate 144.00 --dpi 92 \
    --output DP-0 --mode 1920x1080 --rate 144.00 --dpi 92 --right-of DP-2 &
  xrdb -merge ~/.Xresources &

  noisetorch -u && noisetorch -i -t 80 -s alsa_input.usb-Generic_Blue_Microphones_201701110001-00.analog-stereo &
  polychromatic-cli -n "Razer Viper Ultimate (Wireless)" --dpi 1000 -o poll_rate -p 1000 -z logo -o none &
else
  xinput set-prop "DLL07D1:01 044E:120B" "libinput Tapping Enabled" 1 &
fi

setxkbmap de -option caps:swapescape &
xsetroot -cursor_name left_ptr &
xset r rate 200 75 &
# xset m 1 0 &

polkit-dumb-agent &

exec bspwm
