return {
  'lewis6991/gitsigns.nvim',
  lazy    = true,
  event   = 'BufReadPre',
  keys    = {
    { '<leader>gsh', '<CMD>Gitsigns diffthis<CR>' },
    { '<leader>gsj', '<CMD>silent Gitsigns next_hunk<CR>' },
    { '<leader>gsk', '<CMD>silent Gitsigns prev_hunk<CR>' },
    { '<leader>gsl', '<CMD>Gitsigns toggle_deleted<CR>' },
    { '<leader>gsc', '<CMD>Gitsigns toggle_linehl<CR>' }
  },
  config  = function()
    require('gitsigns').setup({
      attach_to_untracked = false,

      signs = {
        add          = {hl = 'GSAdd', text = '│', numhl='GSAddNr', linehl='GSAddLn'},
        change       = {hl = 'GSCha', text = '│', numhl='GSChaNr', linehl='GSChaLn'},
        delete       = {hl = 'GSDel', text = '│', numhl='GSDelNr', linehl='GSDelLn'},
        topdelete    = {hl = 'GSDel', text = '‾', numhl='GSDelNr', linehl='GSDelLn'},
        changedelete = {hl = 'GSCha', text = '~', numhl='GSChaNr', linehl='GSChaLn'},
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
