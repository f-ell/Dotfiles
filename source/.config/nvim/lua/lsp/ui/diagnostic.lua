-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local L = require('utils.lib')
local M = {}


local preprocess = function(raw)
  local diag = raw.diag
  local tbl = { hdr = '', type = raw.type, data = {} }
  local severity = { 'Error', 'Warn', 'Info', 'Hint' }

  for i = 1, #diag do
    local msg = diag[i].message

    while msg:find('\n') do
      local stridx = msg:find('\n')
      table.insert(tbl.data, {
        partial = true,
        msg = msg:sub(1, stridx-1),
        sev = diag[i].severity
      })
      msg = msg:sub(stridx+1)
    end

    table.insert(tbl.data, {
      partial = false,
      msg = msg,
      src = diag[i].source,
      sev = diag[i].severity,
      sev_str = severity[diag[i].severity],

      ln = diag[i].lnum+1,
      col = diag[i].col+1,
      ecol = diag[i].end_col,
    })
  end

  return tbl
end


local format = function(proc)
  local ret = {}
  local data = proc.data

  local str
  for i = 1, #data do
    if data[i].partial then
      str = data[i].msg
      goto continue
    end

    if proc.type == 'dir' then
      str = data[i].msg..' ('..data[i].src..')'
    else
      local col = data[i].col <= data[i].ecol
        and data[i].col..'-'..data[i].ecol or data[i].col
      str = data[i].msg..' '..'col:'..col
    end

    ::continue::
    table.insert(ret, str)
  end

  return ret
end


local generate_header = function(diag)
  local icon = { '', '', '', '' }
  local data = diag.data[#diag.data]

  local hdr, loc
  if diag.type == 'dir' then
    hdr = icon[data.sev]..' '..data.sev_str
    loc = ' at <'..data.ln..':'..data.col..'>'
  else
    hdr = ' Diagnostics in line'
    loc = ' <'..data.ln..'>'
  end
  diag.hdr = hdr
  diag.loc = loc
end


local set_highlights = function(bufnr, proc)
  local hl_ntl = 'NeutralFloat'
  local hl_ntl_sp = 'NeutralFloatSp'
  local hl_hdr = { 'ErrorFloatSp', 'WarningFloatSp', 'InfoFloatSp', 'HintFloatSp' }
  local hl_msg = { 'ErrorFloat', 'WarningFloat', 'InfoFloat', 'HintFloat' }
  local hl, len
  local data = proc.data

  -- header
  len = proc.hdr:len()
  if proc.type == 'dir' then
    hl = hl_hdr[data[1].sev]
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl, 0, 0, len)
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl_ntl, 0, len+1, -1)
  else
    hl = 'InfoFloatSp'
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl, 0, 0, len)
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl_ntl, 0, len+1, -1)
  end

  -- separator
  vim.api.nvim_buf_add_highlight(bufnr, -1, hl_ntl, 1, 0, -1)

  -- body
  for i = 1, #data do
    hl = hl_msg[data[i].sev]
    len = data[i].msg:len()
    if data[i].partial then
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl, i+1, 0, -1)
      goto continue
    end

    if proc.type == 'dir' then
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl, i+1, 0, len)
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl_ntl_sp, i+1, len+1, -1)
    else
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl, i+1, 0, len)
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl_ntl_sp, i+1, len+1, -1)
    end
    ::continue::
  end
end


local open = function(raw)
  local proc = preprocess(raw)
  local content = format(proc)

  -- move cursor to diagnostic
  if proc.type == 'dir' then vim.fn.cursor(proc.data[#proc.data].ln, proc.data[#proc.data].col) end

  -- insert header and separator
  generate_header(proc)
  table.insert(content, 1, proc.hdr..proc.loc)
  table.insert(content, 2, L.win.separator(content))

  -- do floaty stuff
  local data = L.win.open_cursor(content, false, false, { focusable = false, zindex = 2 })
  set_highlights(data.nbuf, proc)
  L.cmd.event({ 'BufLeave', 'CursorMoved', 'InsertEnter', 'WinNew' }, data.obuf,
    function() L.win.close(data.nwin) end)
end


local try_diagnostic = function(type, diag)
  if diag[1] == nil then return vim.notify('No diagnostics found.', 2) end
  open({ type = type, diag = diag })
end


M.goto_next = function() try_diagnostic('dir', { vim.diagnostic.get_next() }) end
M.goto_prev = function() try_diagnostic('dir', { vim.diagnostic.get_prev() }) end
M.get_line = function()
  try_diagnostic('line', vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 }))
end
return M
