return {
  'stevearc/oil.nvim',
  lazy = true,
  keys = { { '<leader>o', '<CMD>Oil<CR>' } },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    if vim.fn.argc() == 0 then return end
    local stat = vim.loop.fs_stat(vim.fn.argv()[1])
    if stat ~= nil and stat.type == 'directory' then
      require('oil')
    end
  end,
  config = function()
    require('oil').setup({
      view_options = { show_hidden = true },
      preview = { border = 'single' },
      use_default_keymaps = false,
      keymaps = {
        ['g?'] = 'actions.show_help',
        ['g.'] = 'actions.toggle_hidden',
        [';'] = 'actions.parent',
        [','] = 'actions.open_cwd.callback',
        ['<leader>o'] = 'actions.close',
        ['<C-l>'] = 'actions.refresh',
        ['<C-p>'] = 'actions.preview',
        ['<C-v>'] = 'actions.select_vsplit',
        ['<C-s>'] = 'actions.select_split',
        ['<C-t>'] = 'actions.select_tab',
        ['<CR>'] = 'actions.select'
      }
    })
  end
}
