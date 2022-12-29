return {
  'dhruvasagar/vim-table-mode',
  lazy    = true,
  cmd     = 'TableModeEnable',
  config  = function()
    local F = require('utils.functions')

    F.g('table_mode_relign_map',                '<leader>tr')
    F.g('table_mode_tableize_map',              '<leader>tt')
    F.g('table_mode_delete_row_map',            '<leader>tdr')
    F.g('table_mode_delete_column_map',         '<leader>tdc')
    F.g('table_mode_insert_column_before_map',  '<leader>tic')
    F.g('table_mode_insert_column_after_map',   '<leader>tac')
  end
}
