# ____   ____
# |   \  |  |______
# |    \ |  | ___  \
# |     \|  | |  \  |
# |  \   \  | |__/  |
# |  |\     | _____/
# |__| \____| | Author: Nico Pareigis
#          |__| Zsh

[[ -t 0 && $- == *i* ]] && stty -ixon

set -o autocd -o bashrematch -o extendedglob -o histexpiredupsfirst\
  -o histignorealldups -o histignorespace -o incappendhistory -o ksharrays\
  -o kshglob -o pipefail -o promptsubst -o rematchpcre
set +o automenu +o autoremoveslash

export KEYTIMEOUT=1
export SAVEHIST=10000
export HISTSIZE=$(($SAVEHIST + 100))
export HISTFILE="$HOME/.zsh_history"
export LESSHISTFILE=-

[[ -f $HOME/.machine ]] && MACHINE=`< $HOME/.machine` || MACHINE=DT
export MACHINE
export VISUAL=nvim
export EDITOR=$VISUAL

[[ -f $HOME/.env ]] && . "$HOME/.env"

# ------------------------------------------------------------------------------

function _rc_path {
  typeset bin="/usr/bin:/usr/local/bin:$HOME/.local/bin"\
    perl='/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl'
  typeset -a misc=()

  [[ -n $GOPATH ]] && misc+=("$GOPATH/bin")
  [[ -n $CARGO_HOME ]] && misc+=("$CARGO_HOME/bin")
  [[ -n $JAVA_HOME ]] && misc+=("$JAVA_HOME/bin")

  local IFS=':'
  printf "$bin:$perl:${misc[*]}"
}
export PATH=`_rc_path`

[[ -f $HOME/.aliases ]] && . "$HOME/.aliases"

function preexec {
  # does not detect obfuscated commands
  # aliases / indirection / symlinks, newlines / whitespace
  [[ $3 =~ 'rm'([ \t])+'-r' && $3 =~ ('\$HOME'|$HOME) ]] && {
    printf 'WARNING: trying to remove $HOME? '
    sleep 60
    return 1
  }
}

# ------------------------------------------------------------------------------

