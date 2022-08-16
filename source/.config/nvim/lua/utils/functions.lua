local M = {}


function M.c(command)
  vim.api.nvim_command(command)
end

function M.o(name, value)
  vim.opt[name] = value
end

function M.g(name, value)
  vim.g[name] = value
end


function M.bset(name, value)
  vim.api.nvim_buf_set_option(0, name, value)
end

function M.wset(name, value)
  vim.api.nvim_win_set_option(0, name, value)
end

function M.gset(name, value)
  vim.api.nvim_set_option(name, value)
end


local function map(mode, opt)
    opt = opt or {noremap = true}
    return function(lhs, rhs, re)
        re = vim.tbl_extend('force', opt, re or {})
        vim.api.nvim_set_keymap(mode, lhs, rhs, re)
    end
end

M.inmap = map('i')

M.nmap = map('n', {noremap = false})
M.nnmap = map('n')

M.vnmap = map('v')

M.cnmap = map('c')

M.tnmap = map('t')

return M
