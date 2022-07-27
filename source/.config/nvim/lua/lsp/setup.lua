local lspconfig = require('lspconfig')

local servers = {
  _1 = 'jdtls',
  _2 = 'perlnavigator',
  -- _2 = 'perlpls',
  _3 = 'sumneko_lua'
}
local configs  = {
  _2 = 'perl',
  _3 = 'lua'
}

for key, server in pairs(servers) do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local opts = {
    on_attach     = require('lsp.functions').on_attach,
    capabilities  = require('cmp_nvim_lsp').update_capabilities(capabilities)
  }

  if configs[key] then
    local config = require('lsp.server-config.' .. configs[key])
    vim.tbl_deep_extend('force', config, opts)
  end

  lspconfig[server].setup(opts)
end
