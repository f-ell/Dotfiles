local F = require('utils.functions')

-- bootstrap
local v     = vim
local std   = v.fn.stdpath
local path  = std('data')..'/lazy/lazy.nvim'

if not v.loop.fs_stat(path) then
  v.fn.system({
    "git", "clone",
    "--filter=blob:none", "--single-branch",
    "https://github.com/folke/lazy.nvim.git", path
  })
end

v.opt.runtimepath:prepend(path)


-- init
require('lazy').setup('plugins', {
  root        = std('data') .. '/lazy',
  lockfile    = std('data') .. '/lazy/lazy-lock.json',
  install     = { missing = true, colorscheme = { 'everforest' } },
  checker     = { enabled = false, frequency  = 86400 },
  ui          = { border = 'rounded' },
  performance = {
    cache = {
      enabled = true,
      path    = std('cache')..'/lazy/cache'
    }
  }
})

F.nnmap('<leader>*', ':Lazy<CR>')
