-- https://github.com/brndnmtthws/conky
---@diagnostic disable: undefined-global

conky.config = {
	alignment = "br",
	background = false,
	default_color = "#a7c080",
	double_buffer = true,
	draw_shades = false,
	font = "Ellograph CF Heavy:size=14",
	gap_x = 120,
	gap_y = 100,
	out_to_x = true,
	own_window = true,
	own_window_class = "conky_system",
	own_window_title = "conky_system",
	own_window_transparent = false,
	own_window_colour = "#323c41",
	own_window_type = "desktop",
	update_interval = 4.0,
	use_xft = true,
	xinerama_head = 1,
}

conky.text = "${exec /home/nico/.config/conky/sys.pl}"
