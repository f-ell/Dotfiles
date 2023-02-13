return {
  'dhruvasagar/vim-table-mode',
  lazy    = true,
  cmd     = 'TableModeEnable',
  config  = function()
    local L = require('utils.lib')

    L.g('table_mode_relign_map',                '<leader>tr')
    L.g('table_mode_tableize_map',              '<leader>tt')
    L.g('table_mode_delete_row_map',            '<leader>tdr')
    L.g('table_mode_delete_column_map',         '<leader>tdc')
    L.g('table_mode_insert_column_before_map',  '<leader>tic')
    L.g('table_mode_insert_column_after_map',   '<leader>tac')
  end
}
