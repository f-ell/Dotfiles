local lsp = require('lspconfig')
local F   = require('utils.functions')

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

  -- TODO deprecate this block:
  F.nnmap('gd',         '<CMD>Lspsaga peek_definition<CR>')
  F.nnmap('<leader>ca', '<CMD>Lspsaga code_action<CR>')
  F.nnmap('<leader>rn', '<CMD>Lspsaga rename<CR>')
  F.nnmap('<leader>h',  '<CMD>Lspsaga show_line_diagnostics<CR>')
  ----
  F.nnmap('<leader>j', '<CMD>Lspsaga diagnostic_jump_next<CR>')
  F.nnmap('<leader>k', '<CMD>Lspsaga diagnostic_jump_prev<CR>')
  ----

  -- F.nnmap('gd', vim.lsp.buf.definition, {buffer = 0})
  F.nnmap('K',  vim.lsp.buf.hover,      {buffer = 0})
  -- F.nnmap('<leader>ca', vim.lsp.buf.code_action,    {buffer = 0})
  -- F.nnmap('<leader>rn', vim.lsp.buf.rename,         {buffer = 0})
  F.nnmap('<leader>rf', vim.lsp.buf.references,     {buffer = 0})

  -- F.nnmap('<leader>h',  vim.diagnostic.open_float,  {buffer = 0})
  -- F.nnmap('<leader>j',  vim.diagnostic.goto_next,   {buffer = 0})
  -- F.nnmap('<leader>k',  vim.diagnostic.goto_prev,   {buffer = 0})
  F.nnmap('<leader>l', '<CMD>silent! Telescope diagnostics<CR>')
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
