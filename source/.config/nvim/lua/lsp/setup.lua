local lsp = require('lspconfig')
local F   = require('utils.functions')
local dgn = require('lsp.diag')
local def = require('lsp.definition')
local rnm = require('lsp.rename')
local v   = vim

local servers = {
  _1 = 'clangd',
  _2 = 'gopls',
  _3 = 'jdtls',
  _4 = 'perlpls',
  _5 = 'pylsp',
  _6 = 'rust_analyzer',
  _7 = 'sumneko_lua',
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
  F.nnmap('<leader>gd', 'gd')

  F.nnmap('gd', def.peek,           { buffer = 0 })
  F.nnmap('K',  v.lsp.buf.hover,    { buffer = 0 })
  F.nnmap('<leader>ca', v.lsp.buf.code_action, {buffer = 0})
  F.nnmap('<leader>rn', rnm.rename, { buffer = 0 })

  F.nnmap('<leader>h', dgn.get_line,  { buffer = 0 })
  F.nnmap('<leader>j', dgn.goto_next, { buffer = 0 })
  F.nnmap('<leader>k', dgn.goto_prev, { buffer = 0 })
  F.nnmap('<leader>l', '<CMD>silent! Telescope diagnostics<CR>')
end


for key, server in pairs(servers) do
  local capabilities = v.lsp.protocol.make_client_capabilities()
  local opts = {
    on_attach     = on_attach,
    capabilities  = require('cmp_nvim_lsp').default_capabilities(capabilities)
  }

  if configs[key] then
    local config = require('lsp.servers.' .. configs[key])
    v.tbl_deep_extend('force', config, opts)
  end

  lsp[server].setup(opts)
end
