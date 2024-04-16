# ____   ____
# |   \  |  |______
# |    \ |  | ___  \
# |     \|  | |  \  |
# |  \   \  | |__/  |
# |  |\     | _____/
# |__| \____| | Author: Nico Pareigis
#          |__| Zsh

[[ -t 0 && $- == *i* ]] && stty -ixon

set -o autocd -o extendedglob -o histexpiredupsfirst -o histignoredups\
  -o histignorespace -o incappendhistory -o kshglob -o pipefail -o promptsubst\
  -o rematchpcre
set +o automenu +o autoremoveslash

SAVEHIST=10000
HISTSIZE=$(($SAVEHIST + 100))
HISTFILE="$HOME/.zsh_history"
LESSHISTFILE=-

if [[ -o login ]]; then
  [[ -f $HOME/.machine ]] && MACHINE=`< $HOME/.machine`
  export MACHINE=${MACHINE:-DT}
  export VISUAL=nvim
  export EDITOR=$VISUAL

  [[ -f $HOME/.env ]] && . "$HOME/.env"

  Bin="/usr/bin:/usr/local/bin:$HOME/.local/bin"
  Perl='/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl'
  Misc="$CARGO_HOME/bin:$JAVA_HOME/bin"
  export PATH="$Bin:$Perl:$Misc"
  unset Bin Perl Misc
fi

[[ -f $HOME/.aliases ]] && . "$HOME/.aliases"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_MANUAL_REBIND=True
. "$XDG_CONFIG_HOME/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
. "$XDG_CONFIG_HOME/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# binds
autoload edit-command-line; zle -N edit-command-line
bindkey -v '^K' kill-line
bindkey -v '^U' backward-kill-line
bindkey -v '^Y' yank
bindkey -v '^?' backward-delete-char # delete without overwriting yank

bindkey '^Xe' edit-command-line
bindkey '^R' vi-history-search-backward
bindkey '^ ' autosuggest-accept

