local icons = {
  Class         = "",
  Color         = "",
  Constructor   = "",
  Enum          = "",
  EnumMember    = "",
  Event         = "",
  Field         = "",
  File          = "",
  Folder        = "",
  Function      = "",
  Interface     = "",
  Keyword       = "",
  Method        = "m",
  Module        = "",
  Property      = "",
  Reference     = "",
  Snippet       = "",
  Text          = "",
  TypeParameter = "",
  Unit          = "",
  Constant      = "",
  Struct        = "",
  Operator      = "",
  Value         = "",
  Variable      = ""
}

-- Load snippets
require('luasnip.loaders.from_snipmate').lazy_load({
  paths = {'~/.config/nvim/lua/snippets'}
})

-- Configure and load cmp
local cmp   = require('cmp')
local lsnip = require('luasnip')
cmp.setup({
    enabled = function()
      local context = require('cmp.config.context')
      if context.in_treesitter_capture == true
        or context.in_syntax_group == true then
        return false
      end
      return true
    end,

    snippet = {
        expand = function(args)
            lsnip.lsp_expand(args.body)
        end,
    },

    sources = {
        {name = 'luasnip',
         max_item_count = 4},
        {name = 'nvim_lsp',
         max_item_count = 4},
        {name = 'nvim_lua',
         max_item_count = 4},
        {name = 'buffer',
         max_item_count = 4}
    },

    window = {
      completion = {
        col_offset   = 1,
        side_padding = 0
      }
    },

    formatting = {
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, item)
        item.abbr = string.sub(item.abbr, 1, 18)
        item.kind = string.format('%s', icons[item.kind])
        item.menu = ({
            luasnip   = '-Snp-',
            nvim_lsp  = '-Lsp-',
            nvim_lua  = '-Lua-',
            buffer    = '-Buf-'
        })[entry.source.name]
        return item
      end
    },

    view = {
      entries = {
        name = 'custom',
        selection_order = 'near_cursor'
      }
    },

    mapping = {
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete()),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({select = true})
          elseif lsnip.expand_or_jumpable() then
            lsnip.expand_or_jump()
          else
            fallback()
          end
        end)
    },

    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select   = false
    },

    experimental = {
      ghost_text = true
    }
})
