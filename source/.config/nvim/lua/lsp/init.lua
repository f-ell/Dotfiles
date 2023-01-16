local success1, _     = pcall(require, 'lspconfig')
local success2, mason = pcall(require, 'mason')
if not success1 or not success2 then return end

local v = vim

mason.setup()
require('lsp.setup')

local signs = {
  { name = 'DiagnosticSignError', text = 'E' }, -- 
  { name = 'DiagnosticSignWarn',  text = 'W' }, -- 
  { name = 'DiagnosticSignHint',  text = 'H' }, -- 
  { name = 'DiagnosticSignInfo',  text = 'I' }, -- 
}
for _, sign in pairs(signs) do
  v.fn.sign_define(sign.name,
    { texthl = sign.name, text = sign.text, numhl = '' })
end

v.diagnostic.config({
  update_in_insert  = true,
  underline         = true,
  virtual_text      = false,
  severity_sort     = true,

  sign = {
    active = signs
  },
  float = {
    focusable = false,
    source    = 'always',
    scope     = 'line',

    wrap      = true,
    wrap_at   = 72,
    max_width = 72,
    style     = 'minimal',
    border    = 'rounded',

    header = '',
    prefix = ''
  }
})

v.lsp.handlers['textDocument/hover'] =
  v.lsp.with(v.lsp.handlers.hover, { border = 'rounded' })
v.lsp.handlers['textDocument/signatureHelp'] =
  v.lsp.with(v.lsp.handlers.signature_help, { border = 'rounded' })
