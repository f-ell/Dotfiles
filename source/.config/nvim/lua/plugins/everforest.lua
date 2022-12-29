return {
  'sainnhe/everforest',
  lazy      = true,
  config    = function()
    local F = require('utils.functions')

    F.g('everforest_background',              'soft')
    F.g('everforest_enable_bold',             '1')
    F.g('everforest_enable_italic',           '1')
    F.g('everforest_transparent_background',  '1')
    F.g('everforest_spell_foreground',        'colored')
    F.g('everforest_better_performance',      '1')
  end
}
