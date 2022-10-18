# ____   ____
# |   \  |  |______
# |    \ |  | ___  \
# |     \|  | |  \  |
# |  \   \  | |__/  |
# |  |\     | _____/
# |__| \____| | Author: Nico Pareigis
#          |__| Zsh

[[ -t 0 && $- = *i* ]] && stty -ixon # alt: stty stop ''

set -o autocd -o extendedglob -o histexpiredupsfirst -o histignoredups\
  -o histignorespace -o incappendhistory -o kshglob -o pipefail -o promptsubst\
  -o rematchpcre\
  +o automenu +o autoremoveslash

. $HOME'/.env_setup'

SAVEHIST=5000; HISTSIZE=$(($SAVEHIST + 100)); HISTFILE=$HOME'/.zsh_history'

export MACHINE=`< $HOME/Git/machine`

export VISUAL='nvim'
export EDITOR=$VISUAL

. $HOME'/.aliases'
. $XDG_CONFIG_HOME'/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_MANUAL_REBIND=True
. $XDG_CONFIG_HOME'/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

Bin='/usr/bin:/usr/local/bin:/usr/local/sbin:'$HOME'/.local/bin'
Perl='/usr/bin/core_perl:/usr/bin/site_perl:/usr/bin/vendor_perl'
Other='/opt:'$CARGO_HOME'/bin:'$HOME'/Scripts'
export PATH=$Bin':'$Perl':'$Other
unset Bin Perl Other
export FZF_DEFAULT_COMMAND='fd -E .cache -tf -H -d10 .'
export FZF_DEFAULT_OPTS='-i --tiebreak=begin,length --scroll-off=1 --reverse --prompt="$ " --height=25% --color=bw'

# needed because Firefox acts up when being killed by bspwm :)
export MOZ_CRASHREPORTER_DISABLE=1


# Binds
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


