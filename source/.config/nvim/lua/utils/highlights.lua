local set_hl_groups = function()
  local none = ''

  local fg_1 = '#ffffff'
  local fg_2 = '#b0b0b0'

  local plum_1 = '#302090'
  local plum_2 = '#6050f0'

  local readonly  = '#f02030'
  local git       = '#fca326'

  local hls = {
    -- {0, 'name', {fg = '', bg = ''}},

    -- custom groups
    {0, 'fg_dark',  {fg = fg_2, bg = none}},

    {0, 'Default',  {fg = fg_1, bg = none}},
    {0, 'Ro',       {fg = fg_1, bg = readonly}},
    {0, 'Git',      {fg = git,  bg = none, italic = true}},

    -- vim builtin groups
    {0, 'Search',     {fg = plum_1, bg = fg_1}},
    {0, 'IncSearch',  {fg = plum_1, bg = fg_1}},
    {0, 'CurSearch',  {fg = fg_1,   bg = plum_1}},
    {0, 'Substitute', {fg = fg_1,   bg = plum_1}},

    {0, 'Visual', {fg = fg_1, bg = '#3030a0'}},

    {0, 'TabLine',      {fg = fg_2, bg = plum_1, italic = true}},
    {0, 'TabLineSel',   {fg = fg_1, bg = plum_2, italic = true, underline = true}},
    {0, 'TabLineFill',  {fg = fg_1, bg = none}},

    {0, 'modeN',  {fg = fg_1, bg = '#6050f0'}},
    {0, 'modeC',  {fg = fg_1, bg = '#30a080'}},
    {0, 'modeV',  {fg = fg_1, bg = '#3030a0'}},
    {0, 'modeR',  {fg = fg_1, bg = '#d0d050'}},
    {0, 'modeT',  {fg = fg_1, bg = '#3d3d3d'}},
    {0, 'modeI',  {fg = fg_1, bg = '#b03050'}}
  }

  for _, hlgr in pairs(hls) do
    vim.api.nvim_set_hl(hlgr[1], hlgr[2], hlgr[3])
  end
end
set_hl_groups()
