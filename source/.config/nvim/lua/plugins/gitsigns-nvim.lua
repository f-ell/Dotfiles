local toggle_diff = function()
  if not vim.wo.diff then return require('gitsigns').diffthis() end

  -- WARN: will break with simultaneous diffs
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.fn.bufname(vim.fn.winbufnr(win)):match('^gitsigns://.-') then
      vim.api.nvim_win_close(win, true)
    end
  end
end

return {
  'lewis6991/gitsigns.nvim',
  lazy = true,
  event = 'BufReadPre',
  keys = {
    { 'gsh', toggle_diff },
    { 'gsj', '<CMD>silent Gitsigns next_hunk<CR>' },
    { 'gsk', '<CMD>silent Gitsigns prev_hunk<CR>' },
    { 'gsl', '<CMD>Gitsigns toggle_deleted<CR>' },
    { 'gsc', '<CMD>Gitsigns toggle_linehl<CR>' },
    { 'gs<', '<CMD>diffget gitsigns://*:0\\\\|2:<CR>' },
    { 'gs>', '<CMD>diffget gitsigns://*:3:<CR>' },
  },
  config = function()
    require('gitsigns').setup({
      attach_to_untracked = false,

      signs = {
        add          = { hl = 'GSAdd', text = '│', numhl='GSAddNr', linehl='GSAddLn' },
        change       = { hl = 'GSCha', text = '│', numhl='GSChaNr', linehl='GSChaLn' },
        delete       = { hl = 'GSDel', text = '│', numhl='GSDelNr', linehl='GSDelLn' },
        topdelete    = { hl = 'GSDel', text = '‾', numhl='GSDelNr', linehl='GSDelLn' },
        changedelete = { hl = 'GSCha', text = '~', numhl='GSChaNr', linehl='GSChaLn' },
      },

      signcolumn  = true,
      numhl       = false,
      linehl      = false,
      word_diff   = false,

      watch_gitdir = {
        interval      = 500,
        follow_files  = true
      },
    })
  end
}
