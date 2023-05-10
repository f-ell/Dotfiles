return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  keys = {
    { '<leader>b',  '<CMD>Telescope buffers<CR>' },
    { '<leader>u',  '<CMD>Telescope undo<CR>' },
    { '<leader>ff', '<CMD>Telescope find_files<CR>' },
    { '<leader>fg', '<CMD>silent! Telescope git_files<CR>' },
    { '<leader>fp', function() require('telescope.builtin').find_files({ cwd = '..' }) end },
    { '<leader>rg', '<CMD>Telescope live_grep<CR>' },
    { '<leader>zf', '<CMD>Telescope current_buffer_fuzzy_find<CR>' }
  },
  dependencies = {
    'debugloop/telescope-undo.nvim',
    'natecraddock/telescope-zf-native.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons'
  },
  config = function()
    local tls   = require('telescope')
    local tslu  = require('telescope.utils')
    local tlsal = require('telescope.actions.layout')

    tls.setup({
      defaults = {
        initial_mode = 'normal',
        path_display = {
          shorten = { len = 1, exclude = {-2, -1, 1} },
          truncate = 1,
          vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '-H',
            '--column', '-n', '-S', '--hidden', '--max-depth', '8'
          }
        },

        sorting_strategy  = 'descending',
        scroll_strategy   = 'limit',
        file_ignore_patterns = { '.cache/', 'undo/' },

        borderchars       = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
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
        preview = {
          filesize_limit  = 0.3,
          timeout         = 100,
          hide_on_startup = true
        },
        color_devicons    = true,

        mappings = {
          i = {
            ['<CR>']  = 'select_default',
            ['<C-s>'] = 'select_horizontal',
            ['<C-v>'] = 'select_vertical',
            ['<C-t>'] = 'select_tab',
            ['<C-c>'] = 'close',
            ['<C-j>'] = 'move_selection_next',
            ['<C-k>'] = 'move_selection_previous',
            ['<C-p>'] = tlsal.toggle_preview,
            ['<C-b>'] = 'preview_scrolling_up',
            ['<C-f>'] = 'preview_scrolling_down',
            ['<C-u>'] = false,
            ['<C-d>'] = false
          },
          n = {
            ['<ESC>'] = false,
            ['<CR>']  = 'select_default',
            ['<C-s>'] = 'select_horizontal',
            ['<C-v>'] = 'select_vertical',
            ['<C-t>'] = 'select_tab',
            ['<C-c>'] = 'close',
            ['j']     = 'move_selection_next',
            ['k']     = 'move_selection_previous',
            ['gg']    = 'move_to_top',
            ['G']     = 'move_to_bottom',
            ['<C-p>'] = tlsal.toggle_preview,
            ['<C-b>'] = 'preview_scrolling_up',
            ['<C-f>'] = 'preview_scrolling_down',
            ['<C-u>'] = false,
            ['<C-d>'] = false
          }
        }
      },
      pickers = {
        cwd     = tslu.buffer_dir(),
        hidden  = true,

        buffers = {
          initial_mode  = 'insert',
          results_title = false,
          ignore_current_buffer = true
        },

        find_files = {
          initial_mode  = 'insert',
          results_title = false,
          find_command  = { 'fd', '-tf', '-H', '-d10', '--strip-cwd-prefix' },
        },
        git_files = {
          initial_mode = 'insert',
          results_title = false
        },

        live_grep = {
          initial_mode = 'insert',
          preview = {
            filesize_limit  = 0.3,
            timeout         = 100,
            hide_on_startup = false
          },
        },

        current_buffer_fuzzy_find = {
          initial_mode  = 'insert',
          results_title = false,
          skip_empty_lines = true
        }
      },

      extensions  = {
        ['zf-native'] = {
          file = {
            enable            = true,
            highlight_results = true,
            match_filename    = true
          },
          generic = {
            enable            = true,
            highlight_results = true,
            match_filename    = true
          }
        },

        undo = {}
      }
    })

    tls.load_extension('zf-native')
    tls.load_extension('undo')
  end
}
