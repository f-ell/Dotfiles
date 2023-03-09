local v   = vim
local va  = v.api
local vf  = v.fn
local vl  = v.lsp
local EW, CW = 0.7, 0.8 -- window width when 'relative' is editor/cursor

local M = {
  cmd = {},
  fs  = {},
  io  = {},
  key = {},
  lsp = {},
  str = {},
  tbl = {},
  vim = {},
  win = {}
}

---------------------------------------------------------------------------- cmd
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

----------------------------------------------------------------------------- fs
---Create directory for temporary user files.
---
M.fs.mktmpdir = function()
  local dir = vf.stdpath('run')..'/nvim.user'
  if v.loop.fs_stat(dir) then return end
  if not v.loop.fs_mkdir(dir, 448) then
    return v.notify('Couldn\'t create temporary directory \''..dir..'\'', 4)
  end
end


-- TODO: implement | remove
---Write to temporary file. Registers delete autocommands on 'VimLeavePre'.
---
-- M.fs.writetmpfile = function()
-- end

----------------------------------------------------------------------------- io
---Open a readonly filehandle through io.popen(), where fd2 may be redirected
---to /dev/null. Returns the filehandle if not nil; 'ret' otherwise.
---
---@param cmd table
---@param devnull boolean
---@param ret any?
---@return any
M.io.popen = function(cmd, devnull, ret)
  if devnull then table.insert(cmd, '2>/dev/null') end
  local fh = io.popen(table.concat(cmd, ' '), 'r')
  return fh == nil and ret or fh
end


---Slurp filehandle.
---Chops off trailing newline character and closes the handle before returning.
---
---@param fh file*
---@return string
M.io.read = function(fh)
  if fh == nil then return '' end
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


---Write 'content' to 'file' linewise in update mode.
---
---@param file string
---@param content table
M.io.write = function(file, content)
  local fh = io.open(file, 'w+')
  if fh == nil then return v.notify('Write to \''..file..'\' failed.') end
  fh:write(table.concat(content, '\n')..'\n'); fh:flush(); fh:close()
end

---------------------------------------------------------------------------- lsp
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

---------------------------------------------------------------------------- str
---Acts similarly to Perl's chop(), removing the string's last character.
---
---@param str string
---@return string
M.str.chop = function(str)
  return str:sub(0, str:len() - 1)
end

---------------------------------------------------------------------------- tbl
---Returns the length of the longest line in tbl.
---
---@param tbl table
---@return integer
M.tbl.longest_line = function(tbl)
  local max = 0
  for i = 1, #tbl do
    local len = vf.strdisplaywidth(tbl[i])
    if len > max then max = len end
  end
  max = tonumber(max)
  if max == nil then return -1 else return max end
end


---Returns true if tbl is empty or nil, false otherwise.
---
---@param tbl table|nil
---@returns boolean
M.tbl.is_empty = function(tbl)
  return (tbl == nil or next(tbl) == nil) and true or false
end

---------------------------------------------------------------------------- vim
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

---------------------------------------------------------------------------- win
M.win._height = function(content)
  if type(content) == 'number' then return math.floor(v.o.lines * EW) end

  local _mw = M.win._max_width()
  if M.tbl.longest_line(content) < _mw then return #content end

  local h, sb = 0, vf.strdisplaywidth(v.o.showbreak)
  for _, line in pairs(content) do
    h = h + 1
    local ln = vf.strdisplaywidth(line)

    -- first wrap
    if ln > _mw then ln = ln - _mw; h = h + 1 end
    -- all subsequent wraps
    while ln > _mw do
      ln = ln - _mw + sb
      h = h + 1
    end
  end
  return h
end

M.win._max_width = function() return math.floor(v.o.columns * CW) - 2 end

M.win._width = function(content)
  return type(content) == 'number' and math.floor(v.o.columns * EW)
    or math.min(M.tbl.longest_line(content), M.win._max_width())
end

M.win._voffset = function()
  local o = math.floor(-v.o.cmdheight / 2)
  local s = v.o.laststatus
  local t = v.o.showtabline
  if s > 1 or s == 1 and #va.nvim_tabpage_list_wins() > 1 then o = o - 1 end
  if t > 1 or t == 1 and #va.nvim_list_tabpages()     > 1 then o = o + 1 end
  return o
end


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


