local L = require('utils.lib')

local lnum = function()
  if vim.v.virtnum ~= 0 then return '' end
  return vim.v.relnum == 0 and vim.v.lnum..' ' or vim.v.relnum
end

_G.statuscolumn_handler = function()
  local pos = vim.fn.getmousepos()
  vim.api.nvim_win_set_cursor(0, { pos.line, 0 })

  local signs = vim.fn.sign_getplaced(vim.fn.bufnr(),
    { group = '*', lnum = pos.line })[1].signs

  for _, sign in pairs(signs) do
    if (vim.startswith(sign.group, 'vim.diagnostic.vim.lsp.')) then
      require('lsp.ui').dgn.get_line()
      break
    end
  end
end

local statuscolumn = function()
  return table.concat({
    '%=', lnum(), ' %@v:lua.statuscolumn_handler@%s%X'
  })
end

_G.statuscolumn = statuscolumn
L.vim.o('numberwidth', 3)
L.vim.o('statuscolumn', '%!v:lua.statuscolumn()')
