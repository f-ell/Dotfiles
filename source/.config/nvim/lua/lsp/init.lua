local ok1, lspconfig  = pcall(require, 'lspconfig')
local ok2, lspinstall = pcall(require, 'nvim-lsp-installer')
if not ok1 then
    return
end

local F = require('utils.functions')
F.wset('signcolumn', 'yes:1')

lspinstall.setup()
require('lsp.setup')
require('lsp.functions').setup()
