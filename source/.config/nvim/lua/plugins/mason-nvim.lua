return {
  'williamboman/mason.nvim',
  lazy = true,
  cmd = 'Mason',
  event = { 'BufNewFile', 'BufReadPost' },
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'neovim/nvim-lspconfig' },
  config = function()
    local signs = {
      { 'DiagnosticSignError',  '◆' },
      { 'DiagnosticSignWarn',   '▲' },
      { 'DiagnosticSignInfo',   '●' },
      { 'DiagnosticSignHint',   '▪' }
    }
    for _, sign in pairs(signs) do
      vim.fn.sign_define(sign[1], { texthl = sign[1], text = sign[2] })
    end

    vim.diagnostic.config({
      update_in_insert = true,
      underline = true,
      virtual_text = false,
      severity_sort = true,
      sign = { active = signs }
    })

    vim.lsp.handlers['textDocument/hover'] =
      vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
    vim.lsp.handlers['textDocument/signatureHelp'] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })

    require('mason').setup({ ui = { border = 'single' } })
    require('lsp.setup')
  end
}
