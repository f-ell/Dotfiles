return {
  'sainnhe/everforest',
  lazy      = true,
  config    = function()
    local L = require('utils.lib')

    L.o('background', 'dark')
    L.g('everforest_background',              'soft')
    L.g('everforest_enable_bold',             '1')
    L.g('everforest_enable_italic',           '1')
    L.g('everforest_transparent_background',  '1')
    L.g('everforest_spell_foreground',        'colored')
    L.g('everforest_better_performance',      '1')
  end
}
