return {
  'williamboman/mason.nvim',
  lazy = true,
  cmd = 'Mason',
  event = 'FileType',
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

    local key = require('utils.lib').key
    local ui = require('lsp.ui')
    local on_attach = function()
      key.nnmap('gd',         ui.def.peek, { buffer = 0 })
      key.nnmap('<leader>gt', ui.def.type, { buffer = 0 })
      key.nnmap('<leader>gd', ui.def.open, { buffer = 0 })
      key.nnmap('K',          vim.lsp.buf.hover, { buffer = 0 })
      key.nnmap('<leader>ca', ui.cda.codeaction, { buffer = 0 })
      key.nnmap('<leader>rf', vim.lsp.buf.references, { buffer = 0 })
      key.nnmap('<leader>rn', ui.ren.rename, { buffer = 0 })

      key.nnmap('<leader>h', ui.dgn.get_line, { buffer = 0 })
      key.nnmap('<leader>j', ui.dgn.goto_next, { buffer = 0 })
      key.nnmap('<leader>k', ui.dgn.goto_prev, { buffer = 0 })
      key.nnmap('<leader>l', function()
        require('telescope.builtin').diagnostics({ bufnr = 0 })
      end)
    end

    local capabilities = require('cmp_nvim_lsp')
    .default_capabilities(vim.lsp.protocol.make_client_capabilities())

    for _, server in pairs(vim.fn.readdir(vim.fn.stdpath('config')..'/lua/lsp/servers')) do
      local opts = { on_attach = on_attach, capabilities = capabilities }
      server = server:gsub('%.lua$', '')

      local req, tbl = pcall(require, 'lsp.servers.'..server)
      if req then opts = vim.tbl_deep_extend('force', opts, tbl) end
      require('lspconfig')[server].setup(opts)
    end
  end
}
