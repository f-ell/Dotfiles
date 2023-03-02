-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vf  = v.fn
local vl  = v.lsp

local M = {}




local highlight_refs = function(data)
  local client = L.lsp.clients_by_cap('references')
  local params = vl.util.make_position_params(data.owin)
  params.context = { includeDeclaration = true }

  L.lsp.request(client, 'textDocument/references', params, data.obuf,
    function(res)
      for i=1, #res do
        local r = res[i].result
        if r.range then
          va.nvim_buf_add_highlight(data.obuf, data.ns_id, 'Search',
          r.range.start.line, r.range.start.character, r.range['end'].character)
        end
      end
  end)
end


local register_float_actions = function(data)
  local close_win = function()
    if not va.nvim_win_is_valid(data.nwin) then return end
    v.cmd('stopinsert')
    va.nvim_win_close(data.nwin, true)
    va.nvim_buf_clear_namespace(data.obuf, data.ns_id, 0, -1)
    va.nvim_win_set_cursor(data.owin, data.pos)
  end

  local do_rename = function()
    data.new = v.trim(va.nvim_get_current_line())
    close_win()

    if not (data.new and #data.new > 0) or data.new == data.old then return end

    va.nvim_win_set_cursor(data.owin, data.pos)
    vl.buf.rename(data.new, {})
    va.nvim_win_set_cursor(data.owin, { data.pos[1], data.pos[2] + 1 })
  end

  -- register execute and abort keymaps
  local modes = { 'n', 'i', 'v' }
  for _, m in pairs(modes) do
    v.keymap.set(m, '<C-c>', function() close_win() end, { buffer = true })

    if m ~= 'v' then
      v.keymap.set(m, '<CR>', function() do_rename() end, { buffer = true })
    end
  end

  -- register autocommands
  L.cmd.event({ 'WinLeave', 'QuitPre' }, data.nbuf, function() close_win() end)
end


local open = function(cword)
  local min_w, max_w = math.min(v.o.columns, 18), math.min(v.o.columns, 36)
  local len = cword:len()
  local w = len < min_w and min_w or len + 1
  if len > max_w then w = max_w end

  local data = L.win.open({ cword }, true, true, { width = w, col = -1 })
  data.ns_id = va.nvim_create_namespace('LspUtilNS')
  data.pos   = va.nvim_win_get_cursor(data.owin)
  data.old   = cword

  highlight_refs(data)
  register_float_actions(data)
  -- TODO: deprecate?
  va.nvim_feedkeys('A', 'n', true)
  -- v.cmd('norm v$')
  -- va.nvim_feedkeys(va.nvim_replace_termcodes('<C-g>', true, true, true), 'n', false)
end


local try_rename = function(cword, proj)
  if not cword or cword == '' then return v.notify('Nothing to rename.', 2) end
  open(cword)
end




M.rename = function() try_rename(vf.expand('<cword>'), false) end
-- TODO: add project-wide rename
M.proj_rename = function() try_rename(vf.expand('<cword>'), true) end
return M