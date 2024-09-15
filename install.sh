#!/bin/bash
trap "clean 130" HUP INT QUIT KILL TERM

typeset -A CFG=(
  [base]=pkg
  [ifs]="$IFS"
  [logps]=::
  [aur]=0
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
# TODO: coloured + bolded output where applicable

function err {
  printf '%s: %b\n' "${0##*/}" "$2" >&2
  (( $1 > 0 )) && clean $1
}
function clean {
  printf '\e[?25h' # re-enable cursor in case of `logWait`-interrupt
  rm -f "${CFG[logfile]}" || err 0 "failed to remove logfile: ${CFG[logfile]}"

  if [[ -e ${CFG[yay]} ]]; then
    rm -rf "${CFG[yay]}" \
      || err 0 "failed to remove yay install directory: ${CFG[yay]}"
  fi

  exit ${1:-0}
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
  printf '\e[1%s%s\e[0m %b\n' "${C[${1:-a}]}" "${CFG[logps]}" "$2" >&2
}
function logInfo {
  printf '   %b\n' "$1" >&2
}
function logWait {
  typeset msg="$2"
  stripTermColor msg

  typeset -i lnLen=$(( ${#CFG[logps]} + ${#msg} + 1 ))
  # FIX: produces an additional line, since \n is appended by default
  log $1 "$2"
  printf "\e[A\e[${lnLen}C\e[?25l"

  while eval "$3" &>/dev/null; do
    printf '\e[K'
    for _ in {0..2}; do
      sleep 0.2
      printf '.'
    done
    sleep 0.4
    printf '\b\b\b'
  done

  printf '...\n\e[?25h'
  # determine job success
  eval "$4"
  typeset x=$?
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

function handleSelect {
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
#   INPUT := TOKEN[,TOKEN]...
#   TOKEN := INDEX[-INDEX]
# where INDEX > 0 and INDEX <= number of items.
# Special cases to select or deselect all items are also supported:
#   INPUT := *|-
function _inplaceSelect {
  typeset -n items=$1 state=$2
  typeset -i i=1

  for (( i=0; i<${#items[@]}; i++ )); do
    (( ${state[$i]} == 0 )) \
      && printf '%d) %s\n' $(( $i+1 )) "${items[$i]}" \
      || printf '%d) \e[1%s%s\e[0m%s\n' $(( $i+1 )) "${C[b]}" "${PREFIX:-* }" "${items[$i]}"
  done
  printf -v PS3 '%b' "$PS3"
  read -p "${PS3% } "

  if (( $? == 1 )); then
    printf '^D\n'
    return 1
  fi

  typeset -ig SELECTION=0
  if [[ -n $SELECTONE ]]; then
    handleSelect $2 SELECTION $REPLY
    return 0
  fi

  if [[ $REPLY == \* ]]; then
    arrSet state 1
    return 0
  elif [[ $REPLY == - ]]; then
    arrSet state 0
    return 0
  fi

  local IFS=,
  for field in $REPLY; do
    [[ $field =~ - ]] \
      && rangeSelect $2 "$field"  \
      || handleSelect $2 SELECTION "$field"
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
    SELECTONE=y PS3="$PS3" _inplaceSelect $1 $2 || break
    (( $SELECTION >= 0 )) && arrSet state 0 && state[$SELECTION]=1
    printf "\b\e[${h}A\e[J"
  done

  (( ${SELECTION:--1} >= 0 )) && arrSet state 0 && state[$SELECTION]=1
}

function getPkgLists {
  typeset -ag pkgList=() pkgState=()

  for l in ${CFG[base]}/*; do
    l="${l#${CFG[base]}/}"
    l="${l%.txt}"
    pkgList+=("$l")
    pkgState+=(0)
  done

  local IFS=$'\n'
  pkgList=(`sort <<<"${pkgList[*]}"`)
  local IFS=,
  log a "Found \e[1m${#pkgList[@]}\e[0m package lists: ${pkgList[*]}"

  index pkgList core
  pkgState[$INDEX]=1
}

function parsePkgList {
  typeset -ag pkgInstall=()

  for p in "$@"; do
    # nested read requires that this reads from a fd other than 1
    while read -u3 ; do
      [[ -z $REPLY || $REPLY =~ ^\s+$ || $REPLY =~ ^\s*# ]] && continue

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

      pkgInstall+=("${REPLY%%#*}")
    done 3<"${CFG[base]}/$p.txt"

    logWait a "Parsing list \`\e[1m$p\e[0m\`" 'false'
  done

  log a "Found \e[1m${#pkgInstall[@]}\e[0m packages in \e[1m${#@}\e[0m list(s)"
  (( ${#pkgInstall[@]} > 0 ))
}

function ensureYay {
  if command -v yay &>/dev/null; then
    return 0
  fi

  log y '`\e[1myay\e[0m` not found. Trying to install...'
  if ! command -v git &>/dev/null; then
    logInfo "\`\e[1mgit\e[0m\` not found - \e[1${C[r]}aborting\e[0m"
    return 1
  fi

  CFG[yay]=`mktemp -d -p "${TMPDIR:-/tmp}" yay.XXXXXXXXXX`
  typeset _PWD="$PWD"

  # TODO: doing this with pushd / popd would arguably be nicer
  (git clone --depth=1 https://github.com/Jguer/yay "${CFG[yay]}" \
    && cd "${CFG[yay]}" \
    && makepkg -si)&
  logWait a "Installing yay" 'kill -0 $!' 'wait $!'
  cd "$_PWD"
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

  # FIX: handle privilege escalation
  $1 --noconfirm --needed -S "${pkg[@]}" &>"${CFG[logfile]}" &
  logWait a "Installing \e[1m$i\e[0m package(s)" 'kill -0 $!' 'wait $!' \
    || err 4 "$1 fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"
}

# ------------------------------------------------------------------------------

if (( $UID == 0 )); then
  prompt y n '\e[1mWARNING:\e[0m script is not desinged to be run as root - continue?' \
    || err 7 "\e[1${C[r]}aborting\e[0m"
fi

dep pacman sort mktemp
CFG[logfile]=`mktemp -p "${TMPDIR:-/tmp}" "${0##*/}".log.XXXXXXXXXX`
log a "Logfile created at ${CFG[logfile]:-}"

# ------------------------------------------------------------ package selection

getPkgLists

if prompt a y 'Install machine specific packages?'; then
  case $MACHINE in
    dt|DT|desktop)
      index pkgList dt
      pkgState[$INDEX]=1
      ;;
    lt|LT|laptop)
      index pkgList lt
      pkgState[$INDEX]=1
      ;;
    *)
      logInfo "could not determine host type from \$MACHINE - using desktop"
      index pkgList dt
      pkgState[$INDEX]=1
      ;;
  esac
fi

PS3="\e[1${C[g]}$PS3\e[0m Lists to install (^D to confirm): " inplaceSelect pkgList pkgState
[[ ${pkgState[@]} =~ 1 ]] || err 4 "no lists selected - \e[1${C[r]}aborting\e[0m"

typeset -a pkgSelect=()
for (( i=0; i<${#pkgList[@]}; i++ )); do
  (( ${pkgState[$i]} == 0 )) && continue
  pkgSelect+=("${pkgList[$i]}")
done

IFS=,
log a "${#pkgSelect[@]} of ${#pkgList[@]} list(s) selected: ${pkgSelect[*]}"
IFS="$_IFS"

# --------------------------------------------------------- package installation

if [[ ${pkgSelect[@]} =~ aur ]]; then
  CFG[aur]=1
  index pkgSelect aur
  unset pkgSelect[$INDEX]
fi

if (( ${#pkgSelect[@]} > 0 )); then
  (( ${CFG[aur]} == 1 )) \
    && log y 'AUR packages will be installed after all other packages'

  # FIX: handle privilege escalation
  pacman -Syy &>"${CFG[logfile]}" &
  logWait a 'Updating mirrors' 'kill -0 $!' 'wait $!' \
    || err 4 "pacman fatal: \e[0${C[r]}`<${CFG[logfile]}`\e[0m"

  parsePkgList "${pkgSelect[@]}" && installWith pacman pkgInstall
fi

# TODO: need to sync AUR?
if (( ${CFG[aur]} == 1 )); then
  (( $UID == 0 )) \
    && prompt y n '\e[1mWARNING:\e[0m AUR packages should not be installed as root - continue?'

  if (( ($UID != 0 && $? == 1) || ($UID == 0 && $? == 0) )); then
    log a 'Installing AUR packages...'
    ensureYay && parsePkgList aur && installWith yay pkgInstall
  fi
fi

# ------------------------------------------------------ post-installation hooks

log a 'All done - cleaning up'
clean

# TODO: hooks
# * doas configuration : permit nopass :wheel
#   * if LT : permit nopass USER cmd brightnessctl
# * clone repositories : dotfiles, scripts, g, zsh-syntax-highlighting, zsh-autosuggestions
# * stow dotfiles
# * install fonts
