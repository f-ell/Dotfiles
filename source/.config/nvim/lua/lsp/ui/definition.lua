-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vl  = v.lsp

local M = {}




-- auxiliary
local preprocess = function(raw)
  local ret = { cword = raw.cword, switch = raw.sw }
  local res = raw.res
  local range

  if type(res[1]) == 'table' then
    ret.uri = res[1].uri or res[1].targetUri
    range   = res[1].targetSelectionRange
  else
    ret.uri = res.uri or res.targetUri
    range   = res.targetSelectionRange
  end

  local start = { range.start.line + 1, range.start.character }
  local _end  = { range['end'].line + 1, range['end'].character }

  ret.start = start
  ret._end  = _end
  return ret
end


local get_row_offset = function()
  local status  = v.o.laststatus
  local tabline = v.o.showtabline
  local offset  = 0

  if status == 1 and #va.nvim_tabpage_list_wins() > 1 or status > 1 then
    offset = offset + 1
  end
  if tabline == 1 and #va.nvim_list_tabpages() > 1 or tabline > 1 then
    offset = offset + 1
  end

  return v.o.cmdheight + offset
end


local set_highlights = function(bufnr, winnr, data)
  local ns_id = va.nvim_create_namespace('LspUtilsNS')

  va.nvim_buf_add_highlight(bufnr, ns_id, 'Search', data.start[1] - 1,
    data.start[2], data._end[2])

  if data.start[2] > data.start[1] + 1 then
    local current = data.start[1]
    local last    = data._end[1]

    while current < last do
      va.nvim_buf_add_highlight(bufnr, ns_id, 'Search', current, 0, -1)
      current = current + 1
    end
    va.nvim_buf_add_highlight(bufnr, ns_id, 'Search', last, 0, data._end[2])
  end

  -- register mapping for clearing highlight
  v.keymap.set('n', '<C-l>', function()
    va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    v.keymap.del('n', '<C-l>', { buffer = true })
  end, { buffer = true, remap = false })

  -- register close autocommands
  if winnr == nil then return end

  va.nvim_create_autocmd('QuitPre', {
    buffer    = bufnr,
    once      = true,
    callback  = function()
      if not L.win.is_valid(winnr) then return end
      va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    end
  })

  va.nvim_create_autocmd('WinLeave', {
    buffer    = bufnr,
    once      = true,
    callback  = function()
      if not L.win.is_valid(winnr) then return end
      va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
      va.nvim_win_close(winnr, false)
    end
  })
end


local open = function(raw)
  local proc  = preprocess(raw)
  local bufnr = v.uri_to_bufnr(proc.uri)

  if proc.switch or bufnr == va.nvim_get_current_buf() then
    if proc.switch then v.cmd('buffer '..bufnr) end

    set_highlights(bufnr, nil, proc)
    v.fn.cursor(proc.start[1], proc.start[2]+1)
    return
  end

  v.bo[bufnr].bufhidden = 'wipe'

  -- floaty stuff
  local w = math.floor(v.o.columns * 0.7)
  local h = math.floor(v.o.lines * 0.7)
  local winnr = va.nvim_open_win(bufnr, true, {
    width   = w,
    height  = h,

    relative  = 'editor',
    anchor    = 'NW';
    row = math.floor((v.o.lines - h) / 2) - get_row_offset(),
    col = math.floor((v.o.columns - w) / 2),

    style   = 'minimal',
    border  = 'rounded'
  })

  set_highlights(bufnr, winnr, proc)
  va.nvim_win_set_cursor(winnr, proc.start)
  v.cmd('norm! zt')
end


-- TODO: consider using tressitter api to select target node and only display implementation in float (can use open_floating_preview())
local request_definition = function(switch)
  vl.buf_request_all(0, 'textDocument/definition',
    vl.util.make_position_params(), function(res)
      if not res or next(res) == nil then v.notify('Lsp response is nil.', 3)
        return
      end

      local result
      for _, r in pairs(res) do
        if r.result then result = r.result end
      end
      if not result then v.notify('Lsp response is nil.', 3) return end

      open({ cword = v.fn.expand('<cword>'), res = result, sw = switch })
    end)
end




-- main
M.peek = function() request_definition(false) end
M.open = function() request_definition(true) end
return M
