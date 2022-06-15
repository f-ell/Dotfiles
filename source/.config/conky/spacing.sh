#!/bin/bash
case $1 in
  cpu) C=True; break;;
  mem) M=True; break;;
  sto) S=True; break;;
esac

Mem=$(free -m | grep "Mem:" | awk '{print $3}')

if [[ "$M" == True ]]; then
  MemTotal
  [[ $Mem -lt 1000 ]]   && String='  '
  [[ $Mem -ge 1000 ]]   && String=' '
  [[ $Mem -ge 10000 ]]  && String=''

  printf "$String%s" $Mem
fi
