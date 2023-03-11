local success1, _     = pcall(require, 'lspconfig')
local success2, mason = pcall(require, 'mason')
if not success1 or not success2 then return end

local v = vim

mason.setup()
require('lsp.setup')

local signs = {
  { 'DiagnosticSignError',  'E' }, -- 
  { 'DiagnosticSignWarn',   'W' }, -- 
  { 'DiagnosticSignHint',   'H' }, -- 
  { 'DiagnosticSignInfo',   'I' }, -- 
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

v.lsp.handlers['textDocument/hover']          = v.lsp.with(v.lsp.handlers.hover,          { border = 'rounded' })
v.lsp.handlers['textDocument/signatureHelp']  = v.lsp.with(v.lsp.handlers.signature_help, { border = 'rounded' })
