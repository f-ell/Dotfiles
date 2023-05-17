-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vl  = v.lsp

local M = {}




local preprocess = function(raw)
  local ret = { cword = raw.cword, switch = raw.sw }

  local res = raw.res
  if type(res[1]) == 'table' then res = res[1] end
  ret.uri = res.result.uri or res.result.targetUri

  local range = res.result.range or res.result.targetSelectionRange
  ret.start = { range.start.line + 1, range.start.character }
  ret._end  = { range['end'].line + 1, range['end'].character }

  return ret
end


local set_highlights = function(bufnr, proc)
  local ns_id = va.nvim_create_namespace('LspUi')
  va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  va.nvim_buf_add_highlight(bufnr, ns_id, 'Search', proc.start[1] - 1,
    proc.start[2], proc._end[2])

    -- TODO: revise this for multi-line highlights
  if proc._end[1] > proc.start[1] then
    local current = proc.start[1]
    local last    = proc._end[1]

    while current < last do
      va.nvim_buf_add_highlight(bufnr, ns_id, 'Search', current, 0, -1)
      current = current + 1
    end
    va.nvim_buf_add_highlight(bufnr, ns_id, 'Search', last, 0, proc._end[2])
  end

  -- register mapping for clearing highlight
  L.key.nnmap('<C-l>', function()
    va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    L.key.unmap('n', '<C-l>', { buffer = true })
  end, { buffer = true, remap = false })
end


local register_float_actions = function(bufnr, winnr)
  local ns_id = va.nvim_create_namespace('LspUi')
  -- register close autocommands
  if winnr == nil then return end
  L.cmd.event('QuitPre', bufnr, function()
      if not L.win.is_cur_valid(winnr) then return end
      va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  end)
  L.cmd.event('WinLeave', bufnr, function()
      if not L.win.is_cur_valid(winnr) then return end
      va.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
      va.nvim_win_close(winnr, false)
  end)
end


local open = function(raw)
  local proc  = preprocess(raw)
  local bufnr = v.uri_to_bufnr(proc.uri)

  if proc.switch or bufnr == va.nvim_get_current_buf() then
    va.nvim_win_set_buf(0, bufnr)
    set_highlights(bufnr, proc)
    va.nvim_win_set_cursor(0, proc.start)
    return
  end

  local data = L.win.open_center(bufnr, true, true, { zindex = 1 })
  set_highlights(data.nbuf, proc)
  register_float_actions(data.nbuf, data.nwin)
  va.nvim_win_set_cursor(data.nwin, proc.start)
  v.cmd('norm! zt')
  v.wo.winbar = '%#TlActive# '..v.fn.expand('%')..' %#blank#'
end


-- TODO: consider using tressitter api to select target node and only display implementation in float (can use open_floating_preview())
local try_definition = function(switch)
  local res = L.lsp.request(L.lsp.clients_by_cap('definition'),
    'textDocument/definition', vl.util.make_position_params(), 0)
  if L.tbl.is_empty(res) then return end

  open({ cword = v.fn.expand('<cword>'), res = res, sw = switch })
end

local try_type_defintion = function()
  local res = L.lsp.request(L.lsp.clients_by_cap('typeDefinition'),
    'textDocument/typeDefinition', vl.util.make_position_params(), 0)
  if L.tbl.is_empty(res) then return end

  open({ cword = v.fn.expand('<cword>'), res = res })
end




M.peek = function() try_definition(false) end
M.open = function() try_definition(true) end
M.type = function() try_type_defintion() end
return M
