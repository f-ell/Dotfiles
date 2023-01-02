return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  dependencies = {
    'natecraddock/telescope-zf-native.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    { 'kyazdani42/nvim-web-devicons', lazy = true, config = true }
  },
  init = function()
    if vim.fn.argc() > 0 then
      local stat = vim.loop.fs_stat(vim.fn.argv()[1])
      if stat ~= nil and stat.type == 'directory' then
        require('telescope')
      end
    end
  end,
  keys = {
    { '<leader>fb', '<CMD>Telescope file_browser<CR>' },
    { '<leader>ff', '<CMD>Telescope find_files<CR>' },
    { '<leader>fg', '<CMD>silent! Telescope git_files<CR>' },
    { '<leader>fh', function()
      require('telescope.builtin').find_files({ cwd = os.getenv('HOME') })
    end },
    { '<leader>rg', '<CMD>Telescope live_grep<CR>' },
    { '<leader>zf', '<CMD>Telescope current_buffer_fuzzy_find<CR>' }
  },
  config = function()
    local tls   = require('telescope')
    local tslu  = require('telescope.utils')
    local tlsal = require('telescope.actions.layout')

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
            ['<CR>']  = 'select_default',
            ['<C-s>'] = 'select_horizontal',
            ['<C-v>'] = 'select_vertical',
            ['<C-t>'] = 'select_tab',
            ['<C-c>'] = 'close',
            ['<C-j>'] = 'move_selection_next',
            ['<C-k>'] = 'move_selection_previous',
            ['<C-b>'] = 'results_scrolling_up',
            ['<C-f>'] = 'results_scrolling_down',
            ['<C-p>'] = tlsal.toggle_preview,
            ['<C-u>'] = 'preview_scrolling_up',
            ['<C-d>'] = 'preview_scrolling_down',
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
            ['<C-b>'] = 'results_scrolling_up',
            ['<C-f>'] = 'results_scrolling_down',
            ['<C-p>'] = tlsal.toggle_preview,
            ['<C-u>'] = 'preview_scrolling_up',
            ['<C-d>'] = 'preview_scrolling_down',
            ['gg']    = 'move_to_top',
            ['G']     = 'move_to_bottom',
            ['M']     = 'move_to_middle',
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
          initial_mode  = 'normal',
          theme         = 'dropdown',
          hidden        = true,
          hijack_netrw  = true
        },
      }
    })

    tls.load_extension('zf-native')
    tls.load_extension('file_browser')
  end
}
