vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local packer = require('packer')

packer.init {
  ensure_dependencies = true,
  auto_clean = false,
  autoremove = false,
  display = {
    open_fn = function()
      return require('packer.util').float { border = 'rounded' }
    end
  }
}

-- cmd = {'LspInstall', 'LspInstallInfo'} for nvim-lsp-installer
-- event = 'VimEnter' for anything that doesn't need to be loaded immediately
return packer.startup(
  function()
  -- Packer
    use 'wbthomason/packer.nvim'


  -- LSP and completion
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'

    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'
    use 'saadparwaiz1/cmp_luasnip'

    use {
      'L3MON4D3/LuaSnip',
      -- after = 'nvim-cmp'
    }
    -- use 'rafamadriz/friendly-snippets'


  -- LSP supplementary
    use 'folke/trouble.nvim'


  -- Highlighting
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate'
    }


  -- Theming
    use 'nvim-lualine/lualine.nvim'
    use 'sainnhe/everforest'
    -- use 'b4skyx/serenade'


  -- Markdown
    use {
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
    }
    use {
      'iamcco/markdown-preview.nvim',
      run = 'cd app && yarn install',
      ft  = {'markdown'},
      cmd = 'MarkdownPreview',
      config = [[
        vimg('mkdp_browser', 'qutebrowser')
      ]]
    }
    use {
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


  -- Other
    use 'andweeb/presence.nvim'

    use 'mattn/emmet-vim'
    use 'ap/vim-css-color'

    use 'tpope/vim-surround'
    use 'terrortylor/nvim-comment'
  end
)
