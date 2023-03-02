local v   = vim
local va  = v.api
local vf  = v.fn
local vl  = v.lsp

-- TODO: define center-float width and height / offset here, allows reusing, and
-- easier adaptation

local M = {
  cmd = {},
  io  = {},
  key = {},
  lsp = {},
  str = {},
  tbl = {},
  vim = {},
  win = {}
}

--------------------------------------------------------------------------------
---Registers 'events' with 'cb' as a buffer-local autocommand on 'bufnr'.
---
---@param events string|table
---@param bufnr number
---@param cb string|function
M.cmd.event = function(events, bufnr, cb)
  v.defer_fn(function() va.nvim_create_autocmd(events, {
    buffer = bufnr, once = true, nested = true,
    callback = type(cb) == 'string' and cb or function(tbl) cb(tbl) end
  }) end, 0)
end

--------------------------------------------------------------------------------
---Open a readonly filehandle.
---
---The handle is opened with io.popen(); fd2 may be redirected to /dev/null.
---Returns the filehandle if not nil; retval_nil otherwise.
---
---@param tbl table
---@param err_to_devnull boolean
---@param retval_nil any?
---@return any
M.io.open = function(tbl, err_to_devnull, retval_nil)
  if err_to_devnull then table.insert(tbl, '2>/dev/null') end

  local fh = io.popen(table.concat(tbl, ' '), 'r')
  return fh == nil and retval_nil or fh
end


---Slurp filehandle.
---Chops off trailing newline character and closes the handle before returning.
---
---@param fh file*
---@return string
M.io.read = function(fh)
  local str = M.str.chop(fh:read('*a'))
  fh:close()
  return str
end


---Same as io.read(), but don't chop trailing newline character.
---
---@param fh file*
---@return string
M.io.read_no_chop = function(fh)
  local str = fh:read('*a')
  fh:close()
  return str
end

--------------------------------------------------------------------------------
---Applies a workspace edit. 'res' is a table with the same fields as returned
---by client_responses().
---
---@param response table
M.lsp.apply_edit = function(response)
  local edit = response.result
  local oenc = vl.get_client_by_id(response.id).offset_encoding

  if edit.edit then vl.util.apply_workspace_edit(edit.edit, oenc) end
  if edit.action and type(edit.action) == 'function' then edit.action() end
end


---Returns table containing all servers with server_capabilities[cap..'Provider'],
---that are attached to the current buffer.
---
---@param cap string
---@return table
M.lsp.clients_by_cap = function(cap)
  local capable   = {}
  local available = vl.get_active_clients({ buffer = va.nvim_get_current_buf() })

  for i = 1, #available do
    if available[i].server_capabilities[cap..'Provider'] then
      table.insert(capable, available[i])
    end
  end

  if #capable == 0 then v.notify('No suitable client found.', 3) end
  return capable
end


---Returns table consisting of concatenated results from all clients, where each
---table field is { id: number, name: string, result: table }.
---
---'cb', if present, will be called after all results have been gathered, the
---result-table is passed as the first argument to the function.
---
---@param clients table
---@param method string
---@param params TextDocumentPositionParams
---@param bufnr number
---@param cb function?
---@return table|nil
M.lsp.request = function(clients, method, params, bufnr, cb)
  if type(clients) ~= 'table' or M.tbl.is_empty(clients) then
    return v.notify('Invalid clients.', 3)
  end
  local responses = {}

  for i = 1, #clients do
    local client  = clients[i]
    local dict    = client.request_sync(method, params, 500, bufnr)
    if next(dict) == nil or dict.err then goto continue end

    for _, res in pairs(dict.result) do
      table.insert(responses, { id = client.id, name = client.name, result = res })
    end
    ::continue::
  end

  if M.tbl.is_empty(responses) then return v.notify('No results found.', 3) end

  if cb ~= nil and type(cb) == 'function' then cb(responses) end
  return responses
end

--------------------------------------------------------------------------------
---Acts similarly to Perl's chop(), removing the string's last character.
---
---@param str string
---@return string
M.str.chop = function(str)
  return str:sub(0, str:len() - 1)
end

--------------------------------------------------------------------------------
---Returns the length of the longest line in tbl.
---
---@param tbl table
---@return number
M.tbl.longest_line = function(tbl)
  local max = 0
  for i = 1, #tbl do
    local len = vf.strdisplaywidth(tbl[i])
    if len > max then max = len end
  end
  return max
end


---Returns true if tbl is empty or nil, false otherwise.
---
---@param tbl table|nil
---@returns boolean
M.tbl.is_empty = function(tbl)
  return (tbl == nil or next(tbl) == nil) and true or false
end

--------------------------------------------------------------------------------
---Wraps vim.api.nvim_command(cmd).
---
---@param cmd string
M.vim.c = function(cmd) va.nvim_command(cmd) end


---Wraps v.g[name] = value when value is passed.
---Returns the option value otherwise.
---
---@param name string
---@param value any?
M.vim.g = function(name, value)
  if value == nil then
    return v.g[name]
  else
    v.g[name] = value
  end
end


