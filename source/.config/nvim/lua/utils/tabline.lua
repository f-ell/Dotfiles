local F     = require('utils.functions')
local strf  = string.format


local tabline = function()
  local t = ''

  for i = 1, vim.fn.tabpagenr('$') do
    local winnr = vim.fn.tabpagewinnr(i)
    local bufnr = vim.fn.tabpagebuflist(i)[winnr]

    local modified = vim.api.nvim_buf_get_option(bufnr, 'modified')
    if modified then  modified = ''
    else              modified = '' end
    modified = strf(' %%%sX%s', i, modified)

    local bufname = vim.fn.bufname(bufnr)
    if bufname == '' then bufname = '[Untitled]'
    else                  bufname = string.gsub(bufname, '.*/', '') end

    -- set highlight groups
    local hl_type = 'Nor'
    if i == vim.fn.tabpagenr() then hl_type = 'Sel' end

    -- build tabline
    local hl_main = strf('%%#Tl%s#',  hl_type)
    local hl_aux  = strf('%%#Tl%sx#', hl_type)
    local items = {
      hl_aux, '',
      hl_main, bufname, modified,
      hl_aux, ''
    }

    -- mouse support with '%iT'
    t = strf('%s%%%sT%s ', t, i, table.concat(items))
  end

  return strf('%%#blank# %s%%#blank# ', t)
end


_G.tabline = tabline
F.o('showtabline', 1)
F.o('tabline', '%!v:lua.tabline()')
