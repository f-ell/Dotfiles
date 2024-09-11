#!/usr/bin/bash

declare icons='●○'

function desktops {
  declare -a desktops

  for d in `bspc query -D`; do
    declare state
    declare occupied

    bspc query -D -d $d.occupied >/dev/null
    occupied=$?
    (( $occupied == 0 )) && state='occupied' || state='empty'

    bspc query -D -d $d.focused >/dev/null
    (( $? == 0 )) && state='focused'

    desktops+=("{\"id\":\"$d\",\"icon\":\"${icons:${occupied}:1}\",\"state\":\"$state\",\"command\":\"bspc desktop -f $d\"}")
  done

  declare IFS=,
  printf '[%s]\n' "${desktops[*]}"
}

desktops

while read; do
  desktops
done < <(bspc subscribe desktop_{add,focus,remove,transfer} node_{add,remove,transfer})
