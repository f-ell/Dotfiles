require('rules')
require('animations')
require('autostart')
require('binds')
require('env')

hl.monitor({
  output = 'DP-2',
  mode = '1920x1080@144',
  position = '0x0',
  bitdepth = 8,
})
hl.monitor({
  output = 'DP-1',
  mode = '1920x1080@144',
  position = '1920x-540',
  bitdepth = 8,
  transform = 3,

  -- FIX: this affects eww.
  -- reserved_area = { bottom = 336 },
})

---@type HL.WorkspaceRuleSpec[]
local ws_rules = {
  { workspace = '1', monitor = 'DP-2', default = true },
  { workspace = '2', monitor = 'DP-2' },
  { workspace = '3', monitor = 'DP-2' },
  { workspace = '4', monitor = 'DP-2' },
  { workspace = '5', monitor = 'DP-2' },
  { workspace = '6', monitor = 'DP-2' },
  { workspace = '7', monitor = 'DP-1', default = true },

  { workspace = 'special:file', on_created_empty = 'footclient yazi' },
  { workspace = 'special:audio', on_created_empty = 'easyeffects' },
  { workspace = 'special:mail', on_created_empty = 'evolution' },
}

for _, r in pairs(ws_rules) do
  if not string.find(r.workspace, '^special:') then
    r.persistent = true
  end
  hl.workspace_rule(r)
end

hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 16,
    extend_border_grab_area = 4,

    border_size = 2,
    col = {
      active_border = '#8da101',
      inactive_border = '#323d43',
    },

    resize_on_border = true,
    no_focus_fallback = true,

    layout = 'dwindle',
  },

  dwindle = {
    force_split = 2,
    preserve_split = true,
    smart_resizing = false,
  },

  input = {
    kb_layout = 'de',
    kb_options = 'caps:swapescape',
    repeat_delay = 220,
    repeat_rate = 75,

    force_no_accel = true,
    special_fallthrough = true,
  },

  cursor = {
    default_monitor = 'DP-2',
    inactive_timeout = 10,
    persistent_warps = true,
    zoom_disable_aa = true,
  },

  binds = { hide_special_on_workspace_change = true },

  decoration = {
    rounding = 2,
    rounding_power = 4.0,
    blur = { enabled = false },
  },

  misc = {
    font_family = 'Ellograph CF',
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    background_color = '#323d43',

    on_focus_under_fullscreen = 1,
    exit_window_retains_fullscreen = true,
  },

  render = { direct_scanout = 2 },
})
