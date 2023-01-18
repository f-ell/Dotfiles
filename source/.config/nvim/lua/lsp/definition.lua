-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local v   = vim
local va  = v.api
local vl  = v.lsp

local M = {}


-- auxiliary
local prepare_result_data = function(res)
  local ret = {}
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


local is_valid_window = function(winnr)
  if va.nvim_get_current_win() == winnr
    and va.nvim_win_is_valid(winnr) then return true end
  return false
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

  -- register close autocommands
  va.nvim_create_autocmd('QuitPre', {
    buffer    = bufnr,
    once      = true,
    callback  = function()
      if not is_valid_window(winnr) then return end
      va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    end
  })

  va.nvim_create_autocmd('WinLeave', {
    buffer    = bufnr,
    once      = true,
    callback  = function()
      if not is_valid_window(winnr) then return end
      va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
      va.nvim_win_close(winnr, false)
    end
  })
end


local open = function(data)
  local bufnr = v.uri_to_bufnr(data.uri)
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

  set_highlights(bufnr, winnr, data)
  va.nvim_win_set_cursor(winnr, data.start)
  v.cmd('norm! zt')
end




-- main
-- TODO: consider using tressitter api to select target node and only display implementation in float (can use open_floating_preview())
M.peek = function()
  vl.buf_request_all(0, 'textDocument/definition',
    vl.util.make_position_params(), function(res)
      if not res or next(res) == nil then v.notify('Lsp response is nil.', 3) return end

      local result
      for _, r in pairs(res) do
        if r.result then result = r.result end
      end
      if not result then v.notify('Lsp response is nil.', 3) return end

      open(prepare_result_data(result))
    end
  )
end


return M
