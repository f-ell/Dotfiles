local ls    = require('luasnip')
local types = require('luasnip.util.types')
local F     = require('utils.functions')

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

require('luasnip.loaders.from_lua')
  .lazy_load({paths = {'~/.config/nvim/lua/snippets'}})


-- maps
local ls_jump_backwards = function()
  if ls.jumpable(-1) then ls.jump(-1) end
end

local ls_expand_or_jump = function()
  if ls.expand_or_jumpable() then ls.expand_or_jump() end
end

local ls_choice_forward = function()
  if ls.choice_active() then ls.change_choice(1) end
end

local ls_choice_backward = function()
  if ls.choice_active(-1) then ls.change_choice(-1) end
end

F.inmap('<C-h>', function() ls_jump_backwards() end)
F.inmap('<C-j>', function() ls_choice_forward() end)
F.inmap('<C-k>', function() ls_choice_backward() end)
F.inmap('<C-l>', function() ls_expand_or_jump() end)
