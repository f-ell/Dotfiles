#!/bin/sh

Lines=''
while IFS='\n' read -r Line; do
  Lines="$Lines$Line\n"
done < ~/.config/rofi/program_list

Program=$(printf $Lines | rofi -monitor -4 -disable-history -dmenu -i)
$Program &
