## About
Collection of personal configuration files.

## Core Software
```
WM:            bspwm  (https://www.github.com/baskerville/bspwm/)
Keybindings:   sxhkd  (https://github.com/baskerville/sxhkd/)
Terminal:      kitty  (https://sw.kovidgoyal.net/kitty/)
Shell:         Zsh    (https://www.zsh.org/)
Editor:        Neovim (https://neovim.io/)
Launcher:      Rofi   (https://github.com/davatorium/rofi/)
```

## Notes
* bspwm
    * 'smart' scratchpads
        * re-launch when killed
        * prevent overlapping scratchpads
* Neovim configuration at
  [https://gitlab.com/fell_/nvim](https://gitlab.com/fell_/nvim)
* Zsh
    * custom prompt with
        * current git-head as branch / tag / commit
        * last return code
        * prompt-character for `viins` and `vicmd` modes
    * custom `ls` and [`eza`](https://github.com/eza-community/) colours
      (requires [`clsc`](https://gitlab.com/fell_/clsc/))

## Keybindings
List of core keybinds - not exhaustive and subject to change. See
[`sxhkd/`](source/.config/sxhkd/) for general keybindings. WM-specific
keybindings are stored in the WM's configuration folder.

```
  Super + Enter:            terminal
  Super + r:                rofi
  Alt + [1-x]:              scratchpad [1-x]

  Super + Shift   + w:      kill node
  Super + Control + r:      reload window manager
  Super + Control + q:      kill window manager

  Super + f:                toggle node floating / tiled
  Super + Tab:              toggle monocle layout

  Super + [0-x]:            go to workspace [0-x]
  Super + [hjkl]:           focus node in direction [hjkl]
  Super + Shift + [0-x]:    move node to workspace [0-x]
  Super + Shift + [hjkl]:   move node in direction [hjkl]

  Super + Control + [hjkl]:         grow node *in* direction [hjkl]
  Super + Control + Shift + [hjkl]: shrink node *from* direction [hjkl]
```
