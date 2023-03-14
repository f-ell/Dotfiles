return {
  'L3MON4D3/LuaSnip',
  lazy = true, -- required as dependency in cmp_bootstrap.lua
  dependencies = 'saadparwaiz1/cmp_luasnip',
  config = function()
    local ls    = require('luasnip')
    local types = require('luasnip.util.types')
    local key   = require('utils.lib').key

    ls.config.setup({
      history       = true,
      update_events = 'TextChanged,TextChangedI',
      delete_check_events = 'InsertLeave',
      ext_opts = {
        [types.insertNode] = { active = { hl_group = 'modeI' } },
        [types.choiceNode] = { active = {
            hl_group = 'modeI', virt_text = { '<- choice', '<- error' } } }
      }
    })

    require('luasnip.loaders.from_lua')
      .lazy_load({paths = {'~/.config/nvim/lua/snippets'}})

    local jump_backward = function() if ls.jumpable(-1) then ls.jump(-1) end end
    local expand_or_jump = function()
      if ls.expand_or_jumpable() then ls.expand_or_jump() end
    end
    local choice_forward = function()
      if ls.choice_active() then ls.change_choice(1) end
    end
    local choice_backward = function()
      if ls.choice_active(-1) then ls.change_choice(-1) end
    end

    key.inmap('<C-h>', function() jump_backward() end)
    key.inmap('<C-j>', function() choice_forward() end)
    key.inmap('<C-k>', function() choice_backward() end)
    key.inmap('<C-l>', function() expand_or_jump() end)
  end
}