# Prompt
CE='#e67e80'; CF='#d3c6aa'; CG='#fca326'; CC='#a0a0a0'
Prompt() {
  unset {,R}PS1
  # M -> 'mode' - 0 for single-line, anything else for multi-line
  M=$1; X=$2; C=$3

  # Exit code
  (( $X == 0 )) && unset X
  [[ -n "$X" ]] && (( $X == 130 )) && X='INT'
  # Git branch
  B=`git rev-parse --is-inside-work-tree 2>/dev/null`
  if [[ $? -eq 0 && $B == 'true' ]]; then
    B=`git branch --show-current`
    [[ -n "$B" ]] || { B=`git rev-parse @`; B=${B:0:7}; }
  else
    unset B
  fi

  if [[ $M -eq 0 ]]; then
    [[ -n "$X" ]] && PS1=$'%F{$CE}%S%B$X%b%s%f '      # exit code
    PS1=$PS1$'%F{$CF} %B%S%1~%s%b '                  # working dir
    [[ -n "$B" ]] && PS1=$PS1$'on %F{$CG}%S $B%s%f ' # git branch
    PS1=$PS1$'%F{$CC}$C%f '                             # prompt char

    # RPS1
    #   1. replace $HOME in $OLDPWD
    #   2. split to array       - (s)
    #   3. strip leading '.'    - (#)
    #   4. truncate to length 1 - (r)
    #   5. join to string       - (j)
    # |5.     |4.     |3|4.     |1.
    R=${(j:/:)${(r:1:)${${(s:/:)${PWD/$HOME/\~}}[@]##.}}}
    # Adding leading slash and ellipsize
    local Len; [[ ${R:0:1} == '~' ]] && Len=8 || { R='/'$R; Len=9; }
    (( $#R > $Len )) && R=${R:0:$Len}'..'
    [[ $R != '~' ]] && RPS1=$'%F{$CF}%B%S$R%s%b%f'
  else
    PS1=$'%F{$CF}%B%S%~%s%b%f\n'
    [[ -n "$X" ]] && PS1=$PS1$'%F{$CE}%B$X%b%f '
    [[ -n "$B" ]] && PS1=$PS1$'%F{$CG}%B $B%b%f '
    PS1=$PS1$'%F{$CC}$C%f '
  fi
}
precmd() {
  LAST_EXIT=$?; Prompt 0 $LAST_EXIT '' 
}

zle-keymap-select() {
  [[ $KEYMAP == 'main' ]]   && Prompt 0 $LAST_EXIT '' 
  [[ $KEYMAP == 'vicmd' ]]  && Prompt 0 $LAST_EXIT '' 
  zle reset-prompt
}; zle -N zle-keymap-select


# Colours
set_colours(){
  local F C GEN AUD PIC VID FILE CODE ARCH R W X FS UG TS
  F="38;5;"
  GEN="di=${F}228;01:ln=${F}122;01:or=${F}234;01:ex=${F}197;04:*.bak=${F}200;04:*.iso=${F}158;04:*.otf=${F}200:*.ttf=${F}200"
  C="${F}165"     AUD="*.mp3=${C}:*.wav=${C}"
  C="${F}42"      PIC="*.gif=${C}:*.jpg=${C}:*.png=${C}:*.svg=${C}:*.webp=${C}"
  C="${F}63"      VID="*.mov=${C}:*.mp4=${C}"
  C="${F}182"     FILE="*.css=${C}:*.docx=${C}:*.html=${C}:*.md=${C}:*.odf=${C}:*.odt=${C}:*.pdf=${C}:*.sty=${C}:*.tex=${C}:*.txt=${C}:*.yml=${C}"
  C="${F}204"     CODE="*.class=${C}:*.java=${C}:*.js=${C}:*.json=${C}:*.lua=${C}:*.pl=${C}:*.py=${C}:*.sh=${C}:*.ts=${C}"
  C="${F}225;01"  ARCH="*.7z=${C}:*.bz2=${C}:*.gz=${C}:*.jar=${C}:*.rar=${C}:*.tar=${C}:*.xz=${C}:*.zip=${C}"
  C="${F}42"      R="ur=${C}:ue=${C}:gr=${C}:tr=${C}"
                  W="uw=${C}:gw=${C}:tw=${C}"
                  X="ux=${C}:gx=${C}:tx=${C}"
  C="${F}205"     FS="sn=${C}:sb=${C}:df=${C}:ds=${C}"
  C="${F}230"     UG="uu=${C}:gu=${C}"
  C="${F}012"     TS="da=${C}"

  LS_COLORS="${GEN}:${AUD}:${PIC}:${VID}:${FILE}:${CODE}:${ARCH}"
  EXA_COLORS="${R}:${W}:${X}:${FS}:${UG}:${TS}"

  local _1=254 _2=035 _3=072
  ZSH_HIGHLIGHT_STYLES[alias]="fg=$_2,bold"
  ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$_3,underline"
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$_1"
  ZSH_HIGHLIGHT_STYLES[builtin]="fg=$_1,bold"
  ZSH_HIGHLIGHT_STYLES[command]="fg=$_2,bold"
  ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$_2"
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$_2"
  ZSH_HIGHLIGHT_STYLES[function]="fg=$_2,bold"
  ZSH_HIGHLIGHT_STYLES[path]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[precommand]="fg=$_1,underline"
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=228'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$_3"
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$_2"
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=196,bold'
}
set_colours
export LS_COLORS EXA_COLORS

export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;35m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;32m'
export LESSHISTFILE=-


# Completion
zstyle ':completion:*' completer _complete _expand _ignored _match
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} r:|[._-/]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' verbose false

autoload -Uz compinit
compinit -d $XDG_CONFIG_HOME'/zsh/zcomp'


# Run fetch ONLY when X-Server is running, not on TTY
# [[ `xset q 2>/dev/null` ]] \
  # && printf "'Whose is the dying flame?' asked the Witcher.\n    'Yours,' Death replied.\n"
  # && printf "In his strong hand the man held a Rose.\n      And his aura burned bright.\n"
