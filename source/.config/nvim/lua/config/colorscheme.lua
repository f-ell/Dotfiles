local F = require('config.functions')

-- Serenade
F.vimg('serenade_enable_italic', '1')
F.vimg('serenade_disable_italic_comment', '0')
F.vimg('serenadde_transparent_background', '1')
F.vimg('serenadde_better_performance', '1')

-- Everforest
F.vimg('everforest_background', 'soft')
F.vimg('everforest_enable_bold', '1')
F.vimg('everforest_enable_italic', '1')
F.vimg('everforest_transparent_background', '1')
F.vimg('everforest_spell_foreground', 'colored')
F.vimg('everforest_better_performance', '1')

-- setting theme
F.setNV('noshowmode')
F.setNV('termguicolors')
F.setNV('background', 'dark')
F.setsV('colorscheme', 'everforest')
