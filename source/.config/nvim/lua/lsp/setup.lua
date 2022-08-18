local F = require('utils.functions')
local lspconfig = require('lspconfig')

local servers = {
  _1 = 'jdtls',
  _2 = 'perlnavigator',
  _3 = 'sumneko_lua',
  _4 = 'texlab'
}

local configs  = {
  _2 = 'perl',
  _3 = 'lua'
}


local on_attach = function()
  F.o('signcolumn', 'yes:1')

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
    capabilities  = require('cmp_nvim_lsp').update_capabilities(capabilities)
  }

  if configs[key] then
    local config = require('lsp.server-config.' .. configs[key])
    vim.tbl_deep_extend('force', config, opts)
  end

  lspconfig[server].setup(opts)
end
