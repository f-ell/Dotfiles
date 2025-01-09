#!/bin/bash

if [[ -f /etc/doas.conf ]]; then
  logInfo "\e[1${C[r]}->\e[0m doas.conf exists - \e[1${C[r]}aborting\e[0m"
  exit 1
fi

read -r -d '' <<-EOD
  printf "permit nopass :wheel\n" >> /etc/doas.conf
  [[ ${MACHINE:-DT} == LT ]] \
    && printf "permit nopass $USER cmd brightnessctl" >> /etc/doas.conf
EOD

logInfo "\e[1${C[y]}->\e[0m Acquiring elevated privileges:"
suExec "$REPLY"
