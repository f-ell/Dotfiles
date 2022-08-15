local set_hl_groups = function()
  local fg_1 = '#ffffff'
  local fg_2 = '#b0b0b0'
  local hls = {
    -- {0, 'name', {fg = '', bg = ''}},

    {0, 'bg',     {fg = fg_1, bg = ''}},
    {0, 'ro',     {fg = fg_1, bg = '#ff3050'}},

    {0, 'Search',       {fg = fg_1, bg = '#8020f0'}},
    {0, 'Visual',       {fg = '',   bg = '#500040'}},

    {0, 'TabLine',      {fg = fg_2, bg = '#400070'}},
    {0, 'TabLineSel',   {fg = fg_1, bg = '#8020f0'}},
    {0, 'TabLineFill',  {fg = fg_1, bg = ''}},

    {0, 'modeN',  {fg = fg_1, bg = '#8020f0'}},
    {0, 'modeC',  {fg = fg_1, bg = '#30c080'}},
    {0, 'modeV',  {fg = fg_1, bg = '#700060'}},
    {0, 'modeR',  {fg = fg_1, bg = '#b8b800'}},
    {0, 'modeT',  {fg = fg_1, bg = '#3d3d3d'}},
    {0, 'modeI',  {fg = fg_1, bg = '#b02050'}}
  }

  for _, hlgr in pairs(hls) do
    vim.api.nvim_set_hl(hlgr[1], hlgr[2], hlgr[3])
  end
end
set_hl_groups()
