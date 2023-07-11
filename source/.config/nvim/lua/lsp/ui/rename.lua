-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local L = require('utils.lib')
local M = {}


local highlight_refs = function(data)
  for i=1, #data.refs do
    local r = data.refs[i].result
    if r.range then
      vim.api.nvim_buf_add_highlight(data.obuf, data.ns_id, 'Search',
      r.range.start.line, r.range.start.character, r.range['end'].character)
    end
  end
end


local register_float_actions = function(data)
  local close_win = function()
    if not vim.api.nvim_win_is_valid(data.nwin) then return end
    vim.cmd('stopinsert')
    vim.api.nvim_win_close(data.nwin, true)
    vim.api.nvim_buf_clear_namespace(data.obuf, data.ns_id, 0, -1)
    vim.api.nvim_win_set_cursor(data.owin, data.pos)
  end

  local do_rename = function()
    data.new = vim.trim(vim.api.nvim_get_current_line())
    close_win()

    if not (data.new and #data.new > 0) or data.new == data.old then return end

    vim.api.nvim_win_set_cursor(data.owin, data.pos)
    vim.lsp.buf.rename(data.new, {})
    vim.api.nvim_win_set_cursor(data.owin, { data.pos[1], data.pos[2] + 1 })
  end

  -- register execute and abort keymaps
  L.key.modemap({ 'n', 'i', 'v' }, '<C-c>', function() close_win() end, { buffer = true })
  L.key.modemap({ 'n', 'i' }, '<CR>', function() do_rename() end, {buffer = true })

  -- register autocommands
  L.cmd.event({ 'WinLeave', 'QuitPre' }, data.nbuf, function() close_win() end)
end


local open = function(raw)
  local min_w, max_w = math.min(vim.o.columns, 18), math.min(vim.o.columns, 36)
  local len = raw.cword:len()
  local w = len < min_w and min_w or len + 1
  if len > max_w then w = max_w end

  vim.api.nvim_win_set_cursor(0, { raw.pos[1] + 1, raw.pos[2] })
  local data = L.win.open_cursor({ raw.cword }, true, true, { width = w, col = -1, zindex = 2 })
  data.ns_id = vim.api.nvim_create_namespace('LspUi')
  data.pos = vim.api.nvim_win_get_cursor(data.owin)
  data.old = raw.cword
  data.refs = raw.refs

  highlight_refs(data)
  register_float_actions(data)
  vim.api.nvim_feedkeys('A', 'n', true)
end


local try_rename = function()
  local client = L.lsp.clients_by_cap('references')
  local params = vim.lsp.util.make_position_params(0)
  params.context = { includeDeclaration = true }

  local refs = L.lsp.request(client, 'textDocument/references', params, 0)
  if L.tbl.is_empty(refs) then return end

  local ln, col = params.position.line, params.position.character

  local declaration
  for _, ref in pairs(refs) do
    local s, e = ref.result.range.start, ref.result.range['end']
    if s.line == ln and s.character <= col and e.character >= col then
      declaration = ref; break
    end
  end

  if not declaration then
    vim.notify('Could not get declaration for symbol under cursor.', 4)
    return
  end
  local s, e = declaration.result.range.start, declaration.result.range['end']
  local cword = declaration
    and vim.api.nvim_buf_get_text(0, s.line, s.character, e.line, e.character, {})[1]
    or ''

  open({ cword = cword, refs = refs, pos = { s.line, s.character } })
end


M.rename = function() try_rename() end
return M
