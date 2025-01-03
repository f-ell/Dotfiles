#!/bin/bash
trap 'clean'    EXIT
trap 'exit 130' HUP INT QUIT TERM
shopt -u extglob

typeset -A CFG=(
  [base]=pkg
  [exec]="${0##*/}"
  [ifs]="$IFS"
  [logps]=::
)
typeset -A C=(
  [r]=';38;5;1m'
  [g]=';38;5;2m'
  [y]=';38;5;3m'
  [b]=';38;5;4m'
  [a]=';38;5;6m'
)
PS3='==>'

# TODO: documentation

function err {
  printf '%s: %b\n' "${CFG[exec]}" "$2" >&2
  (( $1 > 0 )) && exit $1
}

function clean {
  printf '\e[?25h' # re-enable cursor in case of `logWait`-interrupt
  rm -f ${CFG[logfile]} \
    || err 0 "failed to remove logfile: \e[1m${CFG[logfile]}\e[0m"

  if [[ -e ${CFG[yay]} ]]; then
    rm -rf "${CFG[yay]}" \
      || err 0 "failed to remove yay install directory: \e[1m${CFG[yay]}\e[0m"
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

function stripTermColor {
  for name in "$@"; do
    typeset -n str=$name
    printf -v str '%b' "$str"
    str="${str//[^[:print:]]/}"
    str="${str//\[[[:digit:]];[[:digit:]][[:digit:]];[[:digit:]];[[:digit:]]m/}"
    str="${str//\[[[:digit:]]m/}"
  done
}

function log {
  printf '\e[1%s%s\e[0m %b%s' "${C[${1:-a}]}" "${CFG[logps]}" "$2" "${N-$'\n'}" >&2
}

function logInfo {
  printf '   %b\n' "$1" >&2
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
    printf "\e[A\e[$(( ${lnLen} + 3 ))C \e[1${C[r]}Failed\e[0m\n"
    return $x
  fi

  printf "\e[A\e[$(( ${lnLen} + 3 ))C \e[1${C[g]}Done\e[0m\n"
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

function index {
  typeset -ig INDEX=0
  typeset -n arr=$1

  for (( i=0; i<${#arr[@]}; i++ )); do
    INDEX=$i
    [[ ${arr[$i]} == $2 ]] && return $i
  done

  INDEX=-1
  return -1
}

function arrSet {
  typeset -n arr=$1
  for (( i=0; i<${#arr[@]}; i++ )); do
    arr[$i]="$2"
  done
}

function initializeState {
  typeset -n state=$1 src=$2
  for (( i=0; i<${#src[@]}; i++ )); do
    state[$i]=0
  done
}

function indexSelect {
  typeset -n state=$1 index=$2
  typeset input="$3"

  # prevent assignment error in case REPLY is non-decimal number
  printf '%d' "$input" &>/dev/null && index=$input
  if (( $index <= 0 || $index > ${#state[@]} )); then
    index=-1
    return 0
  fi

  let index--
  (( ${state[$index]} == 0 )) && state[$index]=1 || state[$index]=0
}

function rangeSelect {
  typeset -n state=$1
  typeset range="$2"
  typeset -a bounds=("${range%-*}" "${range#*-}")

  # needs C-style loop since members may be empty
  for (( i=0; i<${#bounds[@]}; i++ )); do
    if [[ -z ${bounds[$i]} ]] \
      || ! printf '%d' "${bounds[$i]}" &>/dev/null \
      || (( ${bounds[$i]} <= 0 || ${bounds[$i]} > ${#state[@]} )); then
      return 0
    fi
  done

  for (( i=${bounds[0]}; i<=${bounds[1]}; i++ )); do
    state[$(( $i-1 ))]=1
  done
}

# Accepts input in the form
#   INPUT  := TOKEN[,TOKEN]... | * | -
#   TOKEN  := SINGLE | RANGE
#   SINGLE := INDEX
#   RANGE  := INDEX-INDEX
# where INDEX > 0 and INDEX <= number of items.
#
# RANGE performs an inclusive selection between two indices. The first index
# should be smaller than or equal to the second index.
#
# The two special values "*" and "-" select / deselect all items.
# Malformed inputs result in no-ops.
function _inplaceSelect {
  typeset -n items=$1 state=$2
  typeset -i i=1

  # print to screen
  for (( i=0; i<${#items[@]}; i++ )); do
    (( ${state[$i]} == 0 )) \
      && printf '%d) %s\n' $(( $i+1 )) "${items[$i]}" \
      || printf '%d) \e[1%s%s\e[0m%s\n' $(( $i+1 )) "${C[b]}" "${PREFIX:-* }" "${items[$i]}"
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
    indexSelect $2 SELECTION "$REPLY"
    return 0
  fi

  if [[ $REPLY == \* ]]; then
    arrSet state 1
    return 0
  elif [[ $REPLY == - ]]; then
    arrSet state 0
    return 0
  fi

  # sanitize globbing or otherwise problematic characters characters
  while [[ $REPLY =~ [^\\](\*|\?|\[|\'|\") ]]; do
    REPLY="${REPLY//"${BASH_REMATCH[1]}"/\\"${BASH_REMATCH[1]}"}"
  done

  local IFS=,
  for field in $REPLY; do
    [[ $field =~ - ]] \
      && rangeSelect $2 "$field"  \
      || indexSelect $2 SELECTION "$field"
  done
}

function inplaceSelect {
  typeset -n items=$1
  typeset -i h=$(( ${#items[@]} + 1 ))

  log
  while :; do
    PS3="$PS3" _inplaceSelect $1 $2 || break
    printf "\b\e[${h}A\e[J"
  done
}

function inplaceSelectOne {
  typeset -n items=$1 state=$2
  typeset -i h=$(( ${#items[@]} + 1 ))
  arrSet state 0
  state[0]=1

  log
  while :; do
    SELECTONE=1 PS3="$PS3" _inplaceSelect $1 $2 || break
    (( $SELECTION >= 0 )) && arrSet state 0 && state[$SELECTION]=1
    printf "\b\e[${h}A\e[J"
  done

  (( ${SELECTION:--1} >= 0 )) && arrSet state 0 && state[$SELECTION]=1
}

function preParse {
  typeset -n base=$1 dir=$2

  for glob in ${CFG[base]}/*; do
    if [[ -d $glob ]]; then
      glob="${glob#${CFG[base]}/}"
      dir+=("$glob")
    else
      glob="${glob#${CFG[base]}/}"
      base+=("${glob%.txt}")
    fi
  done
}

# Updates `pkgSelect` with user selection from package lists in `pkgBase`.
function selectFromBase {
  typeset -n out=$1 sum=$2 pkgLists=$3 pkgState=$4
  sum+=${#pkgLists[@]}

  local IFS=,
  log a "Found \e[1m${#pkgLists[@]}\e[0m package list(s): ${pkgLists[*]}"

  index pkgLists core
  pkgState[$INDEX]=1

  if prompt g y 'Install machine specific packages?'; then
    case $MACHINE in
      dt|DT|desktop)
        index pkgLists dt
        pkgState[$INDEX]=1
        ;;
      lt|LT|laptop)
        index pkgLists lt
        pkgState[$INDEX]=1
        ;;
      *)
        logInfo 'could not determine host type from $MACHINE - using desktop'
        index pkgLists dt
        pkgState[$INDEX]=1
        ;;
    esac
  fi

  PS3="\e[1${C[g]}$PS3\e[0m Lists to install (^D to confirm): " inplaceSelect pkgLists pkgState

  for (( i=0; i<${#pkgLists[@]}; i++ )); do
    (( ${pkgState[$i]} == 1 )) && out+=("${pkgLists[$i]}")
  done
}

# Updates `pkgSelect` with user selection from package lists in `CFG[base]/$1`.
function selectFromDir {
  typeset -n out=$1 sum=$2
  typeset dir=$3
  typeset -a pkgLists=() pkgState=()

  for glob in ${CFG[base]}/$dir/*; do
    glob="${glob#${CFG[base]}/$dir/}"
    pkgLists+=("${glob%.txt}")
  done
  initializeState pkgState pkgLists
  sum+=${#pkgLists[@]}

  index pkgLists core
  (( $INDEX != -1 )) && pkgState[$INDEX]=1

  PS3="\e[1${C[g]}$PS3\e[0m Lists to install (^D to confirm): " inplaceSelect pkgLists pkgState

  if [[ ! ${pkgState[@]} =~ 1 ]]; then
    logInfo "No list selected - \e[1${C[y]}skipping\e[0m $dir"
    return 1
  fi

  for (( i=0; i<${#pkgLists[@]}; i++ )); do
    (( ${pkgState[$i]} == 1 )) && out+=("$dir/${pkgLists[$i]}")
  done
}

function parsePkgList {
  typeset -n core=$1 aur=$2
  typeset list=$3
  typeset -i i=0

  log a "Parsing \e[1m$list\e[0m"
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
      log a "\e[1m1\e[0m of \e[1m${#altList[@]}\e[0m packages selected: $REPLY"
    fi

    REPLY=${REPLY%%#*}
    [[ $REPLY =~ :AUR$ ]] && aur+=(${REPLY%:AUR}) || core+=($REPLY)
    let i++
  done <"${CFG[base]}/$list.txt"

  logWait a "Parsing \e[1m$list\e[0m" 'false'
  logInfo "Found \e[1m$i\e[0m package(s) in $1"

  (( $i > 0 ))
}

function ensureYay {
  if command -v yay &>/dev/null; then
    return 0
  fi

  log y '\e[1myay\e[0m not found. Trying to install...'
  dep git makepgk
  CFG[yay]=`mktemp -d -p "${XDG_CACHE_HOME:-$HOME/.cache}" yay.XXXXXXXXXX`

  (git clone --depth=1 https://github.com/Jguer/yay "${CFG[yay]}" &>${CFG[logfile]} \
    && makepkg --dir="${CFG[yay]}" -si &>${CFG[logfile]}) &
  logWait "${C[a]}" 'Installing yay' 'kill -0 $!' 'wait $!' \
    || err 4 "fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"
}

function installWith {
  typeset -n pkg=$2
  typeset -i i=0

  # FIX: yay does not search AUR with `-Sp`... why are you like this??
  while read; do
    let i++
  done < <($1 --needed -Sp --print-format='%n' "${pkg[@]}")

  if (( $i == 0 )); then
    log a 'All packages already installed, nothing to do'
    return 0
  fi
  (( $i < ${#pkg[@]} )) \
    && logInfo "\e[1m$(( ${#pkg[@]} - $i ))\e[0m of \e[1m${#pkg[@]}\e[0m packages already installed"

  su -c "$1 -S \"${pkg[@]}\" ${CFG[logfile]}" &>${CFG[logfile]}
  logWait a "Installing \e[1m$i\e[0m package(s)" 'kill -0 $!' 'wait $!' \
    || err 4 "$1 fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"
}

# ------------------------------------------------------------------------------

if (( $UID == 0 )); then
  prompt y n '\e[1mWARNING:\e[0m script is not desinged to be run as root - continue?' \
    || err 7 "\e[1${C[r]}aborting\e[0m"
fi

dep mktemp pacman su
# XDG_CACHE_HOME is used instead of TMPDIR to circumvent r/w-issues as root (see
# fs.protected_regular)
CFG[logfile]=`mktemp -p "${XDG_CACHE_HOME:-$HOME/.cache}" "${CFG[exec]}".log.XXXXXXXXXX`
log a "Logfile created at \e[1m${CFG[logfile]:-}\e[0m"

export -f err clean stripTermColor log logInfo logWait

# --------------------------------------------------------------- list selection

typeset -a pkgBase=() pkgBaseState=()
typeset -a pkgDir=()
typeset -a pkgSelect=() pkgCore=() pkgAur=()
typeset -i listSum=0

preParse        pkgBase      pkgDir
initializeState pkgBaseState pkgBase
selectFromBase  pkgSelect    listSum pkgBase pkgBaseState

for dir in "${pkgDir[@]}"; do
  prompt g n "Install packages for \e[1m$dir\e[0m?" || continue
  selectFromDir pkgSelect listSum "$dir"
done

(( ${#pkgSelect[@]} == 0 )) \
  && err 4 "no lists selected - \e[1${C[r]}aborting\e[0m"

IFS=,
log a "\e[1m${#pkgSelect[@]}\e[0m of \e[1m$listSum\e[0m list(s) selected: ${pkgSelect[*]}"
IFS="${CFG[ifs]}"

for list in "${pkgSelect[@]}"; do
  parsePkgList pkgCore pkgAur "$list"
done
log a "Found \e[1m${#pkgCore[@]}\e[0m packages in \e[1m${#pkgSelect[@]}\e[0m list(s)"

# --------------------------------------------------------- package installation

(( ${#pkgAur[@]} > 0 )) \
  && log y 'AUR packages will be installed after core packages'

read -r -d '' <<-EOF
  typeset -A CFG=(${CFG[@]@K})
  typeset -A C=(${C[@]@K})

  pacman -Syy &>${CFG[logfile]} &
  logWait a 'Updating mirrors' 'kill -0 \$!' 'wait \$!' || exit 4
EOF

su -c "$REPLY" || {
  typeset x=$?
  (( $x == 1 )) && err 4  'failed to acquire elevated privileges'
  (( $x > 0  )) && err $x "fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"
}

installWith pacman pkgCore

# TODO: need to sync AUR?
if (( ${#pkgAur[@]} > 0 )); then
  (( $UID == 0 )) \
    && prompt y n '\e[1mWARNING:\e[0m AUR packages should not be installed as root - continue?'

  if (( ($UID != 0 && $? == 1) || ($UID == 0 && $? == 0) )); then
    log a 'Installing AUR packages...'
    ensureYay && installWith yay pkgAur
  fi
fi

# ------------------------------------------------------ post-installation hooks

log a 'All done - cleaning up'

# TODO: hooks
# * doas configuration : permit nopass :wheel
#   * if LT : permit nopass USER cmd brightnessctl
# * clone repositories : dotfiles, scripts, g, zsh-syntax-highlighting
# * stow dotfiles
# * install fonts
