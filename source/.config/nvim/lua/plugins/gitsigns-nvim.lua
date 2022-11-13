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