local M = {}

function M.setup()
    local signs = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn",  text = "" },
        { name = "DiagnosticSignHint",  text = "" },
        { name = "DiagnosticSignInfo",  text = "" },
    }
    for _, sign in pairs(signs) do
        vim.fn.sign_define(sign.name,
            { texthl = sign.name, text = sign.text, numhl = "" })
    end

    local config = {
        update_in_insert    = true,
        virtual_text        = false,
        underline           = false,
        severity_sort       = true,
        sign = {
            active = signs
        },
        float = {
            focusable = false,
            style = 'minimal',
            border = 'rounded',
            source = 'always',
            header = '',
            prefix = ''
        }
    }
    vim.diagnostic.config(config)

    vim.lsp.handlers['textDocument/hover'] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
    vim.lsp.handlers['textDocument/signatureHelp'] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
end

function M.on_attach()
      vim.o.signcolumn = 'yes:1'

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
      vim.keymap.set('n', '<leader>ds', vim.diagnostic.open_float,  { buffer = 0})
      vim.keymap.set('n', '<leader>dj', vim.diagnostic.goto_next,   { buffer = 0 })
      vim.keymap.set('n', '<leader>dk', vim.diagnostic.goto_prev,   { buffer = 0 })
end

return M
