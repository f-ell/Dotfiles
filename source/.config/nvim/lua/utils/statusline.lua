local F = require('utils.functions')
local strf = string.format

local md = function()
  local mode = vim.api.nvim_get_mode().mode

  if      mode == 'V'   then mode = 'VL'
  elseif  mode == '^V'  then mode = 'VB' end

  return strf(' %s', mode:upper())
end

local ft = function()
  -- return string.format(' %s ', vim.fn.fnamemodify(vim.fn.expand('%'), ':e:e:e'))
  local ft = vim.bo.filetype
  if ft ~= '' then ft = strf('%s | ', ft) end
  return ft
end

-- local function pos()
--   local pos = vim.api.nvim_win_get_cursor(0)
--   local row = pos[1]
--   local col = pos[2]
--
--   -- if row == 0 then row = 1 end
--   -- if col == 0 then col = 1 end
--
--   return strf('| %s:%s ', row, col + 1)
-- end
-- local ro = function()
--   local status = '%r'
--   if status == '[RO]' then status = '| ' .. status .. ' ' end
--   return status
-- end


SL = {}
SL.modules = function()
  return table.concat({
    md(),
    ' | %n',
    '%<',
    ' | %r%t',
    '%m',
    '%=',
    ft(),
    '%l:%v '
  })
end


F.gset('laststatus', 3)
vim.api.nvim_exec([[
  augroup SL
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.SL.modules()
  augroup end
]], false)
