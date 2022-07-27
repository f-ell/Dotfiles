local M = {}

function M.c(command)
  vim.api.nvim_command(command)
end

function M.g(name, value)
  vim.g[name] = value
end

function M.o(name, toggle)
  local bool = true
  if toggle then
    bool = false
  end
  vim.opt[name] = bool
end

local function map(mode, opt)
    opt = opt or {noremap = true}
    return function(lhs, rhs, re)
        re = vim.tbl_extend('force', opt, re or {})
        vim.api.nvim_set_keymap(mode, lhs, rhs, re)
    end
end

M.nmap = map('n', {noremap = false})
M.nnmap = map('n')
M.inmap = map('i')

return M
