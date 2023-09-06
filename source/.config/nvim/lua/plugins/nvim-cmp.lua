return {
  'hrsh7th/nvim-cmp',
  lazy = true,
  priority = 1000,
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-buffer',
    'L3MON4D3/LuaSnip',
    { 'hrsh7th/cmp-cmdline', event = 'CmdlineEnter' }
  },
  config = function()
    local icons = {
      Class       = '', Color    = '', Constructor   = '', Enum      = '',
      EnumMember  = '', Event    = '', Field         = '', File      = '',
      Folder      = '', Function = '', Interface     = '', Keyword   = '',
      Method      = 'm', Module   = '', Property      = '', Reference = '',
      Snippet     = '', Text     = '', TypeParameter = '', Unit      = '',
      Constant    = '', Struct   = '', Operator      = '', Value     = '',
      Variable    = ''
    }
    local window_opts = {
      border = 'single',
      winhighlight = 'FloatBorder:FloatBorder',
      side_padding = 1,
      col_offset = 1
    }

    local cmp = require('cmp')
    cmp.setup({
      enabled = function()
        local context = require('cmp.config.context')
        return not context.in_treesitter_capture('comment')
          and not context.in_syntax_group('Comment')
      end,

      matching = {
        disallow_partial_matching = true,
        disallow_prefix_unmatching = true,
        disallow_fuzzy_matching = false,
        disallow_full_fuzzy_matching = false,
        disallow_partial_fuzzy_matching = true
      },

      snippet = {
        expand = function(arg) require('luasnip').lsp_expand(arg.body) end
      },

      sources = {
        { name = 'luasnip',
          max_item_count = 4,
          keyword_length = 1 },
        { name = 'nvim_lsp',
          keyword_length = 1 },
        { name = 'buffer',
          max_item_count = 4,
          keyword_length = 4,
          option = {
            get_bufnrs = function()
              local buf = vim.api.nvim_get_current_buf()
              local byte_size =
                vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
              if byte_size > 1024 * 1024 then return {} end -- 1 MiB max
              return { buf }
            end
          }
        }
      },

      window = { completion = window_opts, documentation = window_opts },
      view = { entries = { name = 'custom', selection_order = 'near_cursor' } },

      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, item)
          item.abbr = entry.source.name == 'cmdline'
            and item.abbr
            or string.sub(item.abbr, 1, 24)
          item.kind = string.format('%s', icons[item.kind])
          item.menu = ({
            luasnip   = '-Snp-',
            nvim_lsp  = '-Lsp-',
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
