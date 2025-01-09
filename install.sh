#!/bin/bash
trap 'clean'    EXIT
trap 'exit 130' HUP INT QUIT TERM
shopt -u extglob

typeset -A CFG=(
  [aurroot]=/home/aur
  [base]=pkg
  [exec]="${0##*/}"
  [hook]=hooks
  [ifs]="$IFS"
  [logps]=::
)
typeset -A C=(
  [r]=';38;5;1m'
  [g]=';38;5;2m'
  [y]=';38;5;3m'
  [b]=';38;5;4m'
  [m]=';38;5;5m'
  [c]=';38;5;6m'
)
export PS3='==>'

# TODO: documentation

function err {
  printf '%s: %b\n' "${CFG[exec]}" "$2" >&2
  (( $1 > 0 )) && exit $1
}

function clean {
  printf '\e[?25h' # re-enable cursor in case of `logWait`-interrupt
  rm -f ${CFG[logfile]} \
    || err 0 "failed to remove logfile: \e[1m${CFG[logfile]}\e[0m"

  if [[ -e ${CFG[aur]} ]]; then
    rm -rf ${CFG[aur]} \
      || err 0 "failed to remove aurutils install directory: \e[1m${CFG[aur]}\e[0m"
  fi
}

function dep {
  typeset -a missing

  for dep in "$@"; do
    if ! command -v $dep &>/dev/null; then
      missing+=($dep)
    fi
  done

  local IFS=,
  (( ${#missing[@]} > 0 )) && err 5 "missing dependencies: ${missing[*]}"
}

# -------------------------------------------------------- logging and prompting

function stripTermColor {
  for name in "$@"; do
    typeset -n n_str=$name
    printf -v n_str '%b' "$n_str"
    n_str="${n_str//[^[:print:]]/}"
    n_str="${n_str//\[[[:digit:]];[[:digit:]][[:digit:]];[[:digit:]];[[:digit:]]m/}"
    n_str="${n_str//\[[[:digit:]]m/}"
  done
}

function log {
  printf '\e[1%s%s\e[0m %b%s' "${C[${1:-c}]}" "${CFG[logps]}" "$2" "${N-$'\n'}" >&2
}

function logInfo {
  if [[ -z ${C[$1]} ]]; then
    printf '   %b\n' "$1" >&2
  else
    printf '   \e[1%s->\e[0m %b\n' "${C[$1]}" "$2" >&2
  fi
}

# Waits for job to complete. Job status and exit code are checked with `eval`;
# the `eval`-ed values are hardcoded.
function logWait {
  typeset msg="$2"
  stripTermColor msg

  typeset -i lnLen=$(( ${#CFG[logps]} + ${#msg} + 1 ))
  N= log $1 "$2"
  printf '\e[?25l'

  while eval "$3" &>/dev/null; do
    printf '\e[K'
    for _ in {0..2}; do
      read -t 0.2
      printf '.'
    done
    read -t 0.4
    printf '\b\b\b'
  done

  printf '...\n\e[?25h'
  # determine job success
  eval "$4"
  typeset -i x=$?
  if (( $x > 0 )); then
    printf "\e[A\e[$(( lnLen + 3 ))C \e[1${C[r]}Failed\e[0m\n"
    return $x
  fi

  printf "\e[A\e[$(( lnLen + 3 ))C \e[1${C[g]}Done\e[0m\n"
}

function _prompt {
  read -p "$1"
  typeset -i x=$?
  (( $x > 0 )) && exit $x || return 0
}

function prompt {
  typeset pSel=$2 pStr='y/N'
  [[ $pSel == y ]] && pStr='Y/n'

  typeset prompt
  printf -v prompt '\e[1%s%s\e[0m %b [%s] ' "${C[$1]}" "${CFG[logps]}" "$3" "$pStr"

  while _prompt "$prompt"; do
    [[ -z $REPLY ]] && printf '\e[A%s%s\n' "$prompt" "$pSel"

    : ${REPLY:=$pSel}
    case ${REPLY,,} in
      y) return 0 ;;
      n) return 1 ;;
    esac

    printf '\e[A\e[K'
  done
}

# -------------------------------------------------------------- generic utility

function index {
  typeset -ig INDEX=0
  typeset -n n_arr=$1

  for (( i=0; i<${#n_arr[@]}; i++ )); do
    INDEX=$i
    [[ ${n_arr[$i]} == $2 ]] && return $i
  done

  INDEX=-1
  return -1
}

function arrSet {
  typeset -n n_arr=$1
  for (( i=0; i<${#n_arr[@]}; i++ )); do
    n_arr[$i]="$2"
  done
}

function initializeState {
  typeset -n n_state=$1 n_arr=$2
  for (( i=0; i<${#n_arr[@]}; i++ )); do
    n_state[$i]=0
  done
}

function suExec {
  su -c "$1" || {
    typeset -i x=$?
    (( $x == 1 )) && err 4  'failed to acquire elevated privileges'
    (( $x > 0  )) && err $x "fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"
  }
}

# --------------------------------------------------------------- parsing

function parse {
  typeset -n n_file=$2 n_dir=$3
  typeset dir="${1%/}" trim="$4"

  for glob in "$dir"/*; do
    if [[ -d $glob ]]; then
      glob="${glob#$dir/}"
      n_dir+=("$glob")
    else
      glob="${glob#$dir/}"
      n_file+=("${glob%$trim}")
    fi
  done
}

function parsePkgList {
  typeset -n n_core=$1 n_aur=$2
  typeset list=$3
  typeset -i i=0

  log c "Parsing \e[1m$list\e[0m"
  while read; do
    [[ $REPLY =~ ^\s*$ || $REPLY =~ ^\s*# ]] && continue

    # user selection between mutually exclusive packages
    if [[ $REPLY =~ '|' ]]; then
      typeset -a altList=() altState=()
      local IFS='|'

      for pkg in $REPLY; do
        altList+=("$pkg")
        altState+=(0)
      done

      PS3="\e[1${C[y]}$PS3\e[0m Mutually exclusive packages - select one (^D to confirm):" inplaceSelectOne altList altState

      index altState 1
      REPLY=${altList[$INDEX]}
      log c "\e[1m1\e[0m of \e[1m${#altList[@]}\e[0m packages selected: $REPLY"
    fi

    REPLY=${REPLY%%#*}
    [[ $REPLY =~ :AUR$ ]] && n_aur+=(${REPLY%:AUR}) || n_core+=($REPLY)
    let i++
  done <"${CFG[base]}/$list.txt"

  logWait c "Parsing \e[1m$list\e[0m" 'false'
  logInfo "Found \e[1m$i\e[0m package(s) in $list"

  (( $i > 0 ))
}

# --------------------------------------------------------------- list selection

function indexSelect {
  typeset -n n_state=$1 n_index=$2
  typeset input="$3"

  # prevent assignment error in case REPLY is non-decimal number
  printf '%d' "$input" &>/dev/null && n_index=$input
  if (( $n_index <= 0 || $n_index > ${#n_state[@]} )); then
    n_index=-1
    return 0
  fi

  let n_index--
  (( ${n_state[$n_index]} == 0 )) && n_state[$n_index]=1 || n_state[$n_index]=0
}

function rangeSelect {
  typeset -n n_state=$1
  typeset range="$2"
  typeset -a bounds=("${range%-*}" "${range#*-}")

  # needs C-style loop since members may be empty
  for (( i=0; i<${#bounds[@]}; i++ )); do
    if [[ -z ${bounds[$i]} ]] \
      || ! printf '%d' "${bounds[$i]}" &>/dev/null \
      || (( ${bounds[$i]} <= 0 || ${bounds[$i]} > ${#n_state[@]} )); then
      return 0
    fi
  done

  for (( i=${bounds[0]}; i<=${bounds[1]}; i++ )); do
    n_state[$(( i-1 ))]=1
  done
}

# Accepts input in the form
#   INPUT  := TOKEN[,TOKEN]... | * | -
#   TOKEN  := SINGLE | RANGE
#   SINGLE := INDEX
#   RANGE  := INDEX-INDEX
# where 0 < INDEX <= number of items.
#
# RANGE performs an inclusive selection between two indices. The first index
# should be smaller than or equal to the second index.
#
# The two special values "*" and "-" select / deselect all items.
# Malformed inputs result in no-ops.
function _inplaceSelect {
  typeset -n n_items=$1 n_state=$2
  typeset -i i=1

  # print to screen
  for (( i=0; i<${#n_items[@]}; i++ )); do
    (( ${n_state[$i]} == 0 )) \
      && printf '%d) %s\n' $(( $i+1 )) "${n_items[$i]}" \
      || printf '%d) \e[1%s%s\e[0m%s\n' \
        $(( $i+1 )) "${C[b]}" "${PREFIX:-* }" "${n_items[$i]}"
  done
  printf -v PS3 '%b' "$PS3"
  # FIX: return produces additional screen line
  read -p "${PS3% } " </dev/tty # executed in nested loop - requires explicit fd

  if (( $? == 1 )); then
    printf '^D\n'
    return 1
  fi

  # handle selection
  typeset -ig SELECTION=0
  if (( ${SELECTONE:-0} == 1 )); then
    indexSelect ${!n_state} SELECTION "$REPLY"
    return 0
  fi

  if [[ $REPLY == \* ]]; then
    arrSet ${!n_state} 1
    return 0
  elif [[ $REPLY == - ]]; then
    arrSet ${!n_state} 0
    return 0
  fi

  # sanitize globbing or otherwise problematic characters characters
  while [[ $REPLY =~ [^\\](\*|\?|\[|\'|\") ]]; do
    REPLY="${REPLY//"${BASH_REMATCH[1]}"/\\"${BASH_REMATCH[1]}"}"
  done

  local IFS=,
  for field in $REPLY; do
    [[ $field =~ - ]] \
      && rangeSelect ${!n_state} "$field"  \
      || indexSelect ${!n_state} SELECTION "$field"
  done
}

function inplaceSelect {
  typeset -n n_items=$1 n_state=$2
  typeset -i h=$(( ${#n_items[@]} + 1 ))

  log g
  while :; do
    PS3="$PS3" _inplaceSelect ${!n_items} ${!n_state} || break
    printf "\b\e[${h}A\e[J"
  done
}

function inplaceSelectOne {
  typeset -n n_items=$1 n_state=$2
  typeset -i h=$(( ${#n_items[@]} + 1 ))
  arrSet ${!n_state} 0
  n_state[0]=1

  log g
  while :; do
    SELECTONE=1 PS3="$PS3" _inplaceSelect ${!n_items} ${!n_state} || break
    (( $SELECTION >= 0 )) && arrSet ${!n_state} 0 && n_state[$SELECTION]=1
    printf "\b\e[${h}A\e[J"
  done

  (( ${SELECTION:--1} >= 0 )) && arrSet ${!n_state} 0 && n_state[$SELECTION]=1
}

# Updates `pkgSelect` with user selection from package lists in `pkgBase`.
function selectFromBase {
  typeset -n n_out=$1 n_sum=$2 n_items=$3 n_state=$4
  n_sum+=${#n_items[@]}

  index ${!n_items} core
  n_state[$INDEX]=1

  PS3="\e[1${C[g]}$PS3\e[0m Lists to install (^D to confirm): " inplaceSelect ${!n_items} ${!n_state}

  for (( i=0; i<${#n_items[@]}; i++ )); do
    (( ${n_state[$i]} == 1 )) && n_out+=("${n_items[$i]}")
  done
}

# Updates `pkgSelect` with user selection from package lists in `CFG[base]/$1`.
function selectFromDir {
  typeset -n n_out=$1 n_sum=$2
  typeset dir=$3
  typeset -a pkgLists=() pkgState=()

  for glob in ${CFG[base]}/$dir/*; do
    glob="${glob#${CFG[base]}/$dir/}"
    pkgLists+=("${glob%.txt}")
  done
  initializeState pkgState pkgLists
  n_sum+=${#pkgLists[@]}

  index pkgLists core
  (( $INDEX != -1 )) && pkgState[$INDEX]=1

  PS3="\e[1${C[g]}$PS3\e[0m Lists to install (^D to confirm): " inplaceSelect pkgLists pkgState

  if [[ ! ${pkgState[@]} =~ 1 ]]; then
    logInfo "No list selected - skipping $dir"
    return 1
  fi

  for (( i=0; i<${#pkgLists[@]}; i++ )); do
    (( ${pkgState[$i]} == 1 )) && n_out+=("$dir/${pkgLists[$i]}")
  done
}

function selectHooks {
  typeset -n n_out=$1 n_hooks=$2 n_hookState=$3

  PS3="\e[1${C[g]}$PS3\e[0m Hooks to execute (^D to confirm): " inplaceSelect hooks hookState

  for (( i=0; i<${#n_hooks[@]}; i++ )); do
    (( ${n_hookState[$i]} == 1 )) && n_out+=("${n_hooks[$i]}")
  done
}

# ------------------------------------------------------ installation utilitites

function aurutilsInstall {
  if command -v aur &>/dev/null; then
    return 0
  fi

  log y "\e[1maurutils\e[0m not found. Trying to install."
  dep git make
  CFG[aur]=`mktemp -d -p "${XDG_CACHE_HOME:-$HOME/.cache}" aurutils.XXXXXXXXXX`

  read -r -d '' <<-EOF
	  typeset -A CFG=(${CFG[@]@K})
	  typeset -A C=(${C[@]@K})
	
	  (git clone --depth=1 https://github.com/aurutils/aurutils ${CFG[aur]} &>${CFG[logfile]} \
	    && makepkg --dir=${CFG[aur]} -si &>${CFG[logfile]}) &
	  logWait c 'Installing aurutils' 'kill -0 \$!' 'wait \$!' || exit 4
	EOF
  suExec "$REPLY"
}

function aurutilsConfigure {
  aur repo --list-repo &>/dev/null && return 0

  log y 'No local package repository found'
  log c "Configuring new repository in ${CFG[aurroot]} ..."
  [[ -d ${CFG[aurroot]} ]] && err 4 'target directory already exists'

  dep mkdir repo-add

  read -r -d '' PACMAN_CONF <<-EOF
	[aur]
	SigLevel = Optional TrustAll
	Server = file://${CFG[aurroot]}/db
	EOF
  read -r -d '' <<-EOF
	  printf '\n%s\n' "$PACMAN_CONF" >> /etc/pacman.conf
	  mkdir -m 777 -p ${CFG[aurroot]}/{db,build}
	  repo-add ${CFG[aurroot]}/db/aur.db.tar.gz
	EOF

  log y 'Updating pacman.conf'
  suExec "$REPLY"
  log r "Remember to export \e[1mAURDEST=${CFG[aurroot]}/build\e[0m for future use"
}

function aurSync {
  typeset -n n_pkg=$1
  export AURDEST=${CFG[aurroot]}/build AUR_PACMAN_AUTH=su

  logWait c "Building ${#n_pkg[@]} packages" 'false'
  aur sync --noview -rnC "${n_pkg[@]}" \
    || err 4 'failed to build one or more AUR packages'
}

function install {
  typeset -n n_pkg=$1
  typeset -i i=0

  while read; do
    let i++
  done < <(pacman --needed -Sp --print-format='%n' "${n_pkg[@]}")

  if (( $i == 0 )); then
    log c 'All packages already installed, nothing to do'
    return 0
  fi
  (( $i < ${#n_pkg[@]} )) \
    && logInfo "\e[1m$(( ${#n_pkg[@]} - $i ))\e[0m of \e[1m${#n_pkg[@]}\e[0m packages already installed"

  read -r -d '' <<-EOF
	  typeset -A CFG=(${CFG[@]@K})
	  typeset -A C=(${C[@]@K})
	
	  pacman -S --noconfirm ${n_pkg[@]} &>${CFG[logfile]} &
	  logWait y 'Installing \e[1m$i\e[0m package(s)' 'kill -0 \$!' 'wait \$!' \
	    || exit 4
	EOF
  log y 'Acquiring elevated privileges for package installation:'
  suExec "$REPLY"
}

function execHooks {
  typeset -n n_items=$1 n_state=$2
  typeset -a selected=()

  if (( ${#n_items[@]} == 0 )); then
    log r "No hooks found - \e[1${C[r]}skipping\e[0m"
    return 1
  fi

  log m "Found \e[1m${#n_items[@]}\e[0m hook(s)"

  selectHooks selected ${!n_items} ${!n_state}
  if [[ ! ${n_state[@]} =~ 1 ]]; then
    log y "No hooks selected - \e[1${C[y]}skipping hook execution\e[0m"
    return 1
  fi

  log c "Running \e[1m${#selected[@]}\e[0m hook(s)..."
  for (( i=0; i<${#selected[@]}; i++ )); do
    logInfo "hook $(( i+1 )): \e[1m${selected[$i]}\e[0m"

    mapfile <${CFG[hook]}/${selected[$i]}

    local IFS=
    read -r -d '' <<-EOF
		  typeset -A CFG=(${CFG[@]@K})
		  typeset -A C=(${C[@]@K})
		  ${MAPFILE[*]}
		EOF

    bash -c "$REPLY"
  done
}

# ------------------------------------------------------------------------------

if (( $UID == 0 )); then
  prompt y n '\e[1mWARNING:\e[0m script is not desinged to be run as root - continue?' \
    || err 7 "\e[1${C[r]}aborting\e[0m"
fi

dep mktemp pacman su
# using TMPDIR causes r/w-issues as root (fs.protected_regular)
CFG[logfile]=`mktemp -p "${XDG_CACHE_HOME:-$HOME/.cache}" "${CFG[exec]}".log.XXXXXXXXXX`
log c "Logfile created at \e[1m${CFG[logfile]:-}\e[0m"
log

# export all functions for use in subshells and hooks
mapfile < <(declare -F)
export -f ${MAPFILE[@]#declare -f* }

# ------------------------------------------------------- package list selection

typeset -a pkgBase=() pkgBaseState=()
typeset -a pkgDir=()
typeset -a pkgSelect=() pkgCore=() pkgAur=()
typeset -i listSum=0

parse           ${CFG[base]} pkgBase pkgDir '.txt'
initializeState pkgBaseState pkgBase

IFS=,
log m "Found \e[1m${#pkgBase[@]}\e[0m package list(s): ${pkgBase[*]}"
IFS="${CFG[ifs]}"

selectFromBase  pkgSelect listSum pkgBase pkgBaseState

IFS=,
if (( ${#pkgDir[@]} == 1 )); then
  log
  log m "Found \e[1m${#pkgDir[@]}\e[0m package directory: ${pkgDir[*]}"
elif (( ${#pkgDir[@]} > 1 )); then
  log
  log m "Found \e[1m${#pkgDir[@]}\e[0m package directories: ${pkgDir[*]}"
fi
IFS="${CFG[ifs]}"

for dir in "${pkgDir[@]}"; do
  prompt g n "Install packages for \e[1m$dir\e[0m?" || continue
  selectFromDir pkgSelect listSum "$dir"
done

if (( ${#pkgSelect[@]} > 0 )); then
  log
  IFS=,
  log c "\e[1m${#pkgSelect[@]}\e[0m of \e[1m$listSum\e[0m list(s) selected: ${pkgSelect[*]}"
  IFS="${CFG[ifs]}"

  for list in "${pkgSelect[@]}"; do
    parsePkgList pkgCore pkgAur "$list"
  done
  log m "Found \e[1m${#pkgCore[@]}\e[0m packages in \e[1m${#pkgSelect[@]}\e[0m list(s)"
  log

  (( ${#pkgAur[@]} > 0 )) \
    && log m 'AUR packages will be built and installed after core packages'

  read -r -d '' <<-EOF
	  typeset -A CFG=(${CFG[@]@K})
	  typeset -A C=(${C[@]@K})
	
	  pacman -Sy &>${CFG[logfile]} &
	  logWait c 'Updating mirrors' 'kill -0 \$!' 'wait \$!' || exit 4
	EOF
  log y 'Acquiring elevated privileges for mirror update:'
  suExec "$REPLY"

  install pkgCore

  if (( ${#pkgAur[@]} > 0 )); then
    log c 'Installing AUR packages...'
    aurutilsInstall
    aurutilsConfigure
    aurSync pkgAur
    install pkgAur
  fi
else
  log y "No lists selected - \e[1${C[y]}skipping package installation\e[0m"
fi

# ------------------------------------------------------ post-installation hooks

log
if prompt g n 'Run post-installation hooks?'; then
  typeset -a hooks=() hookState=()
  parse           ${CFG[hook]} hooks _
  initializeState hookState hooks
  # FIX: factor out of function -> ugly control flow
  execHooks       hooks hookState
fi

log c 'All done - cleaning up'