---Opens a new floating window holding a scratch buffer. If 'bl' is a number, it
---is interpreted as a buffer (b) handle to display. Otherwise, the table
---contents are used as the lines (l) to display in the buffer.
---
---Returns a table containing the new and old buffer and window handles.
---
---@param bl number|table
---@param modifiable boolean
---@param enter boolean
---@param config table?
---@return table
M.win.open = function(bl, modifiable, enter, config)
  local data = {
    obuf = va.nvim_get_current_buf(),
    owin = va.nvim_get_current_win(),
    nbuf = -1,
    nwin = -1,
    height  = M.win._height(bl),
    width   = M.win._width(bl)
  }
  if type(bl) == 'table' then data.nbuf = va.nvim_create_buf(false, true)
  else                        data.nbuf = bl end

  local conf = v.tbl_extend('keep', config or {}, {
    relative = type(bl) == 'table' and 'cursor' or 'editor',
    anchor = 'NW',
    row = 1,
    col = type(bl) == 'table' and -1 or math.floor((v.o.columns * (1 - EW)) / 2),

    width   = data.width,
    height  = data.height,
    style   = 'minimal',
    border  = 'rounded'
  })

  data.nwin = va.nvim_open_win(data.nbuf, enter, conf)
  if type(bl) == 'table' then va.nvim_buf_set_lines(data.nbuf, 0, -1, true, bl)
  else                        va.nvim_win_set_buf(data.nwin, data.nbuf) end

  v.bo[data.nbuf].bufhidden = 'wipe'
  v.bo[data.nbuf].modifiable = modifiable
  -- TODO: change / conditionally set this?
  if type(bl) == 'table' then
    v.wo[data.nwin].wrap = true
    v.bo[data.nbuf].wrapmargin = 0
  end

  return data
end


---Wraps win.open(), with default position centered relative to editor.
---
---@param bl number|table
---@param modifiable boolean
---@param enter boolean
---@param config table?
---@return table
M.win.open_center = function(bl, modifiable, enter, config)
  local conf = v.tbl_extend('keep', config or {}, {
    relative = 'editor', anchor = 'NW',
    row = math.floor((v.o.lines * (1 - EW)) / 2) + M.win._voffset(),
    col = math.floor((v.o.columns * (1 - EW)) / 2)
  })
  return M.win.open(bl, modifiable, enter, conf)
end


---Wraps win.open(), with default position at cursor.
---
---@param bl number|table
---@param modifiable boolean
---@param enter boolean
---@param config table?
---@return table
M.win.open_cursor = function(bl, modifiable, enter, config)
  local anchor, row = M.win.anchor_offset()

  local conf = v.tbl_extend('keep', config or {}, {
    relative = 'cursor', anchor = anchor,
    row = row, col = -1
  })
  return M.win.open(bl, modifiable, enter, conf)
end


---Generate a separation line, with the length accounting for the maximum window
---width.
---
---@param lines table
M.win.separator = function(lines)
  local _mw = M.win._max_width()
  local len = M.tbl.longest_line(lines)
  return string.rep('', len > _mw and _mw or len)
end

---------------------------------------------------------------------------- key
M.key._map = function(mode, map_opts)
    map_opts = map_opts or { noremap = true }
    ---Wraps vim.keymap.set, where the mode is derived from the overarching
    ---map() call.
    ---
    ---@param lhs string
    ---@param rhs string | function
    ---@param opts table?
    return function(lhs, rhs, opts)
        opts = v.tbl_extend('force', map_opts, opts or {})
        v.keymap.set(mode, lhs, rhs, opts)
    end
end

M.key.inmap = M.key._map('i')
M.key.nmap  = M.key._map('n', { noremap = false })
M.key.nnmap = M.key._map('n')
M.key.vnmap = M.key._map('v')
M.key.cnmap = M.key._map('c')
M.key.tnmap = M.key._map('t')


---Creates the keymap 'lhs' for each mode in 'modes'.
---
---@param modes string|table
---@param lhs string
---@param rhs string|function
---@params opts table?
M.key.modemap = function(modes, lhs, rhs, opts)
  opts = v.tbl_extend('force', { noremap = true }, opts)
  if type(modes) == 'string' then modes = { modes } end
  for _, mode in pairs(modes) do v.keymap.set(mode, lhs, rhs, opts) end
end


---Deletes the keymap 'lhs' for each mode in 'modes'.
---
---@param modes string|table
---@param lhs string
---@param opts table?
M.key.unmap = function(modes, lhs, opts)
  if type(modes) == 'string' then modes = { modes } end
  for _, mode in pairs(modes) do v.keymap.del(mode, lhs, opts or {}) end
end


return M
