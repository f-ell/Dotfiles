local set_hl_groups = function()
  local _ = ''

  local fg1 = '#fdf6e3'
  local fg2 = '#d3c6aa'
  local fg3 = '#859289'
  local fg4 = '#434f55'
  local fg5 = '#374247'
  local fg6 = '#2a3439'

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

  local git = '#fca326'

  local highlights = {
    -- Search
    { 0, 'Search',     { fg = fg6, bg = aqu1 }},
    { 0, 'IncSearch',  { fg = fg6, bg = red1 }},
    { 0, 'CurSearch',  { link = 'IncSearch' }},
    { 0, 'Substitute', { link = 'IncSearch' }},
    { 0, 'Visual',     { fg = _,   bg = '#3d5665' }},

    -- Diagnostics
    { 0, 'ErrorText',   { sp = red1, underline = true }},
    { 0, 'WarningText', { sp = yel1, underline = true }},
    { 0, 'InfoText',    { sp = gre1, underline = true }},
    { 0, 'HintText',    { sp = blu1, underline = true }},
    { 0, 'DiagnosticSignError', { fg = red1 }},
    { 0, 'DiagnosticSignWarn',  { fg = yel1 }},
    { 0, 'DiagnosticSignInfo',  { fg = gre1 }},
    { 0, 'DiagnosticSignHint',  { fg = blu1 }},

    -- Float
    { 0, 'NormalFloat',    { fg = _,   bg = _ }},
    { 0, 'FloatTitle',     { fg = fg2, bg = _ }},
    { 0, 'FloatBorder',    { fg = fg3, bg = _ }},

    { 0, 'NeutralFloat',   { fg = fg3, bg = _ }},
    { 0, 'NeutralFloatSp', { fg = fg3, bg = _, italic = true, bold = true }},

    { 0, 'ErrorFloat',      { fg = red1, bg = _ }},
    { 0, 'WarningFloat',    { fg = yel1, bg = _ }},
    { 0, 'InfoFloat',       { fg = gre1, bg = _ }},
    { 0, 'HintFloat',       { fg = blu1, bg = _ }},
    { 0, 'ErrorFloatSp',    { fg = red1, bg = _, italic = true, bold = true }},
    { 0, 'WarningFloatSp',  { fg = yel1, bg = _, italic = true, bold = true }},
    { 0, 'InfoFloatSp',     { fg = gre1, bg = _, italic = true, bold = true }},
    { 0, 'HintFloatSp',     { fg = blu1, bg = _, italic = true, bold = true }},
    { 0, 'ErrorFloatInv',   { fg = fg6,  bg = red1 }},
    { 0, 'WarningFloatInv', { fg = fg6,  bg = yel1 }},
    { 0, 'InfoFloatInv',    { fg = fg6,  bg = gre1 }},
    { 0, 'HintFloatInv',    { fg = fg6,  bg = blu1 }},

    -- Statusline
    { 0, 'Statusline',          { fg = fg2,  bg = _ }},
    { 0, 'StatuslineReadonly',  { fg = red1, bg = _, bold = true }},
    { 0, 'StatuslineBytecount', { fg = yel1, bg = _ }},
    { 0, 'StatuslineSearch',    { fg = blu1, bg = _ }},
    { 0, 'StatuslineLocation',  { fg = aqu1, bg = _ }},

    -- Statusline Modes
    { 0, 'modeC', { fg = pur1, bg = _ }},
    { 0, 'modeI', { fg = blu1, bg = _ }},
    { 0, 'modeN', { fg = gre1, bg = _ }},
    { 0, 'modeR', { fg = yel1, bg = _ }},
    { 0, 'modeT', { fg = fg3,  bg = _ }},
    { 0, 'modeV', { fg = red1, bg = _ }},

    -- Tabline
    { 0, 'TlActive',   { fg = fg2, bg = fg5, bold = true }},
    { 0, 'TlInactive', { fg = fg3, bg = fg6 }},

    -- Misc
    { 0, 'SpellBad', { sp = red1, undercurl = true }},
    { 0, 'Git',      { fg = git,  bg = _ }},
    { 0, 'GitZero',  { fg = fg3,  bg = _ }},
    { 0, 'GitAdd',   { fg = gre1, bg = _ }},
    { 0, 'GitCha',   { fg = blu1, bg = _ }},
    { 0, 'GitDel',   { fg = red1, bg = _ }},

  -- PLUGINS --
    -- Cmp
    { 0, 'CmpItemMenu',           { fg = fg3,  bg = _ } },
    { 0, 'CmpItemAbbrMatch',      { fg = red1, bg = _ } },
    { 0, 'CmpItemAbbrMatchFuzzy', { fg = red1, bg = _ } },

    -- Dap
    { 0, 'DapStopped',             { fg = gre1 } },
    { 0, 'DapLogPoint',            { fg = yel1 } },
    { 0, 'DapBreakpoint',          { fg = red1 } },
    { 0, 'DapBreakpointCondition', { fg = pur2 } },
    { 0, 'DapBreakpointRejected',  { fg = red2 } },

    -- Git(signs)
    { 0, 'DiffText', { bg = '#3d5665', sp = blu1, underline = true }},
    { 0, 'GSAdd',    { fg = gre1,      bg = _ }},
    { 0, 'GSCha',    { fg = blu1,      bg = _ }},
    { 0, 'GSDel',    { fg = red1,      bg = _ }},
    { 0, 'GSAddNr',  { link = 'GitsignsAddNr' }},
    { 0, 'GSAddLn',  { link = 'GitSignsAddLn' }},
    { 0, 'GSChaNr',  { link = 'GitSignsChangeNr' }},
    { 0, 'GSChaLn',  { link = 'GitSignsChangeLn' }},
    { 0, 'GSDelNr',  { link = 'GitSignsDeleteNr' }},
    { 0, 'GSDelLn',  { link = 'GitSignsDeleteLn' }},

    -- Telescope
    { 0, 'TelescopeBorder',        { fg = fg3,  bg = _ }},
    { 0, 'TelescopeMatching',      { fg = red1, bg = _ }},
    { 0, 'TelescopeSelection',     { fg = fg1,  bg = fg5 }},
    { 0, 'TelescopeTitle',         { fg = red1, bg = _ }},
    { 0, 'TelescopeNormal',        { fg = fg1,  bg = _ }},
    { 0, 'TelescopePreviewTitle',  { fg = blu1, bg = _ }},
    { 0, 'TelescopePreviewNormal', { fg = fg1,  bg = _ }},
    { 0, 'TelescopePromptBorder',  { fg = fg3,  bg = _ }},
    { 0, 'TelescopePromptCounter', { fg = gre1, bg = _ }},
    { 0, 'TelescopePromptNormal',  { fg = fg1,  bg = _ }},
    { 0, 'TelescopePromptPrefix',  { fg = gre1, bg = _ }},
    { 0, 'TelescopePromptTitle',   { fg = gre1, bg = _ }},

    -- Treesitter
    { 0, 'TreesitterContext',           { fg = _,   bg = fg5 }},
    { 0, 'TreesitterContextLineNumber', { fg = fg3, bg = _ }},
   }

  for _, group in pairs(highlights) do
    vim.api.nvim_set_hl(group[1], group[2], group[3])
  end
end

set_hl_groups()
