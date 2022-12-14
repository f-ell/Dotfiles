local success1, _     = pcall(require, 'lspconfig')
local success2, mason = pcall(require, 'mason')
if not success1 or not success2 then return end

mason.setup()

require('lsp.setup')

local signs = {
  { name = 'DiagnosticSignError', text = 'E' }, -- 
  { name = 'DiagnosticSignWarn',  text = 'W' }, -- 
  { name = 'DiagnosticSignHint',  text = 'H' }, -- 
  { name = 'DiagnosticSignInfo',  text = 'I' }, -- 
}
for _, sign in pairs(signs) do
  vim.fn.sign_define(sign.name,
    { texthl = sign.name, text = sign.text, numhl = '' })
end

local config = {
  update_in_insert  = true,
  virtual_text      = false,
  underline         = true,
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
  vim.lsp.with(vim.lsp.handlers.hover,          { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] =
  vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
