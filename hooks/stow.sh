#!/bin/bash

if [[ ! -d $HOME/dev ]]; then
  logInfo c '$HOME/dev not found - creating'
  dep mkdir

  if ! mkdir ~/dev &>${CFG[logfile]}; then
    logInfo r "mkdir fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"
    exit 1
  fi
fi

typeset -a packages=() packageState=() packageSelect=()
parse           src _ packages
initializeState packageState packages
index           packages core
packageState[$INDEX]=1

logInfo m "Found \e[1m${#packages[@]}\e[0m packages(s)"
PS3="\e[1${C[g]}$PS3\e[0m Packages to stow (^D to confirm): " inplaceSelect packages packageState

for (( i=0; i<${#packages[@]}; i++ )); do
  (( ${packageState[$i]} == 1 )) && packageSelect+=("${packages[$i]}")
done

if (( ${#packageSelect[@]} > 0 )); then
  logInfo c "Stowing \e[1m${#packageSelect[@]}\e[0m packages..."
  stow ${packageSelect[@]}
else
  logInfo r "No packages selected - \e[1${C[r]}aborting\e[0m"
fi