---Wraps v.o[name] = value when value is passed.
---Returns the option value otherwise.
---
---@param name string
---@param value any?
M.vim.o = function(name, value)
  if value == nil then
    return v.o[name]
  else
    v.o[name] = value
  end
end

--------------------------------------------------------------------------------
---Returns the window anchor (NW or SW) and the required window offset (1 or 0),
---based on the cursor position in the current window.
---
---@return string,number
M.win.anchor_offset = function()
    local anchor = vf.winline() - (vf.winheight(0) / 2) > 0 and 'SW' or 'NW'
    local offset = anchor == 'NW' and 1 or 0
    return anchor, offset
end


---Tries to close window 'nwin'. If present, the current window will be set to
---'owin' at 'pos' (the latter is expected to be a (1,0)-indexed tuple).
---
---@param nwin number
---@param owin number?
---@pos table?
M.win.close = function(nwin, owin, pos)
  if not va.nvim_win_is_valid(nwin) then return end
  va.nvim_win_close(nwin, true)
  if owin and pos then va.nvim_win_set_cursor(owin, pos) end
end


---Returns true if winnr is the current window and true in the sense of
---vim.api.nvim_win_is_valid().
---
---@param winnr number
---@return boolean
M.win.is_cur_valid = function(winnr)
  return (va.nvim_get_current_win() == winnr and va.nvim_win_is_valid(winnr))
    and true or false
end


---Opens a new floating window holding a scratch buffer. If 'id' is a table, the
---content will be set as the buffer contents, otherwise 'id' will be used as a
---buffer handle to display.
---
---Returns a table containing the new and old buffer and window handles.
---
---@param id number|table
---@param modifiable boolean
---@param enter boolean
---@param config table?
---@return table
M.win.open = function(id, modifiable, enter, config)
  local data = {
    obuf = va.nvim_get_current_buf(),
    owin = va.nvim_get_current_win(),
    nbuf = -1,
    nwin = -1
  }
  if type(id) == 'table' then data.nbuf = va.nvim_create_buf(false, true)
  else                        data.nbuf = id end

  local conf = v.tbl_extend('keep', config or {}, {
    relative = type(id) == 'table' and 'cursor' or 'editor',
    anchor = 'NW',
    row = 1,
    col = type(id) == 'table' and -1 or math.floor((v.o.columns * 0.3) / 2),

    width   = type(id) == 'table' and M.tbl.longest_line(id) or math.floor(v.o.columns * 0.7),
    height  = type(id) == 'table' and #id or math.floor(v.o.lines * 0.7),
    style   = 'minimal',
    border  = 'rounded'
  })

  data.nwin = va.nvim_open_win(data.nbuf, enter, conf)
  if type(id) == 'table' then va.nvim_buf_set_lines(data.nbuf, 0, -1, true, id)
  else                        va.nvim_win_set_buf(data.nwin, data.nbuf) end

  v.bo[data.nbuf].bufhidden = 'wipe'
  v.bo[data.nbuf].modifiable = modifiable
  -- TODO: remove / change / conditionally set this?
  v.bo[data.nbuf].wrapmargin = 1
  v.wo[data.nwin].wrap = true

  return data
end


---Wraps win.open(), with default position centered relative to editor.
---
---@param id number|table
---@param modifiable boolean
---@param enter boolean
---@param config table?
---@return table
M.win.open_center = function(id, modifiable, enter, config)
  local conf = v.tbl_extend('keep', config or {}, {
    relative = 'editor', anchor = 'NW',
    row = math.floor((v.o.lines * 0.3) / 2) + M.win.vert_offset(),
    col = math.floor((v.o.columns * 0.3) / 2)
  })
  return M.win.open(id, modifiable, enter, conf)
end

---Wraps win.open(), with default position at cursor.
---
---@param id number|table
---@param modifiable boolean
---@param enter boolean
---@param config table?
---@return table
M.win.open_cursor = function(id, modifiable, enter, config)
  local anchor, row = M.win.anchor_offset()

  local conf = v.tbl_extend('keep', config or {}, {
    relative = 'cursor', anchor = anchor,
    row = row, col = -1
  })
  return M.win.open(id, modifiable, enter, conf)
end


---Returns necessary offset from the top of the window to vertically center a
---float. Accounts for status- and tabline, as well as vim.opt.cmdheight.
---
---@return number
M.win.vert_offset = function()
  local o = math.floor(-v.o.cmdheight / 2)
  local s = v.o.laststatus
  local t = v.o.showtabline
  if s > 1 or s == 1 and #va.nvim_tabpage_list_wins() > 1 then o = o - 1 end
  if t > 1 or t == 1 and #va.nvim_list_tabpages()     > 1 then o = o + 1 end
  return o
end

--------------------------------------------------------------------------------
---Meta-function for easier keymap definition.
---
---@param mode string
---@param opt table?
local map = function(mode, opt)
    opt = opt or { noremap = true }
    ---Wraps vim.keymap.set, where the mode is derived from the overarching map() call.
    ---
    ---@param lhs string
    ---@param rhs string | function
    ---@param re table?
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
