local F = require('utils.functions')


local wipe_buf = function()
  if vim.fn.tabpagenr('$') == 1 then
    vim.cmd('enew | bw #')
  else
    vim.cmd('bw')
  end
end


local tab_bufs = function()
  -- loops over tabs - checks if any window holds target buffer in any tab
  local haswindow = function(target_bufnr)
    -- return vim.fn.bufwinnr(bufnr) ~= -1
    for i = 1, vim.fn.tabpagenr('$') do
      local tabbuflist = vim.fn.tabpagebuflist(i)

      for j = 1, #(tabbuflist) do
        if vim.fn.bufnr(tabbuflist[j]) == target_bufnr then return true end
      end
    end

    return false
  end

  -- loop over buffers - check if buffer should be split to new tab
  for _, v in pairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.fn.bufname(v)

    if    vim.fn.buflisted(v) == 1
      -- and vim.fn.bufloaded(v) == 1
      and not haswindow(v)
      and bufname ~= '' then
      vim.cmd('tabe '..bufname)
    end
  end

  vim.cmd('tablast')
end


local terminal = function()
  local bufname     = 'term_buffer'
  local termheight  = vim.api.nvim_win_get_height(0) / 4

  -- if focused -> close
  if string.find(vim.api.nvim_buf_get_name(0), bufname) then
    return vim.api.nvim_command('close')
  end

  local bufnr = vim.fn.bufnr(bufname)
  -- buffer doesn't exist -> create buf
    -- if vim.fn.bufexists('term_buffer') == 0 then
  if bufnr == -1 then
    bufnr = vim.api.nvim_create_buf(false, false)
    if bufnr == 0 then
      return print('Fatal error while spawing new terminal buffer!')
    end
  -- buffer exists ->
  else
    -- window exists? -> focus
    local winid = vim.fn.bufwinid(bufnr)
    if winid ~= -1 then return vim.fn.win_gotoid(winid) end
  end

  -- window doesn't exist? -> split
  vim.api.nvim_command('bot sb'..bufnr..' | resize '..termheight)

  -- window is empty -> open new terminal and rename
  if vim.fn.bufname(bufnr) == '' then
    vim.fn.termopen('/bin/zsh')
    vim.api.nvim_command('0f | f '..bufname)
  end
end


local ls_jump_backwards = function()
  local ls = require('luasnip')
  if ls.jumpable(-1) then ls.jump(-1) end
end

local ls_expand_or_jump = function()
  local ls = require('luasnip')
  if ls.expand_or_jumpable() then ls.expand_or_jump() end
end

local ls_choice_forward = function()
  local ls = require('luasnip')
  if ls.choice_active() then ls.change_choice(1) end
end

local ls_choice_backward = function()
  local ls = require('luasnip')
  if ls.choice_active(-1) then ls.change_choice(-1) end
end


vim.g.mapleader = ' '

-- normal
F.nnmap('<leader>sok', ':so ~/.config/nvim/lua/utils/keymaps.lua<CR>')
F.nnmap('<leader>sos', ':so ~/.config/nvim/lua/plugins/luasnip.lua<CR>')

F.nnmap('--', ':w<CR>')
F.nnmap('-d', ':bd<CR>')
F.nnmap('-w', function() wipe_buf() end)
F.nnmap('<C-l>', ':noh<CR>')
F.nnmap('<leader>%', ':so%<CR>')

F.nnmap('<leader>tb',   function() tab_bufs() end)
F.nnmap('<leader><CR>', function() terminal() end)

F.nnmap('<leader>~', 'viw~')


-- insert
F.inmap('<C-h>', function() ls_jump_backwards() end)
F.inmap('<C-j>', function() ls_choice_forward() end)
F.inmap('<C-k>', function() ls_choice_backward() end)
F.inmap('<C-l>', function() ls_expand_or_jump() end)

-- command
F.cnmap('<C-h>', '<Left>')
F.cnmap('<C-k>', '<Up>')
F.cnmap('<C-j>', '<Down>')
F.cnmap('<C-l>', '<Right>')

-- terminal
F.tnmap('<C-d>', '<C-\\><C-n>')


-- html / css / js
F.nnmap('<leader>br', 'oborder: 1px solid red;<Esc>o<Esc>')
F.nnmap('<leader>bg', 'oborder: 1px solid green;<Esc>o<Esc>')
F.nnmap('<leader>bb', 'oborder: 1px solid blue;<Esc>o<Esc>')


-- tabs
F.nnmap('<leader>g0', ':tabfirst<CR>')
F.nnmap('<leader>g$', ':tablast<CR>')
F.nnmap('<leader>gh', ':tabmove-<CR>')
F.nnmap('<leader>gj', ':tabmove0<CR>')
F.nnmap('<leader>gl', ':tabmove+<CR>')
F.nnmap('<leader>gk', ':tabmove$<CR>')


-- windows
F.nnmap('<A-h>', '<C-w>h')
F.nnmap('<A-j>', '<C-w>j')
F.nnmap('<A-k>', '<C-w>k')
F.nnmap('<A-l>', '<C-w>l')


-- plugins
  -- packer
    F.nnmap('<leader>ps', ':PackerStatus<CR>')
    F.nnmap('<leader>pc', ':PackerCompile<CR>')
    F.nnmap('<leader>py', ':PackerSync<CR>')

  -- telescope
    F.nnmap('<leader>f',  ':Telescope find_files<CR>')
    F.nnmap('<leader>tg', ':Telescope git_files<CR>')
    F.nnmap('<leader>tr', ':Telescope live_grep<CR>')
    F.nnmap('<leader>tf', ':Telescope current_buffer_fuzzy_find<CR>')

  -- colorizer
    F.nnmap('<leader>ct', ':ColorizerToggle<CR>')

  -- emmet
    F.inmap('<A-e>', '<C-y>,<Esc>')
    F.nnmap('<A-e>', '<C-y>,<Esc>')

  -- gitsigns
    F.nnmap('<leader>gsh', ':Gitsigns diffthis<CR>')
    F.nnmap('<leader>gsj', ':silent Gitsigns next_hunk<CR>')
    F.nnmap('<leader>gsk', ':silent Gitsigns prev_hunk<CR>')
    F.nnmap('<leader>gsl', ':Gitsigns toggle_deleted<CR>')
    F.nnmap('<leader>gsc', ':Gitsigns toggle_linehl<CR>')

  -- markdownpreview
    F.nnmap('<A-p>', '<plug>MarkdownPreviewToggle')

  -- vimtex
    F.nnmap('<leader>vcl',  ':VimtexClean<CR>')
    F.nnmap('<leader>vcp',  ':VimtexCompileSS<CR>')
    F.nnmap('<leader>vtoc', ':VimTexTocToggle<CR>')
    F.nnmap('<leader>vst',  ':VimtexStatus!<CR>')
    F.nnmap('<leader>vv',   ':VimtexView<CR>')
