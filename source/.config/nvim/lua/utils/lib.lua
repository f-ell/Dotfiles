local M   = {}
local v   = vim
local va  = v.api




-- misc
---@param str string
M.chop = function(str)
  return str:sub(0, str:len()-1)
end


---@param tbl table
---@param err_to_devnull boolean
---@param retval_nil any
M.open = function(tbl, err_to_devnull, retval_nil)
  if err_to_devnull then table.insert(tbl, '2>/dev/null') end

  local fh = io.popen(table.concat(tbl, ' '), 'r')
  return fh == nil and retval_nil or fh
end


---@param fh file*
M.read = function(fh)
  local ret = M.chop(fh:read('*a'))
  fh:close()
  return ret
end




-- nvim internal
---@param cmd string
M.c = function(cmd)
  va.nvim_command(cmd)
end

---@param name string
---@param value string
M.o = function(name, value)
  if value == nil then
    return v.o[name]
  else
    v.opt[name] = value
  end
end

---@param name string
---@param value string
M.g = function(name, value)
  if value == nil then
    return v.g[name]
  else
    v.g[name] = value
  end
end


---@param mode string
---@param opt? table
local map = function(mode, opt)
    opt = opt or { noremap = true }
    ---@param lhs string
    ---@param rhs string
    ---@param re table
    return function(lhs, rhs, re)
        re = v.tbl_extend('force', opt, re or {})
        v.keymap.set(mode, lhs, rhs, re)
    end
end

M.inmap = map('i')
M.nmap  = map('n', { noremap = false })
M.nnmap = map('n')
M.vnmap = map('v')
M.cnmap = map('c')
M.tnmap = map('t')


return M
