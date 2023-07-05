local L = require('utils.lib')

local tabline = function()
  local t = ''

  for i = 1, vim.fn.tabpagenr('$') do
    local winnr = vim.fn.tabpagewinnr(i)
    local bufnr = vim.fn.tabpagebuflist(i)[winnr]

    local bufname = vim.fn.bufname(bufnr)
    if bufname == '' then bufname = '[null]'
    else                  bufname = string.gsub(bufname, '.*/', '') end

    -- set highlight groups
    local hl_type = i == vim.fn.tabpagenr() and 'Active' or 'Inactive'
    local mod = vim.api.nvim_buf_get_option(bufnr, 'modified') and 'Mod' or ''

    local hl_mod = string.format('%%#Tl%s%s#', mod, hl_type)
    local hl_item = string.format('%%#Tl%s#', hl_type)

    -- build tabline
    local items = { hl_mod, '▎ ', hl_item, bufname, '  ' }
    t = string.format('%s%%%sT%s', t, i, table.concat(items))
  end

  return string.format('%s%%#TlInactive# ', t)
end

_G.tabline = tabline
L.vim.o('showtabline', 1)
L.vim.o('tabline', '%!v:lua.tabline()')
