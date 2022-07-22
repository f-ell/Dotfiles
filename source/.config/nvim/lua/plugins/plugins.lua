vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local ok, packer = pcall(require, 'packer')
if not ok then
  return
end

packer.init {
  ensure_dependencies = true,
  auto_clean = false,
  display = {
    open_fn = function()
      return require('packer.util').float { border = 'rounded' }
    end
  }
}

-- event = 'VimEnter' for anything that doesn't need to be loaded immediately
return packer.startup(
  function()
  -- Packer
    use 'wbthomason/packer.nvim'


  -- LSP and completion
  -- NEEDS CONFIGS
    use {
      {
        'neovim/nvim-lspconfig',
        -- ft = {'java', 'lua', 'perl'}
      },
      {
        'hrsh7th/cmp-nvim-lsp',
        -- ft = {'java', 'lua', 'perl'}
      },
      {
        'williamboman/nvim-lsp-installer',
        -- cmd = {'LspInstall', 'LspInstallInfo'},
      }
    }

    use 'hrsh7th/nvim-cmp'
    use {
      'hrsh7th/cmp-buffer',
      event = 'VimEnter'
    }
    use {
      'hrsh7th/cmp-nvim-lua',
      event = 'VimEnter'
    }
    use {
      'saadparwaiz1/cmp_luasnip',
      event = 'VimEnter'
    }
    use {
      'L3MON4D3/LuaSnip',
      -- after = 'nvim-cmp'
    }


  -- LSP supplementary
    use {
      'folke/trouble.nvim',
      cmd = 'TroubleToggle',
      config = function()
        require('plugins.plugin-config.trouble')
      end
    }


  -- Highlighting
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
    }


  -- Theming
    use 'nvim-lualine/lualine.nvim'
    use 'sainnhe/everforest'
    -- use 'b4skyx/serenade'


  -- Markdown
    use {
      {
        'preservim/vim-markdown',
        ft = {'markdown'},
        config = [[
          -- vimg('vim_markdown_no_default_keymappings', '1')
          -- vimg('vim_markdown_no_extensions_in_markdown', '1')
          -- vimg('vim_markdown_edit_url_in', 'vspilt')
          -- vimg('vim_markdown_toc_autofit', '1')
          -- vimg('vim_markdown_folding_disabled', '1')
          -- vimg('vim_markdown_folding_level', '6')
          -- vimg('vim_markdown_new_list_item_indent', '0')
          -- vimg('vim_markdown_emphasis_multiline', '0')
          -- vimg('vim_markdown_strikethrough', '1')
          -- vimg('vim_markdown_math', '1')
          -- vimg('vim_markdown_conceal_code_blocks', '0')
          -- vimg('tex_conceal', '')
          -- vimg('vim_markdown_frontmatter', '1')
          -- vimg('vim_markdown_toml_frontmatter', '1')
          -- vimg('vim_markdown_json_frontmatter', '1')
        ]]
      },
      {
        'iamcco/markdown-preview.nvim',
        run = 'cd app && yarn install',
        cmd = 'MarkdownPreview',
        config = [[
          vimg('mkdp_browser', 'qutebrowser')
        ]]
      },
      {
        'dhruvasagar/vim-table-mode',
        cmd     = 'TableModeEnable',
        config  = [[
          -- vimg('table_mode_relign_map', '<leader>tr'),
          -- vimg('table_mode_tableize_map', '<leader>tt'),
          -- vimg('table_mode_delete_row_map', '<leader>tdr'),
          -- vimg('table_mode_delete_column_map', '<leader>tdc'),
          -- vimg('table_mode_insert_column_before_map', '<leader>tic'),
          -- vimg('table_mode_insert_column_after_map', '<leader>tac'),
        ]]
      }
    }


  -- Other
    use {
      'andweeb/presence.nvim',
      event = 'VimEnter',
      config = function()
        require('plugins.plugin-config.presence')
      end
    }

    use {
      'mattn/emmet-vim',
      ft = {'html', 'css'}
    }
    use 'ap/vim-css-color'

    use {
      'tpope/vim-surround',
      event = 'VimEnter'
      -- keys = {'cs', 'ds', 'ys'} -- ds overloads dd
    }
    use {
      'terrortylor/nvim-comment',
      keys = {';', '<leader>;'},
      config = function()
        require('plugins.plugin-config.nvim-comment')
      end
    }
  end
)
