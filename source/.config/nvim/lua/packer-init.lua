local ok, packer = pcall(require, 'packer')
if not ok then
  return
end

packer.init({
  ensure_dependencies = true,
  -- compile_path = '$XDG_DATA_HOME/nvim/site/pack/packer/packer_compiled.lua',
  auto_clean = false,
  display = {
    open_fn = function()
      return require('packer.util').float({border = 'rounded'})
    end
  }
})

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
        'williamboman/mason.nvim',
        ft = {'java', 'lua', 'perl'},
        cmd = {'Mason', 'MasonInstall', 'MasonUninstall'}
      },
      {
        'neovim/nvim-lspconfig',
        -- after = 'nvim-lsp-installer'
        after = 'mason.nvim'
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
        'hrsh7th/nvim-cmp',
        envent = 'VimEnter'
      },
      {
        'hrsh7th/cmp-nvim-lua',
        ft    = 'lua',
        after = 'nvim-cmp'
      },
      {
        'L3MON4D3/LuaSnip',
        after = 'nvim-cmp'
      },
      {
        'saadparwaiz1/cmp_luasnip',
        after = 'LuaSnip'
      },
      {
        'hrsh7th/cmp-buffer',
         after = 'cmp_luasnip',
         config = function()
           require('plugins.nvim-cmp')
         end
      }
    }


  -- LSP supplementary
    use {
      'folke/trouble.nvim',
      cmd    = 'TroubleToggle',
      config = function()
        require('plugins.trouble')
      end
    }


  -- Explorer
  use {
    'kyazdani42/nvim-tree.lua',
    cmd       = 'NvimTreeToggle',
    requires  = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('plugins.nvim-tree')
    end
  }


  -- Highlighting
    use {
      'nvim-treesitter/nvim-treesitter',
      run    = ':TSUpdate',
      event  = 'VimEnter',
      config = function()
        require('plugins.nvim-treesitter')
      end
    }


  -- Theming
    use 'sainnhe/everforest'
    -- use 'b4skyx/serenade'


  -- Markdown
    use {
      {
        'iamcco/markdown-preview.nvim',
        run = 'cd app && npm install',
        cmd = 'MarkdownPreview',
        config  = function()
          require('plugins.markdown-preview')
        end
      },
      {
        'dhruvasagar/vim-table-mode',
        cmd     = 'TableModeEnable',
        config  = function()
          require('plugins.vim-table-mode')
        end
      }
    }


  -- Miscellaneous
    use {
      {
        'terrortylor/nvim-comment',
        keys = {';', '<leader>;'}, -- consider loading on VimEnter
        config = function()
          require('plugins.nvim-comment')
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
          require('plugins.nvim-colorizer')
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
          require('plugins.presence')
        end
      }
    }
  end
)
