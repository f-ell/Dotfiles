return {
  'lewis6991/gitsigns.nvim',
  lazy = true,
  event = 'BufReadPre',
  keys = {
    { 'gsh', '<CMD>Gitsigns diffthis<CR>' },
    { 'gsj', '<CMD>silent Gitsigns next_hunk<CR>' },
    { 'gsk', '<CMD>silent Gitsigns prev_hunk<CR>' },
    { 'gsl', '<CMD>Gitsigns toggle_deleted<CR>' },
    { 'gsc', '<CMD>Gitsigns toggle_linehl<CR>' },
    { 'gs<', '<CMD>diffget gitsigns://*:0|2:<CR>' },
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
