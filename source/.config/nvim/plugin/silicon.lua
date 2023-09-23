local L = require('utils.lib')

if vim.fn.executable('silicon') ~= 1 then return end

local dir = os.getenv('HOME')..'/Media/Pictures/Screenshots/Code/'
local colours = { 'e67e80', 'a7c080', 'dbbc7f', '7fbbb3', 'd699b6', '83c092' }

L.key.vnmap('<leader>*', function()
  local ft    = L.vim.o('filetype')
  local file  = 'silicon_'..os.date('%Y%m%d-%H%M%S')..'.png'
  local args  = {
    '-l '..ft,
    '-o '..dir..file,
    '-f \'Ellograph CF\'',
    '-b \'#'..colours[math.random(1, #colours)]..'\'',
    '--shadow-offset-x 4',
    '--shadow-offset-y 4',
    '--shadow-blur-radius 6',
    '--shadow-color \'#374247\'',
    '--no-window-controls',
    '--theme everforest_dark'
  }

  -- get selection contents
  local start_ln, end_ln  = vim.fn.getpos('v')[2], vim.fn.getpos('.')[2]
  local sel = start_ln < end_ln
    and vim.fn.getline(start_ln, end_ln)
    or  vim.fn.getline(end_ln, start_ln)

  -- escape substrings
  for i, s in pairs(sel) do
    local mut = s:gsub('\\', '\\\\')
          mut = mut:gsub('"', '\\"')
          mut = mut:gsub('`', '\\`')
          mut = mut:gsub('!', '\\!')
          mut = mut:gsub('%$', '\\$')
    sel[i] = mut
  end

  -- run silicon
  local ret = os.execute(
    'printf \'%s\' "'..table.concat(sel, '\n')..'" | silicon '..table.concat(args, ' ')
  )

  if ret == 0 then  vim.notify('silicon: saved as '..file, 2)
  else              vim.notify('silicon: couldn\'t create file', 4) end
end)
