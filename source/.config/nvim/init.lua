-- ____   ____
-- |   \  |  |______
-- |    \ |  | ___  \
-- |     \|  | |  \  |
-- |  \   \  | |__/  |
-- |  |\     | _____/
-- |__| \____| | Author: Nico Pareigis
--          |__| Neovim
--
-- Note: for the statusline to reliably display git HEAD information,
-- 'autochdir' needs to be enabled (see utils.settings).

local F = require('utils.functions')
F.g('mapleader', ' ')

require('utils.lazy')

F.o('termguicolors', true)
F.c('colorscheme everforest')

require('utils')
