-- ____   ____
-- |   \  |  |______
-- |    \ |  | ___  \
-- |     \|  | |  \  |
-- |  \   \  | |__/  |
-- |  |\     | _____/
-- |__| \____| | Author: Nico Pareigis
--          |__| Neovim

local L = require('utils.lib')

-- bootstrap
local v = vim
local std = v.fn.stdpath
local path = std('data')..'/lazy/lazy.nvim'

if not v.loop.fs_stat(path) then
  v.fn.system({
    'git', 'clone',
    '--filter=blob:none', '--single-branch',
    'https://github.com/folke/lazy.nvim.git', path
  })
end

-- init
L.vim.g('mapleader', ' ')
v.opt.runtimepath:prepend(path)

require('lazy').setup('plugins', {
  root      = std('data') .. '/lazy',
  lockfile  = std('data') .. '/lazy/lazy-lock.json',
  install   = { missing = true, colorscheme = { 'everforest' } },
  checker   = { enabled = false, frequency  = 86400 },
  ui        = { border = 'single' },
  performance = {
    cache = {
      enabled = true,
      path = std('cache')..'/lazy/cache'
    }
  }
})

L.key.nnmap('<leader>*', '<CMD>Lazy<CR>')
L.vim.o('termguicolors', true)
L.vim.c('colorscheme everforest')

require('utils')
L.fs.mktmpdir()
