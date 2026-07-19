hl.env('XDG_CURRENT_DESKTOP', 'Hyprland')
hl.env('XDG_SESSION_TYPE', 'wayland')
hl.env('XDG_SESSION_DESKTOP', 'Hyprland')

hl.env('GDK_BACKEND', 'wayland,x11,*')
hl.env('QT_QPA_PLATFORM', 'wayland;xcb')

hl.env('LIBVA_DRIVER_NAME', 'nvidia')
hl.env('GBM_BACKEND', 'nvidia-drm')
hl.env('__GLX_VENDOR_LIBRARY_NAME', 'nvidia')
hl.env('NVD_BACKEND', 'direct')

hl.env('GDK_SCALE', '1')
hl.env('XCURSOR_THEME', 'Quintom_Snow')
hl.env('XCURSOR_SIZE', '30')
hl.env('HYPRCURSOR_THEME', 'Quintom_Snow')
hl.env('HYPRCURSOR_SIZE', '30')

hl.env('ELECTRON_OZONE_PLATFORM_HINT', 'auto')
