local ls    = require('luasnip')
local types = require('luasnip.util.types')

ls.config.setup({
  history       = true,
  update_events = 'TextChanged,TextChangedI',
  delete_check_events = 'InsertLeave',
  ext_opts = {
    [types.insertNode] = {
      active = {hl_group = 'modeI'}
    },
    [types.choiceNode] = {
      active = {hl_group = 'modeI', virt_text = {{'<- choice', '<- error'}}}
    }
  }
})

-- require('luasnip.loaders.from_snipmate')
--   .lazy_load({paths = {'~/.config/nvim/snippets'}})

require('luasnip.loaders.from_lua')
  .lazy_load({paths = {'~/.config/nvim/snippets'}})
