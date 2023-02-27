local lsp = require('lspconfig')
local key = require('utils.lib').key
local cda = require('lsp.codeaction')
local def = require('lsp.definition')
local dgn = require('lsp.diag')
local rnm = require('lsp.rename')
local v   = vim
local servers = {
  _1 = 'clangd',
  _2 = 'gopls',
  _3 = 'jdtls',
  _4 = 'perlpls',
  _5 = 'pylsp',
  _6 = 'rust_analyzer',
  _7 = 'lua_ls',
  _8 = 'texlab',
  _9 = 'tsserver'
}

local configs  = {
  _2 = 'go',
  _4 = 'perl',
  _6 = 'rust',
  _7 = 'lua'
}


local on_attach = function()
  key.nnmap('gd', def.peek,               { buffer = 0 })
  key.nnmap('<leader>gd', def.open,       { buffer = 0 })
  key.nnmap('K', v.lsp.buf.hover,         { buffer = 0 })
  key.nnmap('<leader>ca', cda.codeaction, { buffer = 0 })
  key.nnmap('<leader>rn', rnm.rename,     { buffer = 0 })

  key.nnmap('<leader>h', dgn.get_line,  { buffer = 0 })
  key.nnmap('<leader>j', dgn.goto_next, { buffer = 0 })
  key.nnmap('<leader>k', dgn.goto_prev, { buffer = 0 })
  key.nnmap('<leader>l', function()
    require('telescope')
    v.cmd('silent! Telescope diagnostics')
  end)
end


for idx, server in pairs(servers) do
  local capabilities = v.lsp.protocol.make_client_capabilities()
  local opts = {
    on_attach     = on_attach,
    capabilities  = require('cmp_nvim_lsp').default_capabilities(capabilities)
  }

  if configs[idx] then
    local config = require('lsp.servers.' .. configs[idx])
    v.tbl_deep_extend('force', config, opts)
  end

  lsp[server].setup(opts)
end
