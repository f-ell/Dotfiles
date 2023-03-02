return {
  'williamboman/mason.nvim',
  lazy  = true,
  ft    = {
    'c', 'go', 'java', 'javascript', 'latex', 'lua', 'perl', 'plaintex',
    'rust', 'tex', 'typescript'
  },
  cmd           = { 'Mason', 'MasonInstall', 'MasonUninstall' },
  dependencies  = {
    'hrsh7th/cmp-nvim-lsp',
    'neovim/nvim-lspconfig'
  },
  config = function() require('lsp') end
}