# PS1
if xset q &>/dev/null; then
  function get_git {
    # head
    declare head=`git rev-parse --is-inside-work-tree 2>/dev/null`
    if (( $? == 0 )) && [[ $head == true ]]; then
      declare -A refs
      while read; do
        refs+=([${${REPLY#* }%\^\{\}}]="${REPLY% *}")
      done < <(git -C . show-ref --head --heads --tags --abbrev -d)

      declare href=HEAD hid=${refs[HEAD]}
      declare ref id
      declare -i m b
      for ref id in ${(@kv)refs}; do
        [[ $ref == HEAD ]] && continue

        if [[ $hid == $id ]]; then
          let m++
          [[ $ref =~ refs/heads/ ]] && let b++
          href=${ref#refs/*/}
          hid=$id
        fi
      done

      if (( m == 0 )); then
        href=$hid
      elif (( b > 1 )) || (( m > b && b > 0 )); then
        # NOTE: detached head at branch head prefers tag-name over commit
        declare branch=`git -C . branch --show-current`
        [[ -n $branch ]] && href="$branch"
      fi

      head="$href"
    else
      unset head
    fi

    # stash
    if [[ -n $head ]]; then
      declare tl=`git rev-parse --show-toplevel`
      [[ -f $tl/.git ]] && {
        tl=`< $tl/.git`
        tl=${tl#gitdir: }
        [[ -f $tl/commondir ]] && tl+=/`< $tl/commondir`
      }
      [[ -f $tl/refs/stash || -f $tl/.git/refs/stash ]] && head+=\~
    fi

    printf "$head"
  }

  [[ -f $HOME/.prompt_char ]] && {
    # read first non-empty line
    while read; do
      [[ -z $REPLY ]] && continue
      CHR=$REPLY
      break
    done < $HOME/.prompt_char
  }
  CHR=${CHR:-\$}

  function set_prompt {
    unset PS1
    declare cl_chr=$'\e[38;2;160;160;160m'
    declare cl_err=$'\e[38;2;230;126;128m'
    declare cl_git=$'\e[38;2;252;163;38m'
    declare cl_txt=$'\e[38;2;211;198;170m'
    declare bold=$'\e[1m'
    declare none=$'\e[0m'

    declare ex git pwd
    (( $1 == 0 )) && ex= || ex=$1
    git=`get_git`

    PS1="%{$cl_txt%}"
    [[ $PWD == / ]] && pwd=/ || pwd=${PWD##*/}
    [[ $PWD != $HOME ]] && PS1+=" $pwd"
    [[ -n $git ]]       && PS1+=" %{$cl_git%} $git"
    [[ -n $ex ]]        && PS1+=" %{$cl_err$bold%}$ex%{$none%}"
    PS1+=" %{$cl_chr%}${2:-$CHR} "
  }

  function precmd {
    EXIT=$?
    set_prompt $EXIT
  }

  function zle-keymap-select {
    [[ $KEYMAP == main ]] && set_prompt $EXIT
    [[ $KEYMAP == vicmd ]] && set_prompt $EXIT :
    zle reset-prompt
  }; zle -N zle-keymap-select
else
  PS1=$'%1~ $ '
fi


# colours and highlights
if [[ -o login ]]; then
  function set_colours {
    typeset F='38;5;'

    typeset LSC="bd=${F}03:cd=${F}11:di=${F}03:ex=${F}07;4:fi=${F}07:ln=${F}04;4:or=${F}08;4"
    typeset BLD=`clsc -s \*Brewfile:\*bsconfig.json:\*BUILD:\*BUILD.bazel:\*build.gradle:\*build.sbt:\*build.xml:\*Cargo.toml:\*CMakeLists.txt:\*composer.json:\*configure:\*Containerfile:\*Dockerfile:\*Earthfile:\*flake.nix:\*Gemfile:\*GNUmakefile:\*Gruntfile.coffee:\*Gruntfile.js:\*jsconfig.json:\*Justfile:\*justfile:\*Makefile:\*makefile:\*meson.build:\*mix.exs:\*package.json:\*Pipfile:\*PKGBUILD:\*Podfile:\*pom.xml:\*Procfile:\*pyproject.toml:\*Rakefile:\*RoboFile.php:\*SConstruct:\*tsconfig.json:\*Vagrantfile:\*webpack.config.cjs:\*webpack.config.js:\*WORKSPACE $F'05;4' :`
    typeset ARC=`clsc 7z:ar:br:bz:bz2:bz3:cpio:deb:dmg:gz:iso:jar:lz:lz4:lzh:lzma:lzo:phar:qcow:qcow2:rar:rpm:tar:taz:tbz:tbz2:tc:tgz:tlz:txz:tz:xz:vdi:vhd:vmdk:z:zip:zst $F'11' :`
    typeset IMG=`clsc arw:avif:bmp:cbr:cbz:cr2:dvi:eps:gif:heic:heif:ico:j2c:j2k:jfi:jfif:jif:jp2:jpe:jpeg:jpf:jpg:jpx:jxl:nef:orf:pbm:pgm:png:pnm:ppm:ps:psd:pxm:raw:stl:svg:tif:tiff:webp:xcf:xpm $F'02' :`
    typeset AUD=`clsc aac:alac:ape:flac:m4a:mka:mp2:mp3:ogg:opus:wav:wma $F'05' :`
    typeset TMP=`clsc bak:bk:bkp:swn:swo:swp:tmp $F'08' :`
    typeset VID=`clsc avi:flv:heics:m2ts:m2v:m4v:mkv:mov:mp4:mpeg:mpg:ogm:ogv:video:vob:webm:wmv $F'03' :`

    typeset PERM=`clsc -s ur:gr:tr:uw:gw:tw:ux:gx:tx:ue $F'02' :`
    typeset SIZE=`clsc -s sn:sb:df:ds $F'05' :`
    typeset USER=`clsc -s uu:gu $F'03' :`
    typeset TIME=`clsc -s da $F'04' :`
    typeset STCK=`clsc -s su:sf $F'01' :`

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

# FIX: can't export from within function
function set_highlights {
  ZSH_HIGHLIGHT_STYLES[alias]="fg=07"
  ZSH_HIGHLIGHT_STYLES[assign]="fg=04"
  ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=07"
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=08"
  ZSH_HIGHLIGHT_STYLES[builtin]="fg=07"
  ZSH_HIGHLIGHT_STYLES[command]="fg=07"
  ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=07"
  ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=07"
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=02"
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=07"
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=02"
  ZSH_HIGHLIGHT_STYLES[function]="fg=07"
  ZSH_HIGHLIGHT_STYLES[globbing]="fg=05"
  ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=05"
  ZSH_HIGHLIGHT_STYLES[path]="fg=07"
  ZSH_HIGHLIGHT_STYLES[precommand]="fg=07"
  ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=07"
  ZSH_HIGHLIGHT_STYLES[redirection]="fg=05"
  ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=01"
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=07"
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=02"
  ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=01"
  ZSH_HIGHLIGHT_STYLES[default]="fg=07"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=08"
  ZSH_HIGHLIGHT_REGEXP+=('\$(\w+|\{.+?\})' "fg=05")
  ZSH_HIGHLIGHT_REGEXP+=('^\s*(doas|sudo)(\s|$)' "fg=05")
}
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main regexp)
set_highlights

# completion
zstyle ':completion:*' completer _expand _complete _ignored _match
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'l:|=*'
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' verbose false

autoload -Uz compinit
compinit -d "$XDG_CONFIG_HOME/zsh/zcomp"

# fetch
xset q &>/dev/null && [[ -f $HOME/.fetch ]] && printf '%s\n' "`< $HOME/.fetch`"
