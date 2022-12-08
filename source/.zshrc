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

SAVEHIST=5000; HISTSIZE=$(($SAVEHIST + 100)); HISTFILE=$HOME'/.zsh_history'

### LOGIN ONLY ###
if [[ -o login ]]; then
  export MACHINE=`< $HOME/Git/machine`
  export VISUAL='nvim'
  export EDITOR=$VISUAL

  Bin='/usr/bin:/usr/local/bin:/usr/local/sbin:'$HOME'/.local/bin'
  Perl='/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl'
  Misc='/opt:'$CARGO_HOME'/bin:'$HOME'/Scripts'
  export PATH=$Bin':'$Perl':'$Misc
  unset Bin Perl Misc

  [[ -f $HOME'/.env_setup' ]] && . $HOME'/.env_setup'

  export FZF_DEFAULT_COMMAND='fd -E .cache -tf -H -d10 .'
  export FZF_DEFAULT_OPTS='-i --tiebreak=begin,length --scroll-off=1 --reverse --prompt="$ " --height=25% --color=bw'
  # Firefox acts up when killed by bspwm :))
  export MOZ_CRASHREPORTER_DISABLE=1
fi
### END LOGIN ONLY ###

. $HOME'/.aliases'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_MANUAL_REBIND=True
. $XDG_CONFIG_HOME'/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh'
. $XDG_CONFIG_HOME'/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'


# Keybinds
### WIP ###
# Switch Caps and Escape:
# xmodmap -e 'remove Lock = Caps_Lock'
# xmodmap -e 'keycode 66  = Escape'
# xmodmap -e 'keycode 9   = Caps_Lock'
# Switch R_Shift and BackSpace:
# xmodmap -e 'keycode 62  = BackSpace'
# xmodmap -e 'remove Shift = BackSpace'
# xset r 62
# xmodmap -e 'keycode 22  = Shift_R'

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


