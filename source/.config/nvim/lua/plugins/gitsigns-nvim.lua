local F = require('utils.functions')

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


-- maps
F.nnmap('<leader>gsh', ':Gitsigns diffthis<CR>')
F.nnmap('<leader>gsj', ':silent Gitsigns next_hunk<CR>')
F.nnmap('<leader>gsk', ':silent Gitsigns prev_hunk<CR>')
F.nnmap('<leader>gsl', ':Gitsigns toggle_deleted<CR>')
F.nnmap('<leader>gsc', ':Gitsigns toggle_linehl<CR>')
