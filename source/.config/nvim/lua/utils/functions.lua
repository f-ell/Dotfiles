local M   = {}
local v   = vim
local va  = v.api


M.c = function(command)
  va.nvim_command(command)
end

M.o = function(name, value)
  if value == nil then
    return v.o[name]
  else
    v.opt[name] = value
  end
end

M.g = function(name, value)
  if value == nil then
    return v.g[name]
  else
    v.g[name] = value
  end
end


M.chop = function(str)
  return str:sub(0, str:len()-1)
end


local map = function(mode, opt)
    opt = opt or {noremap = true}
    return function(lhs, rhs, re)
        re = v.tbl_extend('force', opt, re or {})
        v.keymap.set(mode, lhs, rhs, re)
    end
end

M.inmap = map('i')
M.nmap  = map('n', {noremap = false})
M.nnmap = map('n')
M.vnmap = map('v')
M.cnmap = map('c')
M.tnmap = map('t')


return M
