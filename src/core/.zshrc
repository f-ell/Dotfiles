# Author: Nico Pareigis
[[ -t 0 && $- == *i* ]] && stty -ixon

zmodload zsh/mapfile

set -o autocd -o bashrematch -o extendedglob -o histexpiredupsfirst\
  -o histignorealldups -o histignorespace -o incappendhistory -o ksharrays\
  -o kshglob -o pipefail -o promptsubst -o rematchpcre
set +o automenu +o autoremoveslash

KEYTIMEOUT=1
SAVEHIST=10000
HISTSIZE=$(($SAVEHIST + 100))
HISTFILE="$HOME/.zsh_history"
export LESSHISTFILE=-

export MACHINE="${${(f@)mapfile[$HOME/.machine]}[0]:-DT}"
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
  : ${(P)1::=$bin:$perl:${misc[*]}}
}
_rc_path PATH

[[ -f $HOME/.aliases ]] && . "$HOME/.aliases"

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

# Git worktree root. Only updated on directory change, which may cause
# unexpected behaviour when a repository is deleted without a directory change.
typeset -g _rc_ps1_git_root=

function _rc_ps1_find_git_root {
  git rev-parse --show-toplevel 2>/dev/null | read
  if (( $? > 0 )); then
    : ${(P)1::=}
    return 1
  fi

  : ${(P)1::=$REPLY}
  return 0
}

# FIX: this should use the ref/commit found in HEAD instead. Still requires
# tag-resolution / truncation for detached head.
function _rc_ps1_get_git_head {
  typeset -A refs=()
  while read; do
    refs+=([${${REPLY#* }%\^\{\}}]="${REPLY% *}")
  done < <(git -C . show-ref --head --heads --tags --abbrev -d)

  typeset head=HEAD
  typeset hsha=${refs[HEAD]}
  typeset -i m=0 b=0 # m: all matches, b: branch matches
  for ref sha in "${(kv)refs[@]}"; do
    [[ $ref == HEAD ]] && continue

    if [[ $sha == $hsha ]]; then
      let m++                               # HEAD is a valid ref
      [[ $ref =~ ^refs/heads/ ]] && let b++ # HEAD is at branch
      head="${ref#refs/*/}"
    fi
  done

  if (( m == 0 )); then
    head=$hsha
  elif (( b > 1 )) || (( m > b && b > 0 )); then
    # PERF: refactor to native; requires resolving gitdir.
    typeset branch=`git -C . branch --show-current`
    [[ -n $branch ]] && head="$branch"
  fi

  : ${(P)1::=$head}
}

function _rc_ps1_get_git_stash {
  typeset root="$2" head="$3"
  [[ -z $head ]] && return 1

  [[ -f $root/.git ]] && {
    root="${${(f@)mapfile[$root/.git]}[0]#gitdir: }"
    [[ -f $root/commondir ]] && root+=/"${${(f@)mapfile[$root/commondir]}[0]}"
  }

  [[ -f $root/refs/stash || -f $root/.git/refs/stash ]] && : ${(P)1::='~'}
}

function _rc_ps1_get_git {
  typeset root="$2" hd= st=
  [[ -z $root ]] && return

  _rc_ps1_get_git_head hd
  _rc_ps1_get_git_stash st "$root" "$hd"

  : ${(P)1::=$hd$st}
}

typeset -g _rc_ps1_chr="${${(f@)mapfile[$HOME/.prompt_char]}[0]:-\$}"

typeset -gA _rc_ps1_cl=(
  [bld]=$'\e[1m'
  [clr]=$'\e[0m'
  [chr]=$'\e[90m'
  [git]=$'\e[38;2;252;163;38m'
  [err]=$'\e[91m'
  [txt]=$'\e[37m'
)

function _rc_ps1_set {
  unset PS1
  typeset ex= cwd= git= job='%j'
  (( $1 == 0 )) && ex= || ex=$1

  _rc_ps1_get_git git "$_rc_ps1_git_root"

  PS1="%{${_rc_ps1_cl[txt]}%}"
  [[ $PWD == / ]] && cwd=/ || cwd=${PWD##*/}
  [[ $PWD != $HOME ]] && PS1+="$cwd "
  [[ -n $git ]]       && PS1+="%{${_rc_ps1_cl[git]}%} $git "
  (( ${(%)job} > 0 )) && PS1+="%{${_rc_ps1_cl[chr]}%}%% "
  [[ -n $ex ]]        && PS1+="%{${_rc_ps1_cl[err]}${_rc_ps1_cl[bld]}%}$ex%{${_rc_ps1_cl[clr]}%} "
  PS1+="%{${_rc_ps1_cl[chr]}%}$_rc_ps1_chr%{${_rc_ps1_cl[clr]}%} "
}

if xset q &>/dev/null; then
  _rc_ps1_find_git_root _rc_ps1_git_root

  function precmd {
    EXIT=$?
    _rc_ps1_set $EXIT
  }
  function chpwd {
    _rc_ps1_find_git_root _rc_ps1_git_root
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

zstyle ':completion:*:*:nvim:*' ignored-patterns '*.pdf'

autoload -Uz compinit
compinit -d "$XDG_CONFIG_HOME/zsh/zcomp"

# ------------------------------------------------------------------------------

xset q &>/dev/null && [[ -f $HOME/.fetch ]] && < $HOME/.fetch || :
