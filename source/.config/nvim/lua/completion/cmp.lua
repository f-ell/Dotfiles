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
-- require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_snipmate').lazy_load({
  paths = {'~/.config/nvim/lua/completion/snippets'}
})

-- Configure and load cmp
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    sources = {
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'buffer' }
    },
    formatting = {
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, item)
        item.kind = string.format('%s', icons[item.kind])
        item.menu = ({
            nvim_lsp = '-Lsp-',
            nvim_lua = '-Lua-',
            luasnip = '-Snip-',
            buffer = '-Buf-'
        })[entry.source.name]
        return item
      end
    },
    mapping = {
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-Space>'] = cmp.mapping.confirm{ select = true }
    },
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false
    },
    experimental = {
      ghost_text = true
    }
})
