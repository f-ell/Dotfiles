local set_hl_groups = function()
  local _ = ''

  local fg1   = '#fdf6e3'
  local fg2   = '#e8e0cc'
  local fg3   = '#859289'
  local fg4   = '#374247'
  local fg5   = '#2a3439'
  local ro    = '#f85552'
  local git   = '#fca326'

  -- local dr1  = '#6d5261'
  -- local dr2  = '#472e3c'

  local aqu1 = '#83c092'
  local aqu2 = '#35a77c'
  local blu1 = '#7fbbb3'
  local blu2 = '#3a94c5'
  local gre1 = '#a7c080'
  local gre2 = '#8da101'
  local pur1 = '#d699b6'
  local pur2 = '#df69ba'
  local red1 = '#e67e80'
  local red2 = '#f85552'
  local yel1 = '#dbbc7f'
  local yel2 = '#dfa000'

  local cmd = red1
  local ins = aqu1
  local nor = fg4
  local rep = yel1
  local ter = gre1
  local vis = pur1

  local hls = {
    -- custom groups
    {0, 'fg_dark',  {fg = fg2, bg = _}}, -- is this used?

    -- Modes
    {0, 'modeC',  {fg = fg1, bg = cmd}},
    {0, 'modeI',  {fg = fg5, bg = ins}},
    {0, 'modeN',  {fg = fg1, bg = nor}},
    {0, 'modeR',  {fg = fg5, bg = rep}},
    {0, 'modeT',  {fg = fg5, bg = ter}},
    {0, 'modeV',  {fg = fg5, bg = vis}},

    -- Search
    {0, 'Search',     {fg = fg2, bg = red2}},
    {0, 'IncSearch',  {link = 'Search'}},
    {0, 'CurSearch',  {fg = red2, bg = fg2}},
    {0, 'Substitute', {link = 'CurSearch'}},

    {0, 'Visual',     {link = 'CurSearch'}},

    -- Statusline
    {0, 'SlDef',  {fg = fg1, bg =  _, italic = true}},
    {0, 'SlRo',   {fg = fg1, bg = ro,   bold = true}},
    {0, 'SlGit',  {fg = git, bg =  _, italic = true}},

    -- Tabline
    {0, 'TabLine',      {fg = fg3, bg = fg5, italic = true}},
    {0, 'TabLineSel',   {fg = fg2, bg = fg4, italic = true, bold = true}},
    {0, 'TabLineFill',  {fg = fg1, bg = _}},

    -- Float-Diagnostics
    {0, 'GhostHead',    {fg = fg3,  bg = none, italic = true}},
    {0, 'NormalHead',   {fg = aqu1, bg = none,                bold = true}},
    {0, 'NormalBody',   {fg = fg3,  bg = none}},
    {0, 'HintHead',     {fg = blu1, bg = none}},
    {0, 'HintBody',     {fg = blu1, bg = none}},
    {0, 'InfoHead',     {fg = aqu1, bg = none}},
    {0, 'InfoBody',     {fg = aqu1, bg = none}},
    {0, 'WarningHead',  {fg = yel1, bg = none, italic = true, bold = true}},
    {0, 'WarningBody',  {fg = yel1, bg = none}},
    {0, 'ErrorHead',    {fg = red1, bg = none, italic = true, bold = true}},
    {0, 'ErrorBody',    {fg = red1, bg = none}},

    -- Float
    {0, 'NormalFloat',  {fg = none, bg = none}},
    {0, 'FloatBorder',  {fg = pur1, bg = none}},

    -- Telescope
    {0, 'TelescopeBorder',        {fg = fg5,  bg = fg5}},
    {0, 'TelescopeMatching',      {fg = pur2, bg = fg1}},
    {0, 'TelescopeSelection',     {fg = fg1,  bg = pur1}},

    {0, 'TelescopeTitle',         {fg = fg1, bg = pur1}},
    {0, 'TelescopeNormal',        {fg = fg1, bg = fg5}},

    {0, 'TelescopePreviewTitle',  {fg = fg1, bg = blu1}},
    {0, 'TelescopePreviewNormal', {fg = fg1, bg = fg5}},

    {0, 'TelescopePromptBorder',  {fg = fg4,  bg = fg4}},
    {0, 'TelescopePromptCounter', {fg = fg2,  bg = _}},
    {0, 'TelescopePromptNormal',  {fg = fg1,  bg = fg4}},
    {0, 'TelescopePromptPrefix',  {fg = aqu1, bg = _}},
    {0, 'TelescopePromptTitle',   {fg = fg1,  bg = aqu1}},

    -- Gitsigns
    {0, 'GSAdd',    {fg = gre1, bg = none}},
    {0, 'GSCha',    {fg = blu1, bg = none}},
    {0, 'GSDel',    {fg = red1, bg = none}},
    {0, 'GSAddNr',  {link = 'GitsignsAddNr'}},
    {0, 'GSAddLn',  {link = 'GitSignsAddLn'}},
    {0, 'GSChaNr',  {link = 'GitSignsChangeNr'}},
    {0, 'GSChaLn',  {link = 'GitSignsChangeLn'}},
    {0, 'GSDelNr',  {link = 'GitSignsDeleteNr'}},
    {0, 'GSDelLn',  {link = 'GitSignsDeleteLn'}},
  }

  for _, hlgr in pairs(hls) do
    vim.api.nvim_set_hl(hlgr[1], hlgr[2], hlgr[3])
  end
end
set_hl_groups()
