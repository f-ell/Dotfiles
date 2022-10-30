local success, packer = pcall(require, 'packer')
if not success then return end

packer.init({
  ensure_dependencies = true,
  -- compile_path = os.getenv('XDG_DATA_HOME')..'/nvim/site/pack/packer/packer_compiled.lua',
  auto_clean = false,
  display = {
    open_fn = function()
      return require('packer.util').float({border = 'rounded'})
    end
  }
})

return packer.startup(function()
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
      ft  = {
        'java', 'javascript', 'latex', 'lua', 'perl', 'plaintex', 'python',
        'tex', 'typescript'
      },
      cmd = {'Mason', 'MasonInstall', 'MasonUninstall'}
    },
    {
      'neovim/nvim-lspconfig',
      after = 'mason.nvim'
    },
    {
      'glepnir/lspsaga.nvim',
      after = 'nvim-lspconfig',
      config = function()
        require('plugins.lspsaga-nvim')
      end
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
    -- {
    --   'hrsh7th/cmp-omni',
    --   ft    = {'latex', 'plaintex', 'tex'},
    --   after = 'nvim-cmp'
    -- },
    {
      'L3MON4D3/LuaSnip',
      after = 'nvim-cmp',
      config = function()
        require('plugins.luasnip')
      end
    },
    {
      'saadparwaiz1/cmp_luasnip',
      after = 'LuaSnip'
    },
    {
      'hrsh7th/cmp-buffer',
       after = 'nvim-cmp',
       config = function()
         require('plugins.nvim-cmp')
       end
    }
  }


  -- Telescope
  use 'nvim-lua/plenary.nvim'
  use 'natecraddock/telescope-zf-native.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    event     = 'VimEnter',
    requires  = {
      'nvim-lua/plenary.nvim',
      'natecraddock/telescope-zf-native.nvim'
    },
    config    = function()
      require('plugins.telescope-nvim')
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


  -- Miscellaneous
  use {
    {
      'lewis6991/gitsigns.nvim',
      event = 'VimEnter',
      config = function()
        require('plugins.gitsigns-nvim')
      end
    },
    {
      'terrortylor/nvim-comment',
      event = 'VimEnter',
      config = function()
        require('plugins.nvim-comment')
      end
    },
    {
      'echasnovski/mini.surround',
      event = 'VimEnter',
      config = function()
        require('plugins.mini-surround')
      end
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
  }


  -- Markdown
  use {
    {
      'iamcco/markdown-preview.nvim',
      run = 'cd app && npm install',
      -- cmd = 'MarkdownPreview',
      ft = {'md', 'markdown'},
      config  = function()
        require('plugins.markdown-preview-nvim')
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


  -- Latex
  -- compilation with tectonic, texlab for snippets
  use {
    'lervag/vimtex',
    ft      = {'latex', 'plaintex', 'tex'},
    config  = function()
      require('plugins.vimtex')
    end
  }
end)
