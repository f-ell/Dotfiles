-- ____   ____
-- |   \  |  |______
-- |    \ |  | ___  \
-- |     \|  | |  \  |
-- |  \   \  | |__/  |
-- |  |\     | _____/
-- |__| \____| | Author: Nico Pareigis
--          |__| Neovim

local F = require('utils.functions')
F.g('mapleader', ' ')

require('utils.lazy')

F.o('termguicolors', true)
F.c('colorscheme everforest')

require('utils')
