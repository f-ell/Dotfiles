local F = require('utils.functions')
local strf  = string.format

M = {}


M.tabline = function()
  local first_index = 1
  local last_index  = vim.fn.tabpagenr('$')

  local t = ''

  for i = first_index, last_index do
    local winnr   = vim.fn.tabpagewinnr(i)
    local bufnr   = vim.fn.tabpagebuflist(i)[winnr]

    local modified  = vim.api.nvim_buf_get_option(bufnr, 'modified')
      if modified then
        -- alternatives: * ●
        modified = '*' 
      else
        modified = ''
      end

    local bufname = vim.fn.bufname(bufnr)
      if bufname ~= '' then
        bufname = string.gsub(bufname, '.*/', '')
      else
        bufname = '[No Name]'
      end

    -- set highlight groups
    if i == vim.fn.tabpagenr() then 
      -- alternatives:  right aligned => ▕ ▐ ,  left aligned => ▎ ▍
      -- t = strf('%s%s▎', t, '%#TabLineSel#')
      t = strf('%s%s ', t, '%#TabLineSel#')
    else
      t = strf('%s%s ', t, '%#TabLine#')
    end

    -- build tabline
    local items = {
      -- ' ',
      modified,
      bufname,
      ' ',
      '%#TabLineFill#'
    }

    -- mouse support with '%iT'
    t = strf('%s%%%sT%s', t, i, table.concat(items))
  end

  t = strf('%s%s', t, '%#TabLineFill#')

  return t
end


F.gset('showtabline', 2)
_G.set_tabline = M.tabline
F.gset('tabline', '%!v:lua.set_tabline()')

-- vim.api.nvim_create_autocmd(
--   {'TermOpen', 'TermEnter'},
--   { command = 'noautocmd' }
-- )

vim.api.nvim_create_autocmd(
  {'BufAdd', 'BufNewFile', 'VimEnter'},
  {
    pattern = {'*'},
    command = 'tab ball',
    nested = true -- required to load correct filetype in all tabs
  }
)
