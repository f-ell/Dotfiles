local F = require('utils.functions')

-- Preparation
F.vg('everforest_background', 'soft')
F.vg('everforest_enable_bold', '1')
F.vg('everforest_enable_italic', '1')
F.vg('everforest_transparent_background', '1')
F.vg('everforest_spell_foreground', 'colored')
F.vg('everforest_better_performance', '1')

F.vg('background', 'dark')

-- Configuration
F.gset('termguicolors', true)
F.c('colorscheme everforest')
