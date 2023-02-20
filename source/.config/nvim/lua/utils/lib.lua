local v   = vim
local va  = v.api

local M = {
  vim = {},
  key = {},
  util = {}
}




-- misc

---Acts similarly to Perl's chop(), removing the string's last character.
---
---@param str string
---@return string
M.util.chop = function(str)
  return str:sub(0, str:len()-1)
end


---Open a readonly filehandle.
---
---The handle is opened with io.popen(); fd2 may be redirected to /dev/null.
---Returns the filehandle if not nil; retval_nil otherwise.
---
---@param tbl table
---@param err_to_devnull boolean
---@param retval_nil? any
---@return any
M.util.open = function(tbl, err_to_devnull, retval_nil)
  if err_to_devnull then table.insert(tbl, '2>/dev/null') end

  local fh = io.popen(table.concat(tbl, ' '), 'r')
  return fh == nil and retval_nil or fh
end


---Slurp filehandle.
---
---Chops off trailing newline character and closes the handle before returning.
---
---@param fh file*
---@return string
M.util.read = function(fh)
  local ret = M.util.chop(fh:read('*a'))
  fh:close()
  return ret
end

---Same as read(), but don't chop trailing newline character.
---
---@param fh file*
---@return string
M.util.read_no_chop = function(fh)
  local ret = fh:read('*a')
  fh:close()
  return ret
end




-- nvim internal

---Wraps vim.api.nvim_command(cmd).
---
---@param cmd string
M.vim.c = function(cmd)
  va.nvim_command(cmd)
end

---Wraps v.o[name] = value when value is passed.
---Returns the option value otherwise.
---
---@param name string
---@param value? any
M.vim.o = function(name, value)
  if value == nil then
    return v.o[name]
  else
    v.o[name] = value
  end
end

---Wraps v.g[name] = value when value is passed.
---Returns the option value otherwise.
---
---@param name string
---@param value? any
M.vim.g = function(name, value)
  if value == nil then
    return v.g[name]
  else
    v.g[name] = value
  end
end


---Meta-function for easier keymap definition.
---
---@param mode string
---@param opt? table
local map = function(mode, opt)
    opt = opt or { noremap = true }
    ---Wraps vim.keymap.set, where the mode is derived from the overarching map() call.
    ---
    ---@param lhs string
    ---@param rhs string | function
    ---@param re? table
    return function(lhs, rhs, re)
        re = v.tbl_extend('force', opt, re or {})
        v.keymap.set(mode, lhs, rhs, re)
    end
end

M.key.inmap = map('i')
M.key.nmap  = map('n', { noremap = false })
M.key.nnmap = map('n')
M.key.vnmap = map('v')
M.key.cnmap = map('c')
M.key.tnmap = map('t')


return M
