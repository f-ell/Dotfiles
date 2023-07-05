return {
  'jose-elias-alvarez/null-ls.nvim',
  lazy = true,
  event = { 'BufNewFile', 'BufReadPost' },
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    local mpc = vim.fn.stdpath('data')..'/mason/bin'
    local null = require('null-ls')
    local cda = null.builtins.code_actions
    local dgn = null.builtins.diagnostics
    local fmt = null.builtins.formatting

      local eslint_d_conf = {
        command = mpc..'/eslint_d',
        condition = function(utils)
          return utils.root_has_file({
            '.eslintrc.js',
            '.eslintrc.json',
            '.eslintrc.yml'
          })
        end
      }

      local prettierd_conf = {
        command = mpc..'/prettierd',
        condition = function(utils)
          return utils.root_has_file({
            '.prettierrc',
            '.prettierrc.js',
            '.prettierrc.json',
            '.prettierrc.yml'
          })
        end
      }

    null.setup({
      on_attach = function(client, bufnr)
        if client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = vim.api.nvim_create_augroup('null-ls', { clear = true }),
                buffer = bufnr,
                desc = 'null-ls formatting',
                callback = function()
                  vim.lsp.buf.format({
                    bufnr = bufnr,
                    ---@diagnostic disable-next-line: redefined-local
                    filter = function(client) return client.name == "null-ls" end
                  })
                end,
            })
        end
      end,

      sources = {
        cda.eslint_d.with(eslint_d_conf),
        dgn.eslint_d.with(eslint_d_conf),
        fmt.prettierd.with(prettierd_conf)
      }
    })
  end
}
