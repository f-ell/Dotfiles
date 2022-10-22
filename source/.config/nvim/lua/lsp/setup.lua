local lsp = require('lspconfig')
local F   = require('utils.functions')

local servers = {
  _1 = 'jdtls',
  _2 = 'perlpls', -- / perlnavigator
  _3 = 'pylsp',
  _4 = 'sumneko_lua',
  _5 = 'texlab',
  _6 = 'tsserver' -- / quick_lint_js
}

local configs  = {
  _2 = 'perl',
  _3 = 'lua'
}


local on_attach = function()
  F.nnmap('<leader>gd', 'gd')
  F.nnmap('gd', ':Lspsaga peek_definition<CR>')
  F.nnmap('K',  ':Lspsaga hover_doc<CR>')
  F.nnmap('<leader>r', ':Lspsaga rename<CR>')
  F.nnmap('<leader>ca', ':Lspsaga code_action<CR>')

  F.nnmap('<leader>h', ':Lspsaga show_line_diagnostics<CR>')
  F.nnmap('<leader>j', ':Lspsaga diagnostic_jump_next<CR>')
  F.nnmap('<leader>k', ':Lspsaga diagnostic_jump_prev<CR>')
  F.nnmap('<leader>l', ':silent! Telescope diagnostics<CR>')

  -- deprecated mappings:
  -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
  -- F.nnmap('<leader>ds', vim.diagnostic.open_float,  {buffer = 0})
  -- F.nnmap('<leader>dj', vim.diagnostic.goto_next,   {buffer = 0})
  -- F.nnmap('<leader>dk', vim.diagnostic.goto_prev,   {buffer = 0})
  -- F.nnmap('<leader>lr', vim.lsp.buf.rename,     {buffer = 0})
  -- F.nnmap('<leader>ld', vim.lsp.buf.definition, {buffer = 0})
end


for key, server in pairs(servers) do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local opts = {
    on_attach     = on_attach,
    capabilities  = require('cmp_nvim_lsp').default_capabilities(capabilities)
  }

  if configs[key] then
    local config = require('lsp.servers.' .. configs[key])
    vim.tbl_deep_extend('force', config, opts)
  end

  lsp[server].setup(opts)
end
