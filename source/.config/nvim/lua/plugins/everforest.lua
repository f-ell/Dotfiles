return {
  'sainnhe/everforest',
  lazy      = true,
  config    = function()
    local v = require('utils.lib').vim

    v.o('background', 'dark')
    v.g('everforest_background',              'soft')
    v.g('everforest_enable_bold',             '1')
    v.g('everforest_enable_italic',           '1')
    v.g('everforest_transparent_background',  '1')
    v.g('everforest_spell_foreground',        'colored')
    v.g('everforest_better_performance',      '1')
  end
}
