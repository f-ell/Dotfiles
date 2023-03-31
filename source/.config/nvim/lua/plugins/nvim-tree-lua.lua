return {
  'nvim-tree/nvim-tree.lua',
  lazy = true,
  dependencies = 'nvim-tree/nvim-web-devicons',
  keys = { { '<leader>e', '<CMD>NvimTreeToggle<CR>' } },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NvimTreeSetup',
      once = true,
      callback = function()
        vim.defer_fn(function()
          vim.cmd({ cmd = 'source', args = { vim.fn.stdpath('config')..'/lua/utils/highlights.lua' } })
        end, 100)
      end
    })
  end,
  config = function()
    require('nvim-tree').setup({
      live_filter = { always_show_folders = false },
      view = { side = 'left', width = 32, preserve_window_proportions = true },

      auto_reload_on_write  = true,
      sync_root_with_cwd    = true,
      update_focused_file   = { enable = true },

      modified    = { enable = true, show_on_dirs = false },
      git         = { enable = true, show_on_dirs = false, ignore = false },
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        debounce_delay = 200,
        icons = { info = 'I',  hint = 'H', warning = 'W', error = 'E' }
      },

      renderer = {
        full_name     = true,
        add_trailing  = true,
        group_empty   = true,
        highlight_modified = 'name',
        root_folder_label = function(root_cwd)
          local split, str = vim.fn.split(root_cwd, '/'), ''
          if split[1] and split[1] == 'home' and #split > 1 then
            table.remove(split, 1); table.remove(split, 1)
            str = '~'
          end
          local cwd = table.remove(split)
          for _, dir in pairs(split) do str = str..'/'..dir:sub(0, 1) end
          return str..'/'..(cwd or '')
        end,
        indent_markers = { enable = true },
        icons = {
          webdev_colors = true,
          git_placement = 'after',
          symlink_arrow = '  ',
          show = { file = true, folder = true, git = true, modified = false },
          glyphs = {
            default = '', symlink = '➜',
            folder = {
              arrow_closed  = '', arrow_open   = '',
              default       = '', open         = '',
              empty         = '', empty_open   = '',
              symlink       = '', symlink_open = '',
            },
            git = {
              untracked = '?', unstaged = 'M', staged   = 'A',
              unmerged  = 'U', deleted  = 'R', ignored  = 'X',
            }
          }
        }
      },

      on_attach = function(bufnr)
        local L = require('utils.lib')
        local a = require('nvim-tree.api')
        L.key.nnmap(',', function() a.tree.change_root_to_node() end,   { buffer = bufnr })
        L.key.nnmap(';', function() a.tree.change_root_to_parent() end, { buffer = bufnr })
        L.key.nnmap('.', function() a.tree.toggle_hidden_filter() end,  { buffer = bufnr })

        L.key.nnmap('<CR>',   function() a.node.open.edit() end,        { buffer = bufnr })
        L.key.nnmap('<TAB>',  function() a.node.open.preview() end,     { buffer = bufnr })
        L.key.nnmap('<C-t>',  function() a.node.open.tab() end,         { buffer = bufnr })
        L.key.nnmap('<C-v>',  function() a.node.open.vertical() end,    { buffer = bufnr })
        L.key.nnmap('<C-h>',  function() a.node.open.horizontal() end,  { buffer = bufnr })

        L.key.nnmap('/',      function() a.live_filter.start() end, { buffer = bufnr })
        L.key.nnmap('<C-l>',  function() a.live_filter.clear() end, { buffer = bufnr })

        L.key.nnmap('c', function() a.fs.create() end,  { buffer = bufnr })
        L.key.nnmap('d', function() a.fs.remove() end,  { buffer = bufnr })
        L.key.nnmap('x', function() a.fs.cut() end,     { buffer = bufnr })
        L.key.nnmap('p', function() a.fs.paste() end,   { buffer = bufnr })
        L.key.nnmap('r', function() a.fs.rename() end,  { buffer = bufnr })
      end
    })
  end
}
