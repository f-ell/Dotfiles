# ____   ____
# |   \  |  |______
# |    \ |  | ___  \
# |     \|  | |  \  |
# |  \   \  | |__/  |
# |  |\     | _____/
# |__| \____| | Author: Nico Pareigis
#          |__| Zsh

[[ -t 0 && $- == *i* ]] && stty -ixon # alt: stty stop ''

set -o autocd -o extendedglob -o histexpiredupsfirst -o histignoredups\
  -o histignorespace -o incappendhistory -o kshglob -o pipefail -o promptsubst\
  -o rematchpcre\
  +o automenu +o autoremoveslash

SAVEHIST=5000; HISTSIZE=$(($SAVEHIST + 100)); HISTFILE="$HOME/.zsh_history"

[[ -f $HOME/.prompt ]] && PSM=`< $HOME/.prompt`
export PSM=${PSM:-0}
### LOGIN ONLY ###
if [[ -o login ]]; then
  [[ -f $HOME/.machine ]] && MACHINE=`< $HOME/.machine`
  export MACHINE=${MACHINE:-DT}
  export VISUAL=nvim
  export EDITOR=$VISUAL

  [[ -f $HOME/.env_setup ]] && . "$HOME/.env_setup"

  Bin="/usr/bin:/usr/local/bin:$HOME/.local/bin"
  Perl='/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl'
  Misc="$CARGO_HOME/bin"
  export PATH="$Bin:$Perl:$Misc"
  unset Bin Perl Misc
fi
### END LOGIN ONLY ###

. "$HOME/.aliases"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_MANUAL_REBIND=True
. "$XDG_CONFIG_HOME/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
. "$XDG_CONFIG_HOME/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


# KEYBINDS
autoload edit-command-line; zle -N edit-command-line
bindkey '^Xe' edit-command-line

bindkey '^R' vi-history-search-backward

bindkey -v '^K' kill-line
bindkey -v '^U' backward-kill-line
bindkey -v '^Y' yank
# Delete without overwriting 'yank'-buffer
bindkey -v '^?' backward-delete-char

# ^Left | ^Right movement
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

bindkey '^ ' autosuggest-accept


