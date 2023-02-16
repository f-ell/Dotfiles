-- ____   ____
-- |   \  |  |______
-- |    \ |  | ___  \
-- |     \|  | |  \  |
-- |  \   \  | |__/  |
-- |  |\     | _____/
-- |__| \____| | Author: Nico Pareigis
--          |__| Neovim

local L = require('utils.lib')
L.vim.g('mapleader', ' ')

require('utils.lazy')

L.vim.o('termguicolors', true)
L.vim.c('colorscheme everforest')

require('utils')
