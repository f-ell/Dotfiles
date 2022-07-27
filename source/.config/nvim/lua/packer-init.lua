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

return packer.startup(
  function()
  -- Packer
    use {
      'wbthomason/packer.nvim',
      opt = false,
      cmd = {
        'PackerClean',          'PackerCompile',  'PackerInstall',
        'PackerLoad',           'PackerProfile',  'PackerSnapshot',
        'PackerSnapshotDelete', 'PackerRollback', 'PackerStatus',
        'PackerSync',           'PackerUpdate'
      }
    }


  -- LSP and completion
    use {
      {
        'williamboman/nvim-lsp-installer',
        ft = {'java', 'lua', 'perl'}
      },
      {
        'neovim/nvim-lspconfig',
        after = 'nvim-lsp-installer'
      },
      {
        'hrsh7th/cmp-nvim-lsp',
        after   = 'nvim-lspconfig',
        config  = function()
          require('lsp')
        end
      }
    }
    use {
      {
        'L3MON4D3/LuaSnip',
        event = 'VimEnter'
      },

--      {
--        'hrsh7th/cmp-nvim-lua',
--        ft    = 'lua',
--        after = 'LuaSnip'
--      },

      {
        'hrsh7th/nvim-cmp',
        after = 'LuaSnip'
      },
      {
        'saadparwaiz1/cmp_luasnip',
        after = 'nvim-cmp'
      },
      {
        'hrsh7th/cmp-buffer',
         after = 'cmp_luasnip',
         config = function()
           require('cmp-init')
         end
      }
    }


  -- LSP supplementary
    use {
      'folke/trouble.nvim',
      cmd    = 'TroubleToggle',
      config = function()
        require('plugin-config.trouble')
      end
    }


  -- Explorer
  use {
    'kyazdani42/nvim-tree.lua',
    cmd       = 'NvimTreeToggle',
    requires  = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('plugin-config.nvim-tree')
    end
  }


  -- Highlighting
    use {
      'nvim-treesitter/nvim-treesitter',
      run    = ':TSUpdate',
      event  = 'VimEnter',
      config = function()
        require('plugin-config.nvim-treesitter')
      end
    }


  -- Theming
    use {
      {
        'sainnhe/everforest',
      },
      {
        'nvim-lualine/lualine.nvim',
        after = 'everforest',
        config = function()
          require('plugin-config.lualine')
        end
      }
    }
    -- use 'b4skyx/serenade'


  -- Markdown
    use {
      {
        'preservim/vim-markdown',
        ft     = 'markdown',
        config = function()
          require('plugin-config.vim-markdown')
        end
      },
      {
        'iamcco/markdown-preview.nvim',
        run = 'cd app && yarn install',
        cmd = 'MarkdownPreview',
        config = function()
          require('plugin-config.markdown-preview')
        end
      },
      {
        'dhruvasagar/vim-table-mode',
        cmd     = 'TableModeEnable',
        config  = function()
          require('plugin-config.vim-table-mode')
        end
      }
    }


  -- Other
    use {
      {
        'terrortylor/nvim-comment',
        keys = {';', '<leader>;'},
        config = function()
          require('plugin-config.nvim-comment')
        end
      },
      {
        'tpope/vim-surround',
        event = 'VimEnter'
        -- keys = {'cs', 'ds', 'ys'} -- ds overloads dd
      },
      {
        'norcalli/nvim-colorizer.lua',
        event  = 'VimEnter',
        config = function()
          require('plugin-config.nvim-colorizer')
        end
      },
      {
        'mattn/emmet-vim',
        ft = 'html'
      },
      {
        'kyazdani42/nvim-web-devicons',
        event  = 'VimEnter',
        config = function()
          require('nvim-web-devicons').setup()
        end
      },
      {
        'andweeb/presence.nvim',
        event  = 'VimEnter',
        config = function()
          require('plugin-config.presence')
        end
      }
    }
  end
)
