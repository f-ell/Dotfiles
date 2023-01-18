-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local F   = require('utils.functions')
local v   = vim
local va  = v.api
local vd  = v.diagnostic
local vf  = v.fn
local strlen = string.len

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


local preprocess = function(d)
  local tbl   = {}
  local type  = { 'Error', 'Warn', 'Info', 'Hint' }

  for i = 1, #d do
    table.insert(tbl, {
      msg     = d[i].message,
      src     = F.chop(d[i].source),
      sev     = d[i].severity,
      sev_str = type[d[i].severity],

      ln    = d[i].lnum+1,
      col   = d[i].col+1,
      ecol  = d[i].end_col,
    })
  end

  return tbl
end


local format_diag = function(t, d)
  local str

  if t == 'dir' then
    str = d.msg..' ('..d.src..')'
  else
    local col
    col = d.col <= d.ecol and d.col..'-'..d.ecol or d.col
    str = d.msg..' '..'col:'..col
  end

  return str
end


local format_header = function(type, d)
  local d_icon = { '', '', '', '' }

  local str
  if type == 'dir' then
    str = d_icon[d.sev]..' '..d.sev_str..' at <'..d.ln..':'..d.col..'>'
  else
    str = ' Diagnostics in line <'..d.ln..'>'
  end

  return str
end


local set_highlights = function(bufnr, t, d)
  local neutral     = 'NeutralFloat'
  local neutral_sp  = 'NeutralFloatSp'
  local diag_hl_hdr = { 'ErrorFloatSp', 'WarningFloatSp', 'InfoFloatSp',  'HintFloatSp' }
  local diag_hl_bdy = { 'ErrorFloat',   'WarningFloat',   'InfoFloat',    'HintFloat' }
  local hl, len

  -- header
  if t == 'dir' then
    hl  = diag_hl_hdr[d[1].sev]
    len = strlen(d[1].sev_str) + 4 -- multibyte shenanigans
    va.nvim_buf_add_highlight(bufnr, -1, hl,      0,  0, len)
    va.nvim_buf_add_highlight(bufnr, -1, neutral, 0, len+1, -1)
  else
    hl  = 'InfoFloatSp'
    -- TODO: modularize
    len = strlen(' Diagnostics in line ') - 1 -- multibyte shenanigans
    va.nvim_buf_add_highlight(bufnr, -1, hl,      0, 0, len)
    va.nvim_buf_add_highlight(bufnr, -1, neutral, 0, len+1, -1)
  end

  -- separator
  va.nvim_buf_add_highlight(bufnr, -1, neutral, 1, 0, -1)

  -- body
  for i = 1, #d do
    hl  = diag_hl_bdy[d[i].sev]
    len = strlen(d[i].msg)
    if t == 'dir' then
      va.nvim_buf_add_highlight(bufnr, -1, hl,          i+1, 0, len)
      va.nvim_buf_add_highlight(bufnr, -1, neutral_sp,  i+1, len+1, -1)
    else
      va.nvim_buf_add_highlight(bufnr, -1, hl,          i+1, 0, len)
      va.nvim_buf_add_highlight(bufnr, -1, neutral_sp,  i+1, len+1, -1)
    end
  end
end


local render = function(t, d)
  local lines = {}
  local max_width = 72
  local processed = preprocess(d)

  -- format window contents
  for i = 1, #processed do table.insert(lines, format_diag(t, processed[i])) end

  -- move cursor to diagnostic
  if t == 'dir' then vf.cursor(processed[1].ln, processed[1].col) end

  -- insert header
  local width = get_longest_line(lines)
  table.insert(lines, 1, string.rep('', width % max_width))
  table.insert(lines, 1, format_header(t, processed[1]))

  -- do floaty stuff
  v.defer_fn(function()
    local bufnr = v.lsp.util.open_floating_preview(lines, 'off', {
      focusable = true,
      wrap      = true,
      wrap_at   = max_width,
      max_width = max_width,

      style     = 'minimal',
      border    = 'rounded',

      close_events = { 'CursorMoved', 'InsertEnter' }
    })
    set_highlights(bufnr, t, processed)
  end, 0)
end




-- main
M.goto_next = function()
  local d = vd.get_next()
  if    d then render('dir', { d }) end
end
M.goto_prev = function()
  local d = vd.get_prev()
  if    d then render('dir', { d }) end
end
M.get_line = function()
  local d     = vd.get(0, { lnum = vf.line('.') - 1 })
  if    d[1] ~= nil then render('line', d) end
end


return M