autoload edit-command-line
function _rc_reverse_i_search {
  typeset -a hist=(`history 1 | tac | zf --height 16 -kp`)
  zle reset-prompt
  BUFFER=${hist[1,${#hist[@]}]:-$BUFFER}
  CURSOR=$#BUFFER
}

zle -N edit-command-line
zle -N _rc_reverse_i_search

bindkey -v '^K' kill-line
bindkey -v '^U' backward-kill-line
bindkey -v '^Y' yank
bindkey -v '^?' backward-delete-char # don't delete to killring

bindkey '^Xe' edit-command-line
bindkey '^R' _rc_reverse_i_search
bindkey '^I' complete-word
bindkey '^ ' expand-word

# ------------------------------------------------------------------------------

function _rc_ps1_get_git_head {
  typeset head=`git rev-parse --is-inside-work-tree 2>/dev/null`
  ( (( $? != 0 )) || [[ $head != true ]] ) && return 1

  typeset -A refs
  while read; do
    refs+=([${${REPLY#* }%\^\{\}}]="${REPLY% *}")
  done < <(git -C . show-ref --head --heads --tags --abbrev -d)

  head=HEAD
  typeset hid=${refs[HEAD]}
  typeset -i m b
  for ref id in "${(kv)refs[@]}"; do
    [[ $ref == HEAD ]] && continue

    if [[ $hid == $id ]]; then
      let m++
      [[ $ref =~ refs/heads/ ]] && let b++
      head=${ref#refs/*/}
      hid=$id
    fi
  done

  if (( m == 0 )); then
    head=$hid
  elif (( b > 1 )) || (( m > b && b > 0 )); then
    # NOTE: detached head at branch head prefers tag-name over commit
    typeset branch=`git -C . branch --show-current`
    [[ -n $branch ]] && head="$branch"
  fi

  printf "$head"
}
function _rc_ps1_get_git_stash {
  typeset head=$1
  [[ -z $head ]] && return 1

  typeset tl=`git rev-parse --show-toplevel`
  [[ -f $tl/.git ]] && {
    tl=`< $tl/.git`
    tl=${tl#gitdir: }
    [[ -f $tl/commondir ]] && tl+=/`< $tl/commondir`
  }

  [[ -f $tl/refs/stash || -f $tl/.git/refs/stash ]] && printf '~'
}
function _rc_ps1_get_git {
  typeset head=`_rc_ps1_get_git_head` stash=
  [[ -n $head ]] && stash=`_rc_ps1_get_git_stash $head`
  printf "$head$stash"
}

xset q &>/dev/null && [[ -f $HOME/.prompt_char ]] && {
  while read; do
    [[ -z $REPLY ]] && continue
    _rc_ps1_chr=$REPLY
    break
  done < $HOME/.prompt_char
}
_rc_ps1_chr=${_rc_ps1_chr:-\$}

typeset -A _rc_ps1_cl=(
  [bld]=$'\e[1m'
  [clr]=$'\e[0m'
  [chr]=$'\e[38;2;160;160;160m'
  [git]=$'\e[38;2;252;163;38m'
  [err]=$'\e[38;2;230;126;128m'
  [txt]=$'\e[38;2;211;198;170m'
)

function _rc_ps1_set {
  unset PS1
  typeset ex cwd
  (( $1 == 0 )) && ex= || ex=$1

  typeset git=`_rc_ps1_get_git`
  typeset job='%j'

  PS1="%{${_rc_ps1_cl[txt]}%}"
  [[ $PWD == / ]] && cwd=/ || cwd=${PWD##*/}
  [[ $PWD != $HOME ]] && PS1+="$cwd "
  [[ -n $git ]]       && PS1+="%{${_rc_ps1_cl[git]}%} $git "
  (( ${(%)job} > 0 )) && PS1+="%{${_rc_ps1_cl[chr]}%}%% "
  [[ -n $ex ]]        && PS1+="%{${_rc_ps1_cl[err]}${_rc_ps1_cl[bld]}%}$ex%{${_rc_ps1_cl[clr]}%} "
  PS1+="%{${_rc_ps1_cl[chr]}%}$_rc_ps1_chr%{${_rc_ps1_cl[clr]}%} "
}

if xset q &>/dev/null; then
  function precmd {
    EXIT=$?
    _rc_ps1_set $EXIT
  }
  function zle-keymap-select {
    [[ $KEYMAP == main ]] && _rc_ps1_set $EXIT
    [[ $KEYMAP == vicmd ]] && _rc_ps1_chr=: _rc_ps1_set $EXIT
    zle reset-prompt
  }
  zle -N zle-keymap-select
else
  PS1=$'%1~ $ '
fi

# ------------------------------------------------------------------------------

if [[ -o login ]]; then
  function set_colours {
    typeset f='38;5;'

    typeset LSC="bd=${f}03:cd=${f}11:di=${f}03:ex=${f}07;4:fi=${f}07:ln=${f}04;4:or=${f}08;4"
    typeset BLD=`clsc -s \*Brewfile:\*bsconfig.json:\*BUILD:\*BUILD.bazel:\*build.gradle:\*build.sbt:\*build.xml:\*Cargo.toml:\*CMakeLists.txt:\*composer.json:\*configure:\*Containerfile:\*Dockerfile:\*Earthfile:\*flake.nix:\*Gemfile:\*GNUmakefile:\*Gruntfile.coffee:\*Gruntfile.js:\*jsconfig.json:\*Justfile:\*justfile:\*Makefile:\*makefile:\*meson.build:\*mix.exs:\*package.json:\*Pipfile:\*PKGBUILD:\*Podfile:\*pom.xml:\*Procfile:\*pyproject.toml:\*Rakefile:\*RoboFile.php:\*SConstruct:\*tsconfig.json:\*Vagrantfile:\*webpack.config.cjs:\*webpack.config.js:\*WORKSPACE $f'05;4' :`
    typeset ARC=`clsc 7z:ar:br:bz:bz2:bz3:cpio:deb:dmg:gz:iso:jar:lz:lz4:lzh:lzma:lzo:phar:qcow:qcow2:rar:rpm:tar:taz:tbz:tbz2:tc:tgz:tlz:txz:tz:xz:vdi:vhd:vmdk:z:zip:zst $f'11' :`
    typeset IMG=`clsc arw:avif:bmp:cbr:cbz:cr2:dvi:eps:gif:heic:heif:ico:j2c:j2k:jfi:jfif:jif:jp2:jpe:jpeg:jpf:jpg:jpx:jxl:nef:orf:pbm:pgm:png:pnm:ppm:ps:psd:pxm:raw:stl:svg:tif:tiff:webp:xcf:xpm $f'02' :`
    typeset AUD=`clsc aac:alac:ape:flac:m4a:mka:mp2:mp3:ogg:opus:wav:wma $f'05' :`
    typeset TMP=`clsc bak:bk:bkp:swn:swo:swp:tmp $f'08' :`
    typeset VID=`clsc avi:flv:heics:m2ts:m2v:m4v:mkv:mov:mp4:mpeg:mpg:ogm:ogv:video:vob:webm:wmv $f'03' :`

    typeset PERM=`clsc -s ur:gr:tr:uw:gw:tw:ux:gx:tx:ue $f'02' :`
    typeset SIZE=`clsc -s sn:sb:df:ds $f'05' :`
    typeset USER=`clsc -s uu:gu $f'03' :`
    typeset TIME=`clsc -s da $f'04' :`
    typeset STCK=`clsc -s su:sf $f'01' :`

    export LS_COLORS="$LSC:$BLD:$ARC:$IMG:$AUD:$TMP:$VID"
    export EZA_COLORS="reset:$PERM:$SIZE:$USER:$TIME:$STCK"

    export LESS_TERMCAP_mb=$'\e[1;38;5;2m'
    export LESS_TERMCAP_md=$'\e[1;38;5;1m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[3;38;5;3m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[0;38;5;2m'
  }
  set_colours
fi

# ------------------------------------------------------------------------------

zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'l:|=*'
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' verbose false

autoload -Uz compinit
compinit -d "$XDG_CONFIG_HOME/zsh/zcomp"

# ------------------------------------------------------------------------------

xset q &>/dev/null && [[ -f $HOME/.fetch ]] && < $HOME/.fetch || :
