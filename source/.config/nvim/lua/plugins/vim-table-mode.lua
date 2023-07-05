return {
  'dhruvasagar/vim-table-mode',
  lazy = true,
  cmd = 'TableModeEnable',
  config = function()
    local vim = require('utils.lib').vim
    vim.g('table_mode_relign_map',                '<leader>tr')
    vim.g('table_mode_tableize_map',              '<leader>tt')
    vim.g('table_mode_delete_row_map',            '<leader>tdr')
    vim.g('table_mode_delete_column_map',         '<leader>tdc')
    vim.g('table_mode_insert_column_before_map',  '<leader>tic')
    vim.g('table_mode_insert_column_after_map',   '<leader>tac')
  end
}
