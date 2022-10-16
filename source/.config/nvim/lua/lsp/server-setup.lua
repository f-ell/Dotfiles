local lsp = require('lspconfig')
local F   = require('utils.functions')

local servers = {
  _1 = 'jdtls',
  _2 = 'perlpls', -- / perlnavigator
  _3 = 'sumneko_lua',
  _4 = 'texlab',
  _5 = 'tsserver' -- / quick_lint_js
}

local configs  = {
  _2 = 'perl',
  _3 = 'lua'
}


local on_attach = function()
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })

  F.nnmap('<leader>ds', vim.diagnostic.open_float,  {buffer = 0})
  F.nnmap('<leader>dj', vim.diagnostic.goto_next,   {buffer = 0})
  F.nnmap('<leader>dk', vim.diagnostic.goto_prev,   {buffer = 0})

  F.nnmap('<leader>lr', vim.lsp.buf.rename,     {buffer = 0})
  F.nnmap('<leader>ld', vim.lsp.buf.definition, {buffer = 0})
end


for key, server in pairs(servers) do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local opts = {
    on_attach     = on_attach,
    capabilities  = require('cmp_nvim_lsp').default_capabilities(capabilities)
  }

  if configs[key] then
    local config = require('lsp.server-config.' .. configs[key])
    vim.tbl_deep_extend('force', config, opts)
  end

  lsp[server].setup(opts)
end
