---@type HL.WindowRuleSpec[]
local win_rules = {
  { match = { class = '.*' }, float = true, persistent_size = true },
  { match = { class = '^(foot|footclient)$' }, float = false },
  { match = { initial_title = '^(Steam|Zen Browser)$' }, float = false },
  {
    match = { workspace = 's[true]' },
    float = true,
    center = true,
    size = { 1200, 800 },
  },

  { match = { float = true }, min_size = { 64, 64 } },

  { match = { class = '^steam$' }, workspace = '6', no_initial_focus = true },
  {
    match = { class = '^steam_app_\\d+$' },
    workspace = '6',
    no_initial_focus = true,
  },
  {
    match = { class = '^(discord|vesktop|spotify)$' },
    workspace = '7',
    no_initial_focus = true,
  },

  -- TODO: fade to next window instead.
  { match = { fullscreen = true }, no_anim = true },
}

for _, r in pairs(win_rules) do
  hl.window_rule(r)
end
