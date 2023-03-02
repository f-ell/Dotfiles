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

  local range = res.result.targetSelectionRange
  ret.start = { range.start.line + 1, range.start.character }
  ret._end  = { range['end'].line + 1, range['end'].character }

  return ret
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
    va.nvim_win_set_buf(0, bufnr)
    set_highlights(bufnr, nil, proc)
    va.nvim_win_set_cursor(0, proc.start)
    return
  end

  local data = L.win.open(bufnr, true, true)
  set_highlights(data.nbuf, data.nwin, proc)
  va.nvim_win_set_cursor(data.nwin, proc.start)
  v.cmd('norm! zt')
end


-- TODO: consider using tressitter api to select target node and only display implementation in float (can use open_floating_preview())
local try_definition = function(switch)
  local res = L.lsp.request(L.lsp.clients_by_cap('definition')[1],
    'textDocument/definition', vl.util.make_position_params(), 0)
  if L.tbl.is_empty(res) then return end

  open({ cword = v.fn.expand('<cword>'), res = res, sw = switch })
end




M.peek = function() try_definition(false) end
M.open = function() try_definition(true) end
return M
