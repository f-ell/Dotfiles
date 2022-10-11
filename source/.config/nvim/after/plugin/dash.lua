-- qol functions
local optget = function(n) return vim.opt[n]:get() end

-- default options
local def_opts = {
  ['laststatus']  = optget'laststatus',
  ['showtabline'] = optget'showtabline',
  ['number']          = optget'number',
  ['relativenumber']  = optget'relativenumber',
  ['readonly']    = false,
  ['modifiable']  = true,
  ['list']  = optget'list',
  ['spell'] = optget'spell',
  ['cursorline']    = optget'cursorline',
  ['cursorcolumn']  = optget'cursorcolumn',
  ['buflisted'] = true,
  ['bufhidden'] = 'hide'
}

-- dashboard options
local dash_opts = {
  ['filetype']    = 'dash',
  ['laststatus']  = 0,
  ['showtabline'] = 0,
  ['number']          = false,
  ['relativenumber']  = false,
  ['readonly']    = true,
  ['modifiable']  = false,
  ['list']  = false,
  ['spell'] = false,
  ['cursorline']    = false,
  ['cursorcolumn']  = false,
  ['buflisted'] = false,
  ['bufhidden'] = 'wipe'
}

-- set options in tbl
local set_opts = function(tbl)
  for k, v in pairs(tbl) do
    vim.opt_local[k] = v
  end
end

-- create dashbaord
local dashgroup = vim.api.nvim_create_augroup('dash', {clear = true})
vim.api.nvim_create_autocmd('VimEnter', {
  group     = dashgroup,
  nested    = true,
  callback  = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 then
      -- set buffer and window number
      local bufnr = vim.api.nvim_get_current_buf()
      local winnr = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(winnr, bufnr)

      -- set dashboard options
      set_opts(dash_opts)

      -- set dashboard text

      -- reset options to user default on buffer / file change
      vim.api.nvim_create_autocmd('FileType', {
        group     = dashgroup,
        nested    = true,
        pattern   = 'dash',
        callback  = function()
          vim.api.nvim_create_autocmd('BufNew', {
            group     = dashgroup,
            callback  = function() set_opts(def_opts) end
          })
        end
      })
    end
  end
})
