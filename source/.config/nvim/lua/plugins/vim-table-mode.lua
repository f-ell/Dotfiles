return {
  'dhruvasagar/vim-table-mode',
  lazy = true,
  cmd = 'TableModeEnable',
  config = function()
    local v = require('utils.lib').vim
    v.g('table_mode_relign_map',                '<leader>tr')
    v.g('table_mode_tableize_map',              '<leader>tt')
    v.g('table_mode_delete_row_map',            '<leader>tdr')
    v.g('table_mode_delete_column_map',         '<leader>tdc')
    v.g('table_mode_insert_column_before_map',  '<leader>tic')
    v.g('table_mode_insert_column_after_map',   '<leader>tac')
  end
}
