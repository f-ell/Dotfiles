local lsp = require('lspconfig')
local F   = require('utils.functions')

local servers = {
  _1 = 'jdtls',
  _2 = 'perlpls', -- / perlnavigator
  _3 = 'pylsp',
  _4 = 'rust_analyzer',
  _5 = 'sumneko_lua',
  _6 = 'texlab',
  _7 = 'tsserver' -- / quick_lint_js
}

local configs  = {
  _2 = 'perl',
  _4 = 'rust',
  _5 = 'lua'
}


local on_attach = function()
  F.nnmap('<leader>gd', 'gd')

  -- TODO: deprecate this block:
  F.nnmap('gd', ':Lspsaga peek_definition<CR>')
  F.nnmap('<leader>ca', ':Lspsaga code_action<CR>')
  F.nnmap('<leader>rn', ':Lspsaga rename<CR>')
  F.nnmap('<leader>h', ':Lspsaga show_line_diagnostics<CR>')
  ----
  F.nnmap('<leader>j', ':Lspsaga diagnostic_jump_next<CR>')
  F.nnmap('<leader>k', ':Lspsaga diagnostic_jump_prev<CR>')
  ----

  -- F.nnmap('gd', vim.lsp.buf.definition, {buffer = 0})
  F.nnmap('K',  vim.lsp.buf.hover,      {buffer = 0})
  -- F.nnmap('<leader>ca', vim.lsp.buf.code_action,    {buffer = 0})
  -- F.nnmap('<leader>rn', vim.lsp.buf.rename,         {buffer = 0})
  F.nnmap('<leader>rf', vim.lsp.buf.references,     {buffer = 0})

  -- F.nnmap('<leader>h',  vim.diagnostic.open_float,  {buffer = 0})
  -- F.nnmap('<leader>j',  vim.diagnostic.goto_next,   {buffer = 0})
  -- F.nnmap('<leader>k',  vim.diagnostic.goto_prev,   {buffer = 0})
  F.nnmap('<leader>l', ':silent! Telescope diagnostics<CR>')
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
