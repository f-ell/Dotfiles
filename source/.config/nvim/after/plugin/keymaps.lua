local F = require('utils.functions')
local v = vim


local wipe_buf = function()
  if v.fn.tabpagenr('$') == 1 then  v.cmd('enew | bw #')
  else                              v.cmd('bw') end
end


local tab_bufs = function()
  -- loops over tabs - checks if any window holds target buffer in any tab
  local haswindow = function(target_bufnr)
    for i = 1, v.fn.tabpagenr('$') do
      local tabbuflist = v.fn.tabpagebuflist(i)
      for j = 1, #(tabbuflist) do
        if v.fn.bufnr(tabbuflist[j]) == target_bufnr then return true end
      end
    end

    return false
  end

  -- loop over buffers - check if buffer should be split to new tab
  for _, b in pairs(v.api.nvim_list_bufs()) do
    local bufname = v.fn.bufname(b)

    if    v.fn.buflisted(b) == 1
      -- and v.fn.bufloaded(v) == 1
      and not haswindow(b)
      and bufname ~= '' then
      v.cmd('tabe '..bufname)
    end
  end

  v.cmd('tablast')
end


local terminal = function()
  local bufname     = 'term_buffer'
  local termheight  = v.api.nvim_win_get_height(0) / 4

  -- if focused -> close
  if string.find(v.api.nvim_buf_get_name(0), bufname) then
    return v.api.nvim_command('close')
  end

  local bufnr = v.fn.bufnr(bufname)
  -- buffer doesn't exist -> create buf
  if bufnr == -1 then
    bufnr = v.api.nvim_create_buf(false, false)
    if bufnr == 0 then
      return print('Fatal error while spawing new terminal buffer!')
    end
  -- buffer exists ->
  else
    -- window exists? -> focus
    local winid = v.fn.bufwinid(bufnr)
    if winid ~= -1 then return v.fn.win_gotoid(winid) end
  end

  -- window doesn't exist? -> split
  v.api.nvim_command('bot sb'..bufnr..' | resize '..termheight)

  -- window is empty -> open new terminal and rename
  if v.fn.bufname(bufnr) == '' then
    v.fn.termopen('/bin/zsh')
    v.api.nvim_command('0f | f '..bufname)
  end
end


local polymerize = function()
  local ft    = F.o('filetype')
  local dir   = os.getenv('HOME')..'/Media/Pictures/Screenshots/Code/'
  local file  = 'silicon_'..os.date('%Y%m%d-%H%M%S')..'.png'
  local args  = {
    '-l '..ft,
    '-o '..dir..file,
    '-f \'Ellograph CF\'',
    '-b \'#7fbbb3\'',
    '--shadow-offset-x 4',
    '--shadow-offset-y 4',
    '--shadow-blur-radius 6',
    '--shadow-color \'#374247\'',
    '--no-window-controls',
    '--theme everforest_dark'
  }

  -- get selection contents
  local s_ln  = v.fn.getpos('v')[2]
  local e_ln  = v.fn.getpos('.')[2]
  local sel   = s_ln < e_ln
    and v.fn.getline(s_ln, e_ln)
    or  v.fn.getline(e_ln, s_ln)

  -- escape necessary substrings
  for i, s in pairs(sel) do
    local mut = string.gsub(s, '"', '\\"')
          mut = string.gsub(mut, '`', '\\`')
          mut = string.gsub(mut, '\\%$', '$')
          mut = string.gsub(mut, '%$', '\\$')
          mut = string.gsub(mut, '%%', '%%%%')
    sel[i] = mut
  end

  -- run silicon
  local ret = os.execute(
    'printf "'..table.concat(sel, '\n')..'" | silicon '..table.concat(args, ' ')
  )

  if ret == 0 then
    print('screenshot saved as '..file)
  else
    print('fatal: couldn\'t create screenshot')
  end
end




-- misc
F.nnmap('--', '<CMD>w<CR>')
F.nnmap('-d', '<CMD>bd<CR>')
F.nnmap('-w',         function() wipe_buf() end)
F.nnmap('<leader>tb', function() tab_bufs() end)
F.vnmap('<leader>p',  function() polymerize() end)

F.nnmap('<leader>~',  'viw~')
F.nnmap('<leader>w',  '<CMD>w !doas tee %<CR>')
F.nnmap('<leader>x',  '<CMD>!chmod 744 %<CR>')
F.nnmap('<leader>%%', '<CMD>so %<CR>')
F.nnmap('<leader>%k', '<CMD>so ~/.config/nvim/after/plugin/keymaps.lua<CR>')
F.nnmap('<leader>%s', '<CMD>so ~/.config/nvim/lua/plugins/luasnip.lua<CR>')

F.tnmap('<C-d>', '<C-\\><C-n>')
F.nnmap('<leader><CR>', function() terminal() end)

-- credits primeagen
F.nnmap('n', 'nzz')
F.nnmap('N', 'Nzz')
F.nnmap('<C-u>', '<C-u>zz')
F.nnmap('<C-d>', '<C-d>zz')
F.nnmap('<leader>y', '"+y')
F.vnmap('<leader>y', '"+y')
F.nnmap('<leader>d', '"_d')
F.vnmap('<leader>d', '"_d')

  -- tabs
F.nnmap('<leader>g0', '<CMD>tabfirst<CR>')
F.nnmap('<leader>g$', '<CMD>tablast<CR>')
F.nnmap('<leader>gh', '<CMD>silent! tabmove-<CR>')
F.nnmap('<leader>gj', '<CMD>tabmove0<CR>')
F.nnmap('<leader>gl', '<CMD>silent! tabmove+<CR>')
F.nnmap('<leader>gk', '<CMD>tabmove$<CR>')

-- ex-mode navigation
F.cnmap('<C-h>', '<Left>')
F.cnmap('<C-k>', '<Up>')
F.cnmap('<C-j>', '<Down>')
F.cnmap('<C-l>', '<Right>')

  -- windows
F.nnmap('<A-h>', '<C-w>h')
F.nnmap('<A-j>', '<C-w>j')
F.nnmap('<A-k>', '<C-w>k')
F.nnmap('<A-l>', '<C-w>l')

  -- html / css / js
F.nnmap('<leader>br', 'oborder<CMD> 1px solid red;<Esc>o<Esc>')
F.nnmap('<leader>bg', 'oborder<CMD> 1px solid green;<Esc>o<Esc>')
F.nnmap('<leader>bb', 'oborder<CMD> 1px solid blue;<Esc>o<Esc>')
