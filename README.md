## About
This repository is a collection of my personal configuration files.  
Some things worth highlighting:
* bspwm
  * 'smart' scratchpads script
    * re-launch scratchpad and reexecute application after accidentally closing
    * hide all visible scratchpads before showing another one -> no overlap
  * 'better' monocle mode script
    * hide all but the focused window (currently ignores floating windows) to
      remove annoying backdrop with transparency
* Neovim
  * _almost_ 100% Lua configuration (some `vim.cmd`s still remain)
  * custom status- and tab-/bufferline written from scratch
  * custom highlight groups for status- and tab-/bufferline
  * toggleable terminal in separate split (somewhat similar to VSCode)
  * [LuaSnip](https://github.com/L3MON4D3/LuaSnip/) lua snippets that can be
    used to build upon
* sxhkd
  * device-specific bindings that act differently depending on the machine
    that's used
    * device-specific files end in `.dt` and `.lt` respectively
    * the device type is read from `$HOME/Git/machine` (should contain either
    'DT' or 'LT') and exported as `$MACHINE` on login
    * e.g. `Alt + b` returns my
      * mouse's battery percentage on a desktop
      * laptop's battery percentage on a laptop
* Zsh
  * prompt shows
    * current Git branch
    * last command's exit code, when not zero
    * prompt-character denoting `viins` and `vicmd` modes
  * colours
    * custom `ls` and [`exa`](https://the.exa.website/) colours
      * note: colours require [`clsc`](https://gitlab.com/fell_/clsc)
    * custom [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting/)
    colours

## Software
* WM:             [`bspwm`](https://www.github.com/baskerville/bspwm/)
* Keybindings:    [`sxhkd`](https://github.com/baskerville/sxhkd/)
* Terminal:       [`kitty`](https://sw.kovidgoyal.net/kitty/)
* Shell:          [`Zsh`](https://www.zsh.org/)
* Editor:         [`Neovim`](https://neovim.io/)
* Launcher:       [`Rofi`](https://github.com/davatorium/rofi/)
* Notifications:  [`dunst`](https://dunst-project.org/)
* Screenshots:    [`scrot`](https://github.com/resurrecting-open-source-projects/scrot/)

## Pictures
Custom Zsh prompt:
![](Pictures/zsh.png)  

Neovim:  
![](Pictures/nvim.png)

## Basic Keybindings
Keybindings needed to get up and running. Not exhaustive and subject to change.  
See [`sxhkd/`](source/.config/sxhkd/) for general keybindings. WM-specific
keybindings can be found in `source/.config/<WM>/sxhkdrc.<WM>`.

```
  Super + Enter:          spawn terminal
  Super + r:              spawn Rofi with custom run script
  Super + Shift + r:      spawn Rofi in window | drun mode
  Super + o + b:          spawn browser

  Super + Shift + w:      close focused node
  Super + Control + r:    reload window manager
  Super + Control + q:    kill window manager

  Super + f:              toggle node floating / tiled
  Super + Tab:            toggle 'monocle' layout

  Super + [0-x]:                      go to workspace [0-x]
  Super + [hjkl]:                     focus node in direction [hjkl]
  Super + Shift + [0-x]:              move node to workspace [0-x]
  Super + Shift + [hjkl]:             move node in direction [hjkl]

  Super + Control + n:                equalize nodes
  Super + Control + [hjkl]:           grow node *in* direction [hjkl]
  Super + Control + Shift + [hjkl]:   shrink node *from* direction [hjkl]

  Super + r-Alt + [hjkl]:   preselect in direction [hjkl]
  Super + r-Alt + [0-9]:    change preselect ratio
  Super + r-Alt + Escape:   cancel preselect

  Super + i + [ims]:        insert / move to / switch with receptacle

  Super + (Shift +) m:      take (full desktop) screenshot

  Alt + [bcdtu]: dunst notifications for system information
```
