-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local v   = vim
local va  = v.api
local vf  = v.fn
local vl  = v.lsp

local M = {}




-- auxiliary
local get_anchor_offset = function()
    local anchor = v.fn.winline() - (v.fn.winheight(0) / 2) > 0 and 'SW' or 'NW'
    local offset = anchor == 'NW' and 1 or 0
    return anchor, offset
end


local highlight_refs = function(data)
  local client = vl.get_active_clients({ buffer = data.origin_buf })[1]
  local ref_provider = client.server_capabilities.referencesProvider
  if not ref_provider or ref_provider == false then
    return v.notify('No reference provider found.', 3)
  end

  local params = vl.util.make_position_params()
  params.context = { includeDeclaration = true }

  client.request('textDocument/references', params,
    function(_, res)
      if not res or next(res) == nil then return end
      for _, r in pairs(res) do
        if r.range then
          va.nvim_buf_add_highlight(data.origin_buf, data.ns_id, 'Search',
            r.range.start.line, r.range.start.character, r.range['end'].character)
        end
      end
    end)
end


local register_float_actions = function(data)
  local close_win = function()
    if not va.nvim_win_is_valid(data.winnr) then return end
    v.cmd('stopinsert')
    va.nvim_win_close(data.winnr, true)
    va.nvim_buf_clear_namespace(data.origin_buf, data.ns_id, 0, -1)
    va.nvim_win_set_cursor(data.origin_win, data.pos)
  end

  local do_rename = function()
    data.new = v.trim(va.nvim_get_current_line())
    close_win()

    if not (data.new and #data.new > 0) or data.new == data.old then return end

    va.nvim_win_set_cursor(data.origin_win, data.pos)
    vl.buf.rename(data.new, {})
    va.nvim_win_set_cursor(data.origin_win, { data.pos[1], data.pos[2] + 1 })
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
  v.api.nvim_create_autocmd({ 'WinLeave', 'QuitPre' }, {
    buffer    = data.bufnr,
    callback  = function() close_win() end
  })
end


local open = function(cword)
  local origin_buf = va.nvim_get_current_buf()
  local origin_win = va.nvim_get_current_win()
  local ns_id = va.nvim_create_namespace('LspUtilsNS')
  local bufnr = va.nvim_create_buf(false, true)
  v.bo[bufnr].bufhidden = 'wipe'

  local data = {
    origin_buf = origin_buf,
    origin_win = origin_win,
    bufnr = bufnr,
    winnr = nil,
    ns_id = ns_id,
    pos   = va.nvim_win_get_cursor(origin_win),
    old   = cword
  }

  highlight_refs(data)

  -- floaty stuff
  local anchor, offset = get_anchor_offset()
  local min_w, max_w = math.min(v.o.columns, 18), math.min(v.o.columns, 36)
  local len = cword:len()

  local width = len < min_w and min_w or len + 1
  if len > max_w then width = max_w end

  local winnr = va.nvim_open_win(bufnr, true, {
    width     = width,
    height    = 1,

    relative  = 'cursor',
    anchor    = anchor,
    row       = offset,
    col       = 0,

    style   = 'minimal',
    border  = 'rounded'
  })
  data.winnr = winnr

  register_float_actions(data)

  va.nvim_buf_set_lines(bufnr, 0, -1, false, { cword })
  v.cmd('norm! v$')
  va.nvim_feedkeys(va.nvim_replace_termcodes('<C-g>', true, true, true), 'n', false)
end


local try_rename = function(cword, proj)
  if not cword or cword == '' then return v.notify('Nothing to rename.', 2) end
  open(cword)
end




-- main
M.rename = function() try_rename(vf.expand('<cword>'), false) end
-- TODO: add project-wide rename
M.proj_rename = function() try_rename(vf.expand('<cword>'), true) end
return M
