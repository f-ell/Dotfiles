local F     = require('utils.functions')
local v     = vim
local strf  = string.format


local tabline = function()
  local t = ''

  for i = 1, v.fn.tabpagenr('$') do
    local winnr = v.fn.tabpagewinnr(i)
    local bufnr = v.fn.tabpagebuflist(i)[winnr]

    local modified = v.api.nvim_buf_get_option(bufnr, 'modified')
    if modified then  modified = ' '
    else              modified = '' end

    local bufname = v.fn.bufname(bufnr)
    if bufname == '' then bufname = '[null]'
    else                  bufname = string.gsub(bufname, '.*/', '') end

    -- set highlight groups
    local hl_type = 'Nor'
    if i == v.fn.tabpagenr() then hl_type = 'Sel' end

    -- build tabline
    local hl_main = strf('%%#Tl%s#',  hl_type)
    local hl_aux  = strf('%%#Tl%sx#', hl_type)
    local items = {
      hl_aux, '',
      hl_main, modified, bufname,
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
