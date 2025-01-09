#!/bin/bash

if [[ -f /etc/doas.conf ]]; then
  logInfo r "doas.conf exists - \e[1${C[r]}aborting\e[0m"
  exit 1
fi

read -r -d '' <<-EOD
  printf 'permit nopass :wheel\n' >> /etc/doas.conf
  [[ ${MACHINE:-DT} == LT ]] \
    && printf 'permit nopass $USER cmd brightnessctl' >> /etc/doas.conf
EOD

logInfo y 'Acquiring elevated privileges:'
suExec "$REPLY"
