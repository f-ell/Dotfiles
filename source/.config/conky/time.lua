-- https://github.com/brndnmtthws/conky
---@diagnostic disable: undefined-global

conky.config = {
    alignment     = 'bl',
    background    = false,
    default_color = 'a7c080',
    double_buffer = true,
    draw_shades   = false,
    font          = 'Ellograph CF Heavy:size=90',
    gap_x         = 120,
    gap_y         = 100,
    out_to_x      = true,
    own_window    = true,
    own_window_class        = 'conky_time',
    own_window_title        = 'conky_time',
    own_window_transparent  = true,
    own_window_type         = 'override',
    update_interval         = 1.0,
    use_xft                 = true,
    xinerama_head           = 1,
}

conky.text = [[
${time %I:%M}${font Ellograph CF Heavy:size=24}${time %p}
${offset 8}${font Ellograph CF Heavy:size=22}${time %a. %d %B %Y}
]]
