local F = require('utils.functions')
local strf    = string.format
local hl_nor  = '%#TlNor#'; local hl_sel = '%#TlSel#'


local tabline = function()
  local t = ''

  for i = 1, vim.fn.tabpagenr('$') do
    local winnr = vim.fn.tabpagewinnr(i)
    local bufnr = vim.fn.tabpagebuflist(i)[winnr]

    local modified = vim.api.nvim_buf_get_option(bufnr, 'modified')
      if modified then  modified = '*'
      else              modified = '' end

    local bufname = vim.fn.bufname(bufnr)
      if bufname ~= '' then
        bufname = string.gsub(bufname, '.*/', '')
      else
        bufname = '[unnamed]'
      end

    -- set highlight groups
    if i == vim.fn.tabpagenr() then t = strf('%s%s', t, hl_sel)
    else                            t = strf('%s%s', t, hl_nor) end

    -- build tabline
    local items = { modified, bufname, hl_nor }

    -- mouse support with '%iT'
    t = strf('%s%%%sT%s ', t, i, table.concat(items))
  end

  return strf('%s %s%s', hl_nor, t, hl_nor)
end


_G.tabline = tabline
F.o('showtabline', 1)
F.o('tabline', '%!v:lua.tabline()')
