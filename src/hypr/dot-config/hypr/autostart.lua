local function pcli(args)
  return string.format('polychromatic-cli -d mouse %s', args)
end

local startup = {
  'systemctl --user start hyprland-session',
  'systemctl --user start hyprpolkitagent',
  'systemctl --user start hypridle',
  'systemctl --user start hyprpaper',

  'wl-paste --type text --watch cliphist store',
  'foot --server',
  'eww-wayland open-many bar-hypr time sysinfo',

  'easyeffects --gapplication-service',
  'dunst',

  'openrgb -p off',
  pcli('--dpi 800'),
  pcli('-z main -o poll_rate -p 1000'),
  pcli('-z logo -o none'),
}

local shutdown = {
  'systemctl --user stop hyprland-session && sleep 0.1',
}

hl.on('hyprland.start', function()
  for _, cmd in pairs(startup) do
    hl.exec_cmd(cmd)
  end
end)

hl.on('hyprland.shutdown', function()
  for _, cmd in pairs(shutdown) do
    hl.exec_cmd(cmd)
  end
end)
