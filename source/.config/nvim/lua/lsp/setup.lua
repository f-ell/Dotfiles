local lsp = require('lspconfig')
local key = require('utils.lib').key
local ui  = require('lsp.ui')
local v   = vim

local servers = {
  ['1'] = 'clangd',
  ['2'] = 'gopls',
  ['3'] = 'jdtls',
  ['4'] = 'perlpls',
  ['5'] = 'pylsp',
  ['6'] = 'rust_analyzer',
  ['7'] = 'lua_ls',
  ['8'] = 'texlab',
  ['9'] = 'tsserver'
}
local configs  = {
  ['2'] = 'go',
  ['3'] = 'java',
  ['4'] = 'perl',
  ['6'] = 'rust',
  ['7'] = 'lua'
}


local on_attach = function()
  key.nnmap('gd',         ui.def.peek,        { buffer = 0 })
  key.nnmap('<leader>gd', ui.def.open,        { buffer = 0 })
  key.nnmap('K',          v.lsp.buf.hover,    { buffer = 0 })
  key.nnmap('<leader>ca', ui.cda.codeaction,  { buffer = 0 })
  key.nnmap('<leader>rn', ui.ren.rename,      { buffer = 0 })

  key.nnmap('<leader>h', ui.dgn.get_line,   { buffer = 0 })
  key.nnmap('<leader>j', ui.dgn.goto_next,  { buffer = 0 })
  key.nnmap('<leader>k', ui.dgn.goto_prev,  { buffer = 0 })
  key.nnmap('<leader>l', function()
    require('telescope'); v.cmd('silent! Telescope diagnostics')
  end)
end


for i, server in pairs(servers) do
  local caps = v.lsp.protocol.make_client_capabilities()
  local opts = {
    on_attach     = on_attach,
    capabilities  = require('cmp_nvim_lsp').default_capabilities(caps)
  }

  if configs[i] then
    opts = v.tbl_extend('force', opts, require('lsp.servers.' .. configs[i]))
  end
  lsp[server].setup(opts)
end
