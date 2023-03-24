local lsp = require('lspconfig')
local key = require('utils.lib').key
local ui  = require('lsp.ui')
local v   = vim

local servers = {
  'clangd',
  'gopls',
  'jdtls',
  'lua_ls',
  'perlpls',
  'pylsp',
  'rust_analyzer',
  'texlab',
  'tsserver'
}

local on_attach = function()
  key.nnmap('gd',         ui.def.peek,          { buffer = 0 })
  key.nnmap('<leader>gd', ui.def.open,          { buffer = 0 })
  key.nnmap('K',          v.lsp.buf.hover,      { buffer = 0 })
  key.nnmap('<leader>ca', ui.cda.codeaction,    { buffer = 0 })
  key.nnmap('<leader>rf', v.lsp.buf.references, { buffer = 0 })
  key.nnmap('<leader>rn', ui.ren.rename,        { buffer = 0 })

  key.nnmap('<leader>h', ui.dgn.get_line,   { buffer = 0 })
  key.nnmap('<leader>j', ui.dgn.goto_next,  { buffer = 0 })
  key.nnmap('<leader>k', ui.dgn.goto_prev,  { buffer = 0 })
  key.nnmap('<leader>l', function()
    require('telescope.builtin').diagnostics({ bufnr = 0 })
  end)
end
local capabilities = require('cmp_nvim_lsp')
  .default_capabilities(v.lsp.protocol.make_client_capabilities())

for i = 1, #servers do
  local opts = { on_attach = on_attach, capabilities = capabilities }

  local req, tbl = pcall(require, 'lsp.servers.'..servers[i])
  if req then opts = v.tbl_deep_extend('force', opts, tbl) end
  lsp[servers[i]].setup(opts)
end
