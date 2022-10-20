local tls   = require('telescope')
local tlsal = require('telescope.actions.layout')

tls.setup({
  defaults = {
    initial_mode      = 'insert',
    vimgrep_arguments = {
      'rg', '--color=never', '--no-heading', '--with-filename', '--column',
      '--smart-case'
    },
    path_display      = {
      shorten = {
        len = 1, exclude = {-2, -1, 1}
      },
      truncate
    },

    sorting_strategy  = 'descending',
    scroll_strategy   = 'limit',
    layout_strategy   = 'horizontal',
    prompt_prefix     = ' ',
    entry_prefix      = '  ',
    selection_caret   = '> ',
    winblend          = 0,

    results_title     = 'Files',
    prompt_title      = 'Query String',
    preview = {
      filesize_limit  = 0.3,
      timeout         = 100,
      hide_on_startup = true
    },
    color_devicons    = true,

    file_ignore_patterns = {
      "undo/"
    },

    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-p>'] = tlsal.toggle_preview,
        ['<CR>']  = 'select_default',
        ['<C-s>'] = 'select_horizontal',
        ['<C-v>'] = 'select_vertical',
        ['<C-t>'] = 'select_tab',
        ['<C-c>'] = 'close',
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
        ['<C-b>'] = 'preview_scrolling_up',
        ['<C-f>'] = 'preview_scrolling_down',
      },
      n = {
        ['<C-p>'] = tlsal.toggle_preview,
        ['<CR>']  = 'select_default',
        ['<C-s>'] = 'select_horizontal',
        ['<C-v>'] = 'select_vertical',
        ['<C-t>'] = 'select_tab',
        ['<C-c>'] = 'close',
        ['j']     = 'move_selection_next',
        ['k']     = 'move_selection_previous',
        ['gg']    = 'move_to_top',
        ['G']     = 'move_to_bottom',
        ['M']     = 'move_to_middle',
        ['<C-b>'] = 'preview_scrolling_up',
        ['<C-f>'] = 'preview_scrolling_down',
      }
    }
  },
  pickers     = {
    find_files = {
      find_command  = {
        'fd', '-tf', '-H', '-d10', '--strip-cwd-prefix'
      },

      mappings = {
        n = {
          ["cd"] = function(prompt_bufnr)
            local sel = require("telescope.actions.state").get_selected_entry()
            local dir = vim.fn.fnamemodify(sel.path, ":p:h")
            require("telescope.actions").close(prompt_bufnr)
            vim.cmd('silent lcd '..dir)
          end
        }
      }
    },

    live_grep = {
      preview = {
        filesize_limit  = 0.3,
        timeout         = 100,
        hide_on_startup = false
      },
    }
  },
  extensions  = {},
})
tls.load_extension('zf-native')
