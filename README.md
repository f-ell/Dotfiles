## About
This repository is a collection of my personal configuration files.  
Included with these configurations are:
* bspwm
  * 'smart' scratchpads script
    * re-launch scratchpad and reexecute application after accidentally closing
    * hide all visible scratchpads before showing another one -> no overlap
  * 'better' monocle mode script
    * hide all but the focused window (currently ignores floating windows) to
      remove annoying backdrop with transparency
* Neovim
  * _almost_ full Lua configuration (some `vim.cmd`s remain)
  * custom status- and tab-/bufferline written from scratch
  * custom highlight groups for status- and tab-/bufferline
  * toggleable terminal in separate split (somewhat similar to VSCode)
  * [LuaSnip](https://github.com/L3MON4D3/LuaSnip/) lua snippets for languages I
  use
* sxhkd
  * different bindings fitting my needs for desktop and laptop machines
    * the device type is read from `$HOME/Git/machine` (should contain either
    'DT' or 'LT') and exported as `$MACHINE`
    * e.g. `r-Alt + b` returns my
      * mouse's battery percentage on a desktop
      * laptop's battery percentage on a laptop
* Zsh
  * prompt
    * Git branch
    * last command exit status (`$?`)
    * prompt-character denoting viins and vicmd modes
  * colours
    * custom `ls` and [`exa`](https://the.exa.website/) colours
    * custom [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting/)
    colours

## Software
* WM:             [`bspwm`](https://www.github.com/baskerville/bspwm/)
* Keybindings:    [`sxhkd`](https://github.com/baskerville/sxhkd/)
* Terminal:       [`Alacritty`](https://alacritty.org/)
* Shell:          [`Zsh`](https://www.zsh.org/)
* Editor:         [`Neovim`](https://neovim.io/)
* Launcher:       [`Rofi`](https://github.com/davatorium/rofi/)
* File Manager:   [`ranger`](https://ranger.github.io/)
* Notifications:  [`dunst`](https://dunst-project.org/)
* Screenshots:    [`scrot`](https://github.com/resurrecting-open-source-projects/scrot/)

## Pictures
Showing off Zsh prompt whilst in a Git repository and last propram's exit code:  
![](Pictures/zsh.png)  

Showing off Neovim looks whilst editing a buffer:  
![](Pictures/nvim.png)

## Basic Keybindings
Keybindings needed to get up and running. Not exhaustive and subject to change.  
See [`sxhkd`](source/.config/sxhkd/) for general keybindings. WM-specific
keybindings can be found in `source/.config/<WM>/sxhkdrc.<WM>`.
```
  Super + Enter:      spawn terminal (Alacritty by default)
  Super + r:          spawn rofi with custom run script
  Super + Shift + r:  spawn rofi in window mode
  Super + o + x:      open application x

  Super + Shift + w:    close current window
  Super + Control + q:  kill window manager

  Super + [0-x]:                    go to workspace x
  Super + Shift + [0-x]:            move current window to workspace x
  Super + Control + [hjkl]:         grow window in direction [hjkl]
  Super + Control + Shift + [hjkl]: shrink window from direction [hjkl]

  Super + r-Alt + [hjkl]: preselect in direction [hjkl]
  Super + r-Alt + [0-9]:  change preselection ratio
  Super + r-Alt + Escape: cancel preselction

  Super + i + [ims]:  insert / move to / switch with receptacle

  Super + (Shift +) m: take (full desktop) screenshot

  r-Alt + x: send dunst notification x ('mode_switch' bindings)
```
