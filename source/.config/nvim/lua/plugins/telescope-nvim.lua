local tls   = require('telescope')
local tlsb  = require('telescope.builtin')
local tslu  = require('telescope.utils')
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
      truncate = 1
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
  pickers = {
    cwd     = tslu.buffer_dir(),
    hidden  = true,
    find_files = {
      find_command = { 'fd', '-tf', '-H', '-d10', '--strip-cwd-prefix' },
    },

    live_grep = {
      preview = {
        filesize_limit  = 0.3,
        timeout         = 100,
        hide_on_startup = false
      },
    },

    current_buffer_fuzzy_find = {
      preview = { hide_on_startup = false },
    }
  },

  extensions  = {
    ["zf-native"] = {
      file = {
        enable            = true,
        highlight_results = true,
        match_filename    = true,
      },
    },

    file_browser = {
      theme = 'dropdown',
      hijack_netrw = true
    },
  }
})

tls.load_extension('zf-native')
tls.load_extension('file_browser')


-- maps
F.nnmap('<leader>fb', ':Telescope file_browser<CR>')
F.nnmap('<leader>ff', ':Telescope find_files<CR>')
F.nnmap('<leader>fg', ':silent! Telescope git_files<CR>')
F.nnmap('<leader>fh', function() tlsb.find_files({ cwd = os.getenv('HOME') }) end)
F.nnmap('<leader>rg', ':Telescope live_grep<CR>')
F.nnmap('<leader>zf', ':Telescope current_buffer_fuzzy_find<CR>')
