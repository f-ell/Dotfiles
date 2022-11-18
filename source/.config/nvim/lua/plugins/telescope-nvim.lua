local tls   = require('telescope')
local tlsal = require('telescope.actions.layout')
local F     = require('utils.functions')

tls.setup({
  defaults = {
    initial_mode      = 'insert',
    vimgrep_arguments = {
      'rg', '--color=never', '--no-heading', '--with-filename', '--column',
      '--smart-case'
    },
    path_display = {
      shorten = {
        len = 1, exclude = {-2, -1, 1}
      },
      truncate
    },

    sorting_strategy  = 'descending',
    scroll_strategy   = 'limit',

    layout_strategy   = 'vertical',
    theme = 'dropdown',
    layout_config     = {
      prompt_position = 'bottom',
      width   = 0.80,
      height  = 0.70,
      horizontal = {
        preview_width = 0.65,
        results_width = 0.3,
      },
      vertical = {
        preview_height = 0.45,
        mirror = false,
      },
      preview_cutoff = 12
    },

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
    },

    live_grep = {
      preview = {
        filesize_limit  = 0.3,
        timeout         = 100,
        hide_on_startup = false
      },
    },

    current_buffer_fuzzy_find = {
      preview = {
        hide_on_startup = false
      },
    }
  },
  extensions  = {},
})

tls.load_extension('zf-native')


-- maps
F.nnmap('<leader>f',  ':Telescope find_files<CR>')
F.nnmap('<leader>tg', ':silent! Telescope git_files<CR>')
F.nnmap('<leader>tr', ':Telescope live_grep<CR>')
F.nnmap('<leader>tf', ':Telescope current_buffer_fuzzy_find<CR>')
