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
    use {
      {
        'neovim/nvim-lspconfig',
        -- ft = {'java', 'lua', 'perl'},
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
        config = function()
          require('plugins.plugin-config.vim-markdown')
        end
      },
      {
        'iamcco/markdown-preview.nvim',
        run = 'cd app && yarn install',
        cmd = 'MarkdownPreview',
        config = function()
          require('plugins.plugin-config.markdown-preview')
        end
      },
      {
        'dhruvasagar/vim-table-mode',
        cmd     = 'TableModeEnable',
        config  = function()
          require('plugins.plugin-config.vim-table-mode')
        end
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
