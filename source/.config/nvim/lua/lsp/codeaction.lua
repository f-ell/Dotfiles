-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local v   = vim
local va  = v.api
local vf  = v.fn
local vl  = v.lsp
local strlen = string.len

local M = {}




-- auxiliary
local get_anchor_offset = function()
    local anchor = vf.winline() - (vf.winheight(0) / 2) > 0 and 'SW' or 'NW'
    local offset = anchor == 'NW' and 1 or 0
    return anchor, offset
end


local get_longest_line = function(tbl)
  local max = 0
  for i = 1, #tbl do
    local len = strlen(tbl[i])
    if len > max then max = len end
  end
  return max
end


local preprocess = function(responses)
  local ret = {}
  local idx = 1

  for _, res in pairs(responses) do
    local ind = (#responses > 9 and idx < 10) and true or false
    table.insert(ret, {
      idx = idx, ind = ind, msg = res.action.title, src = res.name
    })
    idx = idx + 1
  end

  return ret
end


local format = function(res)
  local ret = {}

  for _, r in pairs(res) do
    local prefix = ' '..r.idx..'  '
    if r.ind then prefix = ' '..prefix end

    table.insert(ret, prefix..r.msg..' ('..r.src..')')
  end

  return ret
end


local set_highlights = function(bufnr, data)
  for i = 1, #data do
    local len = 2 + strlen(data[i].idx)
    if data[i].ind then len = len + 1 end

    -- prefix
    va.nvim_buf_add_highlight(bufnr, -1, 'CodeAction', i-1, 0, len)

    -- body
    va.nvim_buf_add_highlight(bufnr, -1, 'NeutralFloatSp', i-1, len+#data[i].msg, -1)
  end
end


local close_win = function(data)
  if not va.nvim_win_is_valid(data.winnr) then return end

  va.nvim_win_close(data.winnr, true)
  va.nvim_win_set_cursor(data.origin_win, data.pos)
end




local do_codeaction = function(data, num)
  local idx
  if num then idx = num
  else        idx = vf.line('.') end
  close_win(data)

  local response = data.res[idx]
  local action = response.action
  local client = v.lsp.get_client_by_id(response.id)

  if action.edit then
    vl.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end

  if action.action and type(action.action) == 'function' then action.action() end
end


local register_float_actions = function(data)
  -- register execute and abort keymaps
  v.keymap.set('n', '<C-c>',  function() close_win(data) end, { buffer = true })
  v.keymap.set('n', '<CR>',   function() do_codeaction(data) end, { buffer = true })
  for i = 1, data.len do
    v.keymap.set('n', tostring(i), function() do_codeaction(data, i) end,
      { buffer = true})
  end

  -- disable unwanted keys
  v.keymap.set('n', 'h',      '', { buffer = true })
  v.keymap.set('n', 'l',      '', { buffer = true })
  v.keymap.set('n', 'w',      '', { buffer = true })
  v.keymap.set('n', 'W',      '', { buffer = true })
  v.keymap.set('n', 'b',      '', { buffer = true })
  v.keymap.set('n', 'B',      '', { buffer = true })
  v.keymap.set('n', 'e',      '', { buffer = true })
  v.keymap.set('n', 'E',      '', { buffer = true })
  v.keymap.set('n', 'f',      '', { buffer = true })
  v.keymap.set('n', 'F',      '', { buffer = true })
  v.keymap.set('n', 't',      '', { buffer = true })
  v.keymap.set('n', 'T',      '', { buffer = true })
  v.keymap.set('n', 'v',      '', { buffer = true })
  v.keymap.set('n', 'V',      '', { buffer = true })
  v.keymap.set('n', '<C-v>',  '', { buffer = true })

  -- register autocommands
  va.nvim_create_autocmd({ 'WinLeave', 'QuitPre' }, {
    buffer    = data.bufnr,
    callback  = function() close_win(data) end
  })
end


local open = function(responses)
  local origin_win = va.nvim_get_current_win()
  local bufnr = va.nvim_create_buf(false, true)

  local processed = preprocess(responses)
  local content   = format(processed)
  va.nvim_buf_set_lines(bufnr, 0, -1, true, content)
  set_highlights(bufnr, processed)

  v.bo[bufnr].bufhidden   = 'wipe'
  v.bo[bufnr].modifiable  = false

  local data = {
    origin_win = origin_win,
    bufnr = bufnr,
    winnr = nil,
    pos   = va.nvim_win_get_cursor(origin_win),
    len   = #content,
    res   = responses
  }

  -- floaty stuff
  local anchor, offset = get_anchor_offset()
  local winnr = va.nvim_open_win(bufnr, true, {
    width   = get_longest_line(content),
    height  = #content,

    relative  = 'cursor',
    anchor    = anchor,
    row       = offset,
    col       = 0,

    style   = 'minimal',
    border  = 'rounded'
  })
  data.winnr = winnr

  register_float_actions(data)
end


local try_action = function()
  -- get capable clients
  local capable_clients = {}
  local buf = va.nvim_get_current_buf()
  local available_clients = vl.get_active_clients({ buffer = buf })

  for i = 1, #available_clients do
    if available_clients[i].server_capabilities.codeActionProvider then
      table.insert(capable_clients, available_clients[i])
    end
  end
  if #capable_clients == 0 then
    return v.notify('No codeaction provider found.', 3)
  end


  -- prepare lsp request
  local params    = vl.util.make_range_params()
  params.context  = { diagnostics = vl.diagnostic.get_line_diagnostics(0) }


  -- request and collect codeactions from all capable servers
  local responses = {}
  for i = 1, #capable_clients do
    local client  = capable_clients[i]
    local dict    = client.request_sync('textDocument/codeAction', params, 500, buf)
    if next(dict) == nil or dict.err then goto continue end

    for _, act in pairs(dict.result) do
      table.insert(responses, { id = client.id, name = client.name, action = act })
    end
    ::continue::
  end

  if next(responses) == nil then return v.notify('No code actions available.', 3) end
  open(responses)
end




-- main
M.codeaction = function() try_action() end
return M