# Set fancy prompt in X, simple prompt on tty
if [[ `xset q 2>/dev/null` ]]; then
  # Prompt
  CE='#e67e80'; CF='#d3c6aa'; CG='#fca326'; CC='#a0a0a0'
  Prompt() {
    unset {,R}PS1
    # M -> 'mode' - 0 for compact single-line, 1 for long single-line,
    # anything else for multi-line
    M=$1; X=$2; C=$3

    # Exit code
    (( $X == 0 )) && unset X

    # Git branch
    B=`git rev-parse --is-inside-work-tree 2>/dev/null`
    if (( $? == 0 )) && [[ $B == 'true' ]]; then
      B=`git branch --show-current`
      [[ -z $B ]] && B=`git describe --tags @ 2>/dev/null`
      [[ -z $B ]] && { B=`git rev-parse @`; B=${B:0:7}; }
    else
      unset B
    fi

    if (( $M == 0 )); then
      [[ $PWD == / ]] && P=/ || P=${PWD##*/}
      PS1=$'%F{$CF}• %B%S';
      [[ $PWD != $HOME ]] && PS1=$PS1\ $P; PS1=$PS1$'%s%b'          # working dir
      [[ -n $B ]] \
        && PS1=$PS1$'%K{$CG} %k%F{$CG}%S $B%s%f' \
        || PS1=$PS1$''                                             # git branch
      [[ -n $X ]] && PS1=$PS1$' %F{$CE}%B%{\e[3m%}$X%{\e[0m%}%b%f'  # exit code
      PS1=$PS1$' %F{$CC}$C%f '                                      # prompt char

    elif (( $M == 1 )); then
      [[ -n $X ]] && PS1=$'%F{$CE}%B%S$X%s%b%f '      # exit code
      PS1=$PS1$'%F{$CF}• %B%S %1~%s%b '              # working dir
      [[ -n $B ]] && PS1=$PS1$'on %F{$CG}%S $B%s%f ' # git branch
      PS1=$PS1$'%F{$CC}$C%f '                           # prompt char

    else
      PS1=$'%F{$CF}%B%S%~%s%b%f\n'
      [[ -n $X ]] && PS1=$PS1$'%F{$CE}%B$X%b%f '
      [[ -n $B ]] && PS1=$PS1$'%F{$CG}%B $B%b%f '
      PS1=$PS1$'%F{$CC}$C%f '
    fi


    # RPS1
    if (( $M == 1 )); then
      #   1. replace $HOME in $OLDPWD
      #   2. split to array       - (s)
      #   3. strip leading '.'    - (#)
      #   4. truncate to length 1 - (r)
      #   5. join to string       - (j)
      # |5.     |4.     |3|2.     |1.
      R=${(j:/:)${(r:1:)${${(s:/:)${PWD/$HOME/\~}}[@]##.}}}
      # Add leading slash and ellipsize
      local Len; [[ ${R:0:1} == '~' ]] && Len=8 || { R='/'$R; Len=9; }
      (( $#R > $Len )) && R=${R:0:$Len}'..'
      [[ $R != '~' ]] && RPS1=$'  %F{$CF}%B%S$R%s%b%f'
      RPS1=$RPS1$' •'
    fi
  }
  precmd() {
    LAST_EXIT=$?; Prompt 0 $LAST_EXIT ''
  }

  zle-keymap-select() {
    [[ $KEYMAP == 'main' ]]   && Prompt 0 $LAST_EXIT ''
    [[ $KEYMAP == 'vicmd' ]]  && Prompt 0 $LAST_EXIT ''
    zle reset-prompt
  }; zle -N zle-keymap-select
else
  PS1=$'%1~ $ '
fi


# Colours and highlights
### LOGIN ONLY ###
if [[ -o login ]]; then
  set_colours(){
    local F GEN AUD PIC VID ARCH CODE CONF FILE FONT SPEC PERM SIZE USER TIME STCK
    F='38;5;'

    GEN="bd=${F}15:cd=${F}16:di=${F}15;1:ex=${F}13;4:fi=${F}01;3:ln=${F}07;4:or=${F}02;1:*.bak=${F}15;4:*.iso=${F}15;4:?akefile=${F}11;3;4"
    AUD=`clsc mp3:wav $F'11' :`
    PIC=`clsc gif:jpg:png:svg:webp $F'07' :`
    VID=`clsc mov:mp4 $F'15' :`
    ARCH=`clsc bz2:gz:jar:rar:tar:xz:zip $F'16;1' :`
    CODE=`clsc c:java:js:lua:pl:py:rs:sh:ts $F'13;3' :`
    CONF=`clsc conf:ini:rasi:toml:yml $F'07;3' :`
    FILE=`clsc a:css:h:html:json:md:o:pdf:sty:tex:xml $F'09' :`
    FONT=`clsc otf:ttf $F'09;3' :`
    SPEC=`clsc lt:dt $F'10' :`
    PERM=`clsc -s ur:gr:tr:uw:gw:tw:ux:gx:tx $F'05' :`
    SIZE=`clsc -s sn:sb:df:ds $F'11' :`
    USER=`clsc -s uu:gu $F'15' :`
    TIME=`clsc -s da $F'09' :`
    STCK=`clsc -s su:sf $F'13' :`

    LS_COLORS="${GEN}:${AUD}:${PIC}:${VID}:${ARCH}:${CODE}:${CONF}:${FILE}:${FONT}:${SPEC}"
    EXA_COLORS="${PERM}:${SIZE}:${USER}:${TIME}:${STCK}"
    export LS_COLORS EXA_COLORS
  }
  set_colours

  export LESS_TERMCAP_mb=$'\e[1;38;5;9m'
  export LESS_TERMCAP_md=$'\e[1;38;5;13m'
  export LESS_TERMCAP_me=$'\e[0m'
  export LESS_TERMCAP_se=$'\e[0m'
  export LESS_TERMCAP_so=$'\e[3;38;5;15m'
  export LESS_TERMCAP_ue=$'\e[0m'
  export LESS_TERMCAP_us=$'\e[0;38;5;9m'
  export LESSHISTFILE=-
fi
### END LOGIN ONLY ###

set_highlights() {
  local _1=01 _2=02 _3=03 _4=04 _5=05 _6=06 _7=07 _8=08 _9=09
  local _10=10 _11=11 _12=12 _13=13 _14=14 _15=15 _16=16
  ZSH_HIGHLIGHT_STYLES[alias]="fg=$_5,bold"
  ZSH_HIGHLIGHT_STYLES[assign]="fg=$_7,bold"
  ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$_15,bold"
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$_2"
  ZSH_HIGHLIGHT_STYLES[builtin]="fg=$_6,bold"
  ZSH_HIGHLIGHT_STYLES[command]="fg=$_5,bold"
  ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$_9"
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$_10"
  ZSH_HIGHLIGHT_STYLES[function]="fg=$_5,bold"
  ZSH_HIGHLIGHT_STYLES[globbing]="fg=$_11,bold"
  ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=$_11,bold"
  ZSH_HIGHLIGHT_STYLES[path]="fg=$_1,italic"
  ZSH_HIGHLIGHT_STYLES[precommand]="fg=$_6"
  ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[redirection]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$_13"
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$_9"
  ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$_13,bold"
  ZSH_HIGHLIGHT_STYLES[default]="fg=$_1"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$_2,bold"
}
set_highlights


# Completion
zstyle ':completion:*' completer _expand _complete _ignored _match
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} r:|[._-/]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' verbose false

autoload -Uz compinit
compinit -d $XDG_CONFIG_HOME'/zsh/zcomp'


# Run fetch ONLY when X-Server is running, not on TTY
# [[ `xset q 2>/dev/null` ]] \
  # && printf "'Whose is the dying flame?' asked the Witcher.\n    'Yours,' Death replied.\n"
  # && printf "In his strong hand the man held a Rose.\n      And his aura burned bright.\n"
