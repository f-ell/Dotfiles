return {
  'hrsh7th/nvim-cmp',
  lazy  = true,
  event = 'InsertEnter',
  priority      = 1000,
  dependencies  = {
    { 'hrsh7th/cmp-cmdline', event = 'CmdlineEnter' },
    'hrsh7th/cmp-buffer',
    { 'hrsh7th/cmp-nvim-lua', ft = 'lua' },
    'L3MON4D3/LuaSnip'
  },
  config = function()
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

    local cmp = require('cmp')
    cmp.setup({
      enabled = function()
        local context = require('cmp.config.context')
        return not context.in_treesitter_capture('comment')
          and not context.in_syntax_group('Comment')
      end,

      snippet = {
        expand = function(arg) require('luasnip').lsp_expand(arg.body) end
      },

      sources = {
        { name = 'luasnip',
          max_item_count = 4,
          keyword_length = 1 },
        { name = 'nvim_lsp',
          keyword_length = 1 },
        { name = 'nvim_lua',
          keyword_length = 1 },
        { name = 'buffer',
          max_item_count = 4,
          keyword_length = 4,
          option = {
            get_bufnrs = function()
              local va = vim.api
              local buf = va.nvim_get_current_buf()
              local byte_size = va.nvim_buf_get_offset(buf, va.nvim_buf_line_count(buf))
              if byte_size > 1024 * 1024 then return {} end -- 1 MiB max
              return { buf }
            end
          }
        }
      },

      window = { completion = { col_offset   = 1, side_padding = 0 } },
      view = { entries = { name = 'custom', selection_order = 'near_cursor' } },

      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, item)
          item.abbr = string.sub(item.abbr, 1, 18)
          item.kind = string.format('%s', icons[item.kind])
          item.menu = ({
            luasnip   = '-Snp-',
            nvim_lsp  = '-Lsp-',
            nvim_lua  = '-Lua-',
            omni      = '-Omn-',
            buffer    = '-Buf-'
          })[entry.source.name]
          return item
        end
      },

      mapping = {
        ['<C-l>']     = cmp.mapping.confirm({ select = true }),
        ['<C-k>']     = cmp.mapping.select_prev_item(),
        ['<C-j>']     = cmp.mapping.select_next_item(),
        ['<C-e>']     = cmp.mapping.abort(),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete())
      },

      confirm_opts = { behavior = cmp.ConfirmBehavior.Replace, select = false },
      experimental = { ghost_text = true }
    })

    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {{ name = 'buffer' }}
    })
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({{ name = 'path' }}, {{ name = 'cmdline' }})
    })
  end
}
