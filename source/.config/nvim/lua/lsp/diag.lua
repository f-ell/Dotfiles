-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local v   = vim
local va  = v.api
local vd  = v.diagnostic
local vf  = v.fn
local strlen = string.len
local strsub = string.gsub

local M = {}




-- auxiliary
local get_longest_line = function(tbl)
  local max = 0
  for i = 1, #tbl do
    local len = strlen(tbl[i])
    if len > max then max = len end
  end
  return max
end


local preprocess = function(type, diag)
  local tbl       = { hdr = '', type = type, data = {} }
  local severity  = { 'Error', 'Warn', 'Info', 'Hint' }

  for i = 1, #diag do
    table.insert(tbl.data, {
      msg     = strsub(diag[i].message, '\n', '\\n'),
      src     = diag[i].source,
      sev     = diag[i].severity,
      sev_str = severity[diag[i].severity],

      ln    = diag[i].lnum+1,
      col   = diag[i].col+1,
      ecol  = diag[i].end_col,
    })
  end

  return tbl
end


local format = function(diag)
  local ret   = {}
  local data  = diag.data

  local str
  for i = 1, #data do
    if diag.type == 'dir' then
      str = data[i].msg..' ('..data[i].src..')'
    else
      local col = data[i].col <= data[i].ecol
        and data[i].col..'-'..data[i].ecol or data[i].col
      str = data[i].msg..' '..'col:'..col
    end

    table.insert(ret, str)
  end

  return ret
end


local generate_header = function(diag)
  local icon = { '', '', '', '' }
  local data = diag.data[1]

  local hdr, loc
  if diag.type == 'dir' then
    hdr = icon[data.sev]..' '..data.sev_str
    loc = ' at <'..data.ln..':'..data.col..'>'
  else
    hdr = ' Diagnostics in line'
    loc =  ' <'..data.ln..'>'
  end
  diag.hdr = hdr
  diag.loc = loc
end


local set_highlights = function(bufnr, diag)
  local hl_ntl    = 'NeutralFloat'
  local hl_ntl_sp = 'NeutralFloatSp'
  local hl_hdr = { 'ErrorFloatSp', 'WarningFloatSp', 'InfoFloatSp',  'HintFloatSp' }
  local hl_msg = { 'ErrorFloat',   'WarningFloat',   'InfoFloat',    'HintFloat' }
  local hl, len
  local data = diag.data

  -- header
  len = strlen(diag.hdr)
  if diag.type == 'dir' then
    hl = hl_hdr[data[1].sev]
    va.nvim_buf_add_highlight(bufnr, -1, hl,      0,  0, len)
    va.nvim_buf_add_highlight(bufnr, -1, hl_ntl,  0, len+1, -1)
  else
    hl = 'InfoFloatSp'
    va.nvim_buf_add_highlight(bufnr, -1, hl,      0, 0, len)
    va.nvim_buf_add_highlight(bufnr, -1, hl_ntl,  0, len+1, -1)
  end

  -- separator
  va.nvim_buf_add_highlight(bufnr, -1, hl_ntl, 1, 0, -1)

  -- body
  for i = 1, #data do
    hl  = hl_msg[data[i].sev]
    len = strlen(data[i].msg)
    if diag.type == 'dir' then
      va.nvim_buf_add_highlight(bufnr, -1, hl,        i+1, 0, len)
      va.nvim_buf_add_highlight(bufnr, -1, hl_ntl_sp, i+1, len+1, -1)
    else
      va.nvim_buf_add_highlight(bufnr, -1, hl,        i+1, 0, len)
      va.nvim_buf_add_highlight(bufnr, -1, hl_ntl_sp, i+1, len+1, -1)
    end
  end
end


local open = function(type, diag)
  local w_max = math.floor(v.o.columns * 0.8)
  local processed = preprocess(type, diag)
  local content   = format(processed)

  -- move cursor to diagnostic
  if type == 'dir' then
    vf.cursor(processed.data[1].ln, processed.data[1].col)
  end

  -- insert header and separator
  generate_header(processed)
  table.insert(content, 1, processed.hdr..processed.loc)

  local w = get_longest_line(content)
  table.insert(content, 2,
    string.rep('', w < w_max and w or w_max))

  -- do floaty stuff
  v.defer_fn(function()
    local bufnr = v.lsp.util.open_floating_preview(content, 'off', {
      focusable = true,
      wrap      = true,
      wrap_at   = w_max,
      max_width = w_max,

      style     = 'minimal',
      border    = 'rounded',

      close_events = { 'CursorMoved', 'InsertEnter' }
    })
    set_highlights(bufnr, processed)
  end, 0)
end


local try_diag = function(type, diag)
  if diag[1] == nil then
    local str = type == 'dir' and 'No diagnostics to jump to.'
      or 'No diagnostics in this line.'
    return v.notify(str, 2)
  end

  open(type, diag)
end




-- main
M.goto_next = function() try_diag('dir', { vd.get_next() }) end
M.goto_prev = function() try_diag('dir', { vd.get_prev() }) end
M.get_line = function()
  try_diag('line', vd.get(0, { lnum = vf.line('.') - 1 }))
end
return M
