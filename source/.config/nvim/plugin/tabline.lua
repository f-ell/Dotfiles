local L = require('utils.lib')

local tabline = function()
  local tabs = {}

  for i = 1, vim.fn.tabpagenr('$') do
    local bufnr = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
    local name = vim.fn.bufname(bufnr) == ''
      and '[null]'
      or vim.fn.bufname(bufnr):gsub('.*/', '')

    local tab = {
      string.format('%%%sT', i),
      '%#Tl'..(i == vim.fn.tabpagenr() and 'Active' or 'Inactive')..'#',
      '▎',
      vim.api.nvim_buf_get_option(bufnr, 'modified') and ' + ' or '  ',
      name..'  '
    }

    table.insert(tabs, table.concat(tab))
  end

  return table.concat(tabs)..'%#TlInactive#'
end

_G.tabline = tabline
L.vim.o('showtabline', 1)
L.vim.o('tabline', '%!v:lua.tabline()')
