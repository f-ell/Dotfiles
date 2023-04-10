local L = require('utils.lib')
local d = require('lsp.ui.diagnostic')
local signs, line

local lnum = function()
  return [[%{v:virtnum < 1 ? (v:relnum ? v:relnum : (v:lnum < 100 ? v:lnum.' ' : v:lnum)) : ''}]]
end

local statuscolumn = function()
  return table.concat({
    '%=', lnum(), ' %@v:lua.statuscolumn_diagnostic@%s%X'
  })
end

_G.statuscolumn_diagnostic = function()
  local pos = vim.fn.getmousepos()
  vim.api.nvim_win_set_cursor(0, { pos.line, 0 })

  if (line ~= pos.line) then
    line = pos.line
    signs = vim.fn.sign_getplaced(vim.fn.bufname(),
      { group = '*', lnum = pos.line })[1].signs
  end

  for _, sign in pairs(signs) do
    if (vim.startswith(sign.group, 'vim.diagnostic.vim.lsp.')) then
      d.get_line()
      break
    end
  end
end

_G.statuscolumn = statuscolumn
L.vim.o('numberwidth', 3)
L.vim.o('statuscolumn', '%!v:lua.statuscolumn()')
