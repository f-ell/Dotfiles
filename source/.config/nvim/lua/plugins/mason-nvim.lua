return {
  'williamboman/mason.nvim',
  lazy = true,
  cmd = 'Mason',
  event = { 'BufNewFile', 'BufReadPost' },
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'neovim/nvim-lspconfig' },
  config = function()
    local v = vim
    local signs = {
      { 'DiagnosticSignError',  '◆' },
      { 'DiagnosticSignWarn',   '▲' },
      { 'DiagnosticSignInfo',   '●' },
      { 'DiagnosticSignHint',   '▪' }
    }
    for _, sign in pairs(signs) do
      v.fn.sign_define(sign[1], { texthl = sign[1], text = sign[2] })
    end

    v.diagnostic.config({
      update_in_insert  = true,
      underline         = true,
      virtual_text      = false,
      severity_sort     = true,
      sign = { active = signs }
    })

    v.lsp.handlers['textDocument/hover'] = v.lsp.with(v.lsp.handlers.hover, { border = 'single' })
    v.lsp.handlers['textDocument/signatureHelp'] = v.lsp.with(v.lsp.handlers.signature_help, { border = 'single' })

    require('mason').setup({ ui = { border = 'single' } })
    require('lsp.setup')
  end
}
