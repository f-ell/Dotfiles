require('nvim-tree').setup({
  -- disable_netrw = false,
  -- hijack_netrw  = true,
  -- hijack_directories = true,
  sort_by    = 'name',

  view = {
    hide_root_folder = false,
    side    = 'left',
    width   = 30,
    height  = 30,
    number          = true,
    relativenumber  = true,
    signcolumn      = 'no',
    mappings = {
      custom_only = false,
      list = {}
    }
  },

  renderer = {
    highlight_opened_files = 'name',
    indent_markers = {
      enable  = true,
      icons   = {
            corner  = "└",
            edge    = "│",
            item    = "│",
            none    = " ",
      }
    }
  },

  diagnostics = {
    enable  = true,
    icons   = {
          hint    = "",
          info    = "",
          warning = "",
          error   = "",
    }
  },

  filters = {
    dotfiles = false
  }
})
