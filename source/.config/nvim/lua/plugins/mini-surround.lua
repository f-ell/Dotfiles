return {
  'echasnovski/mini.surround',
  lazy    = true,
  -- event   = 'BufReadPre',
  keys    = { '+s', 'cs', 'ds', '<leader>+s', '<leader>ns' },
  config  = function()
    require('mini.surround').setup({
      custom_surroundings = nil,
      highlight_duration  = 1000,
      n_lines       = 20,
      search_method = 'cover_or_nearest',
      mappings = {
        add       = '+s',
        replace   = 'cs',
        delete    = 'ds',
        find      = '',
        find_left = '',
        highlight = '<leader>+s',
        update_n_lines = '<leader>ns',

        suffix_last = 'l',
        suffix_next = 'n'
      }
    })
  end
}
