local L     = require('utils.lib')
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
    local hl_type = i == v.fn.tabpagenr() and 'Active' or 'Inactive'
    local hl_gr = strf('%%#Tl%s#', hl_type)

    -- build tabline
    local items = { hl_gr, ' ', modified, bufname, ' ' }
    t = strf('%s%%%sT%s', t, i, table.concat(items))
  end

  return strf('%s%%#TlInactive# ', t)
end


_G.tabline = tabline
L.o('showtabline', 1)
L.o('tabline', '%!v:lua.tabline()')
