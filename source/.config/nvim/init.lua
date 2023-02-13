-- ____   ____
-- |   \  |  |______
-- |    \ |  | ___  \
-- |     \|  | |  \  |
-- |  \   \  | |__/  |
-- |  |\     | _____/
-- |__| \____| | Author: Nico Pareigis
--          |__| Neovim

local L = require('utils.lib')
L.g('mapleader', ' ')

require('utils.lazy')

L.o('termguicolors', true)
L.c('colorscheme everforest')

require('utils')
