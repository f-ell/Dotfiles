local ok1, lspconfig  = pcall(require, 'lspconfig')
local ok2, mason      = pcall(require, 'mason')
if not ok1 or not ok2 then return end

mason.setup()

require('lsp.setup')

local std_server_setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn",  text = "" },
    { name = "DiagnosticSignHint",  text = "" },
    { name = "DiagnosticSignInfo",  text = "" },
  }
  for _, sign in pairs(signs) do
    vim.fn.sign_define(sign.name,
      { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    update_in_insert  = true,
    virtual_text      = false,
    underline         = false,
    severity_sort     = true,
    sign = {
      active = signs
    },
    float = {
      focusable = false,
      style  = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = ''
    }
  }
  vim.diagnostic.config(config)

  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
end
std_server_setup()
