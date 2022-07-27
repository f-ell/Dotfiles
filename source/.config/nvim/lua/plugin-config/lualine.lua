local function icon()
  return ''
end

require('lualine').setup({
  options = {
    theme = 'everforest',
    icons_enabled = false,

    section_separators = {
      left = '', right = ''
    },
    component_separators = {
      left = '', right = ''
    },

    globalstatus = true
  },

  sections = {
    lualine_a = {icon},
    lualine_b = {'mode'},
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 0,
        symbols = {
          modified = '+',
          readonly = '-',
          unnamed = 'Unnamed'
        }
      }
    },
    lualine_x = {
      {
        'diagnostics',
        colored = true,
        sources = {'nvim_lsp', 'nvim_diagnostic'},
        sections = {'warn', 'error'},
        update_in_insert = true,
        always_visible = false
      }
    },
    lualine_y = {
      {
        'filetype',
        colored = false,
      }
    },
    lualine_z = {'location'}
  }
})
