return {
  'sainnhe/everforest',
  lazy = true,
  config = function()
    local vim = require('utils.lib').vim
    vim.o('background', 'dark')
    vim.g('everforest_background',              'soft')
    vim.g('everforest_enable_bold',             '1')
    vim.g('everforest_enable_italic',           '1')
    vim.g('everforest_transparent_background',  '1')
    vim.g('everforest_spell_foreground',        'colored')
    vim.g('everforest_better_performance',      '1')
  end
}
