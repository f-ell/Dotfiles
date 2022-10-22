require('lspsaga').init_lsp_saga({
  border_style      = 'rounded',
  saga_winblend     = 0,
  move_in_saga      = { prev = '<C-k>', next = '<C-j>' },
  diagnostic_header = { ' ', ' ', ' ', 'ﴞ ' },
  code_action_lightbulb = {
    enable            = true,
    enable_in_insert  = false,
    sign              = false,
    update_time       = 100
  },
  code_action_icon  = '',
  max_preview_lines = 8,

  rename_action_quit  = '<C-c>',
  rename_in_select    = true,
  code_action_num_shortcut = true,
})