# PROMPT
if [[ `xset q 2>/dev/null` ]]; then
  CE=#e67e80; CF=#d3c6aa; CG=#fca326; CC=#a0a0a0
  Prompt() {
    unset {,R}PS1
    # prompt modes:
    #   * 0: compact single-line, plain
    #   * 1: compact single-line, decorated
    #   * 2: verbose single-line, decorated
    #   * *: multi-line (outdated)
    # $2 -> exit status
    # $3 -> viins prompt char
    X=$1; C=$2

    # Exit code
    (( $X == 0 )) && unset X

    # Git HEAD
    B=`git rev-parse --is-inside-work-tree 2>/dev/null`
    if (( $? == 0 )) && [[ $B == true ]]; then
      declare -i m b
      declare -A Refs
      git -C . show-ref --head --heads --tags --abbrev -d | while read; do
        Refs+=(${${REPLY#* }%\^\{\}} ${REPLY% *})
      done

      local HeadRef=HEAD
      local HeadId=${Refs[HEAD]}

      local Ref Id
      for Ref Id in ${(@kv)Refs}; do
        [[ $Ref == HEAD ]] && continue

        if [[ $HeadId == $Id ]]; then
          let m++
          [[ $Ref =~ refs/heads/ ]] && let b++
          HeadRef=${Ref#refs/*/}
          HeadId=$Id
        fi
      done

      if (( m == 0 )); then
        HeadRef=$HeadId
      elif (( b > 1 )) || (( m > b && b > 0 )); then
        # NOTE: detached head at branch head prefers tag-name over commit
        local branch=`git -C . branch --show-current`
        [[ -n $branch ]] && HeadRef=$branch
      fi

      B=$HeadRef
    else
      unset B
    fi

    # Git stash
    if [[ -n $B ]]; then
      local TL=`git rev-parse --show-toplevel`
      [[ -f $TL/.git ]] && {
        TL=`< $TL/.git`
        TL=${TL#gitdir: }
        [[ -f $TL/commondir ]] && TL+=/`< $TL/commondir`
      }
      [[ -f $TL/refs/stash || -f $TL/.git/refs/stash ]] && B+=\~
    fi

    if (( $PSM == 0 )); then
      [[ $PWD == / ]] && P=/ || P=${PWD##*/}
      PS1=$'%F{$CF}%B';
      # cwd
      [[ $PWD != $HOME ]] && PS1+=\ $P; PS1+=$'%b'
      # git
      [[ -n $B ]] \
        && PS1+=$' %F{$CG} $B%f' \
      # exit status
      [[ -n $X ]] && PS1+=$' %F{$CE}%B%{\e[3m%}$X%{\e[0m%}%b%f'
      # prompt char
      PS1+=$' %F{$CC}$C%f '

    elif (( $PSM == 1 )); then
      [[ $PWD == / ]] && P=/ || P=${PWD##*/}
      PS1=$'%F{$CF}• %B%S';
      # cwd
      [[ $PWD != $HOME ]] && PS1+=\ $P; PS1+=$'%s%b'
      # git
      [[ -n $B ]] \
        && PS1+=$'%K{$CG} %k%F{$CG}%S $B%s%f' \
        || PS1+=$''
      # exit status
      [[ -n $X ]] && PS1+=$' %F{$CE}%B%{\e[3m%}$X%{\e[0m%}%b%f'
      # prompt char
      PS1+=$' %F{$CC}$C%f '

    elif (( $PSM == 2 )); then
      # exit status
      [[ -n $X ]] && PS1=$'%F{$CE}%B%S$X%s%b%f '
      # cwd
      PS1+=$'%F{$CF}• %B%S %1~%s%b '
      # git
      [[ -n $B ]] && PS1+=$'on %F{$CG}%S $B%s%f '
      # prompt char
      PS1+=$'%F{$CC}$C%f '

    else
      PS1=$'%F{$CF}%B%S%~%s%b%f\n'
      [[ -n $X ]] && PS1+=$'%F{$CE}%B$X%b%f '
      [[ -n $B ]] && PS1+=$'%F{$CG}%B $B%b%f '
      PS1+=$'%F{$CC}$C%f '
    fi


    # RPS1
    if (( $PSM == 2 )); then
      #   1. replace $HOME in $OLDPWD
      #   2. split to array       - (s)
      #   3. strip leading '.'    - (#)
      #   4. truncate to length 1 - (r)
      #   5. join to string       - (j)
      # |5.     |4.     |3|2.     |1.
      R=${(j:/:)${(r:1:)${${(s:/:)${PWD/$HOME/\~}}[@]##.}}}
      # Add leading slash and ellipsize
      local Len; [[ ${R:0:1} == '~' ]] && Len=8 || { R=/$R; Len=9; }
      (( $#R > $Len )) && R=${R:0:$Len}'..'
      [[ $R != '~' ]] && RPS1=$'  %F{$CF}%B%S$R%s%b%f'
      RPS1+=$' •'
    fi
  }
  precmd() {
    LAST_EXIT=$?; Prompt $LAST_EXIT  # ›
  }

  zle-keymap-select() {
    [[ $KEYMAP == main ]]   && Prompt $LAST_EXIT 
    [[ $KEYMAP == vicmd ]]  && Prompt $LAST_EXIT :
    zle reset-prompt
  }; zle -N zle-keymap-select
else
  PS1=$'%1~ $ '
fi


# COLOURS AND HIGHLIGHTS
### LOGIN ONLY ###
if [[ -o login ]]; then
  set_colours(){
    local F GEN AUD PIC VID ARCH CODE CONF FILE FONT SPEC PERM SIZE USER TIME STCK FTXB
    F='38;5;'

    GEN="bd=${F}03:cd=${F}11:di=${F}03;1:ex=${F}01;4:fi=${F}07;3:ln=${F}04;4:or=${F}08;1:*.bak=${F}03;4:*.iso=${F}03;4:?akefile=${F}05;3;4"
    AUD=`clsc mp3:wav $F'05' :`
    PIC=`clsc gif:jpg:png:svg:webp $F'04' :`
    VID=`clsc mov:mp4 $F'03' :`
    ARCH=`clsc bz2:gz:jar:rar:tar:xz:zip $F'11;1' :`
    CODE=`clsc c:java:js:lua:pl:py:rs:sh:ts $F'01;3' :`
    CONF=`clsc conf:ini:rasi:toml:yml $F'04;3' :`
    FILE=`clsc a:css:h:html:json:md:o:pdf:sty:tex:xml $F'02' :`
    FONT=`clsc otf:ttf $F'02;3' :`
    SPEC=`clsc lt:dt $F'10' :`
    PERM=`clsc -s ur:gr:tr:uw:gw:tw:ux:gx:tx $F'02' :`
    SIZE=`clsc -s sn:sb:df:ds $F'05' :`
    USER=`clsc -s uu:gu $F'03' :`
    TIME=`clsc -s da $F'04' :`
    STCK=`clsc -s su:sf $F'01' :`
    FTXB=`clsc -s ue $F'06;1' :`

    LS_COLORS="${GEN}:${AUD}:${PIC}:${VID}:${ARCH}:${CODE}:${CONF}:${FILE}:${FONT}:${SPEC}"
    EXA_COLORS="${PERM}:${SIZE}:${USER}:${TIME}:${STCK}:${FTXB}"
    export LS_COLORS EXA_COLORS
  }
  set_colours

  export LESS_TERMCAP_mb=$'\e[1;38;5;2m'
  export LESS_TERMCAP_md=$'\e[1;38;5;1m'
  export LESS_TERMCAP_me=$'\e[0m'
  export LESS_TERMCAP_se=$'\e[0m'
  export LESS_TERMCAP_so=$'\e[3;38;5;3m'
  export LESS_TERMCAP_ue=$'\e[0m'
  export LESS_TERMCAP_us=$'\e[0;38;5;2m'
  export LESSHISTFILE=-
fi
### END LOGIN ONLY ###

typeset -a ZSH_HIGHLIGHT_HIGHLIGHTERS=(main regexp)
typeset -A ZSH_HIGHLIGHT_STYLES ZSH_HIGHLIGHT_REGEXP
set_highlights() {
  local _1=01 _2=02 _3=03 _4=04 _5=05 _6=06 _7=07 _8=08 _9=09
  local _10=10 _11=11 _12=12 _13=13 _14=14 _15=15 _16=16
  ZSH_HIGHLIGHT_STYLES[alias]="fg=$_6"
  ZSH_HIGHLIGHT_STYLES[assign]="fg=$_4"
  ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$_8"
  ZSH_HIGHLIGHT_STYLES[builtin]="fg=$_4"
  ZSH_HIGHLIGHT_STYLES[command]="fg=$_6,bold"
  ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$_7"
  ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=$_7"
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$_2"
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$_7"
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$_10"
  ZSH_HIGHLIGHT_STYLES[function]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[globbing]="fg=$_5"
  ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=$_5"
  ZSH_HIGHLIGHT_STYLES[path]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[precommand]="fg=$_7"
  ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=$_7"
  ZSH_HIGHLIGHT_STYLES[redirection]="fg=$_5"
  ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$_7"
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$_2"
  ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[default]="fg=$_7"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$_8"

  ZSH_HIGHLIGHT_REGEXP+=('\$(\w+|\{.+?\})' "fg=$_5")
  ZSH_HIGHLIGHT_REGEXP+=('^\s*(doas|sudo)(\s|$)' "fg=$_5")
}
set_highlights


# COMPLETION
zstyle ':completion:*' completer _expand _complete _ignored _match
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'l:|=*'
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' verbose false

autoload -Uz compinit
compinit -d "$XDG_CONFIG_HOME/zsh/zcomp"


# FETCH
# [[ `xset q 2>/dev/null` ]] \
  # && printf "'Whose is the dying flame?' asked the Witcher.\n    'Yours,' Death replied.\n"
  # && printf "In his strong hand the man held a Rose.\n      And his aura burned bright.\n"
