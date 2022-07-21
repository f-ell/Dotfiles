require('trouble').setup({
  position  = 'bottom',
  height    = 6,
  padding = false,
  group   = true,
  action_keys = {
    close   = 'q',
    cancel  = '<Esc>',
    refresh = 'r',
    next = 'j',
    previous = 'k'
  },
  icons = false,
  use_diagnostic_signs = true
})
