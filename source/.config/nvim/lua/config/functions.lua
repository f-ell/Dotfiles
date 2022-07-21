local M = {}

function M.map(mode, bind, command, opts)
    local constraint = { noremap = true }
    if opts then
        constraint = vim.tbl_extend('force', constraint, opts)
    end
    vim.api.nvim_set_keymap(mode, bind, command, constraint)
end

function M.vimg(name, value)
    vim.g[name] = value
end

function M.setNV(name, value)
    local option = name
    if value then
        option = option .. '=' .. value
    end
    vim.api.nvim_command(':set ' .. option)
end

function M.setmV(...)
    for _, name in pairs({...}) do
        vim.api.nvim_command(':set ' .. name)
    end
end

function M.setsV(name, onoff)
    vim.api.nvim_command(':' .. name .. ' ' .. onoff)
end

return M
