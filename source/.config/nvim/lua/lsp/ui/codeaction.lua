-- inspired by glepnir's Lspsaga: https://github.com/glepnir/lspsaga.nvim
local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vf  = v.fn
local vl  = v.lsp

local M = {}




local preprocess = function(raw)
  local ret = {}
  local idx = 1

  for _, res in pairs(raw) do
    local ind = (#raw > 9 and idx < 10) and true or false
    table.insert(ret, {
      idx = idx, ind = ind, msg = res.result.title, src = res.name
    })
    idx = idx + 1
  end

  return ret
end


local format = function(proc)
  local ret = {}

  for _, r in pairs(proc) do
    local prefix = ' '..r.idx..'  '
    if r.ind then prefix = prefix..' ' end

    table.insert(ret, prefix..r.msg..' ('..r.src..')')
  end

  return ret
end


local set_highlights = function(bufnr, proc)
  local hlgr = { 'HintFloatInv', 'InfoFloatInv', 'WarningFloatInv', 'ErrorFloatInv' }

  for i = 1, #proc do
    local hlidx = i % #hlgr ~= 0 and i % #hlgr or 4
    local len = 2 + string.len(proc[i].idx)

    -- header
    va.nvim_buf_add_highlight(bufnr, -1, 'InfoFloatSp', 0, 0, -1)
    va.nvim_buf_add_highlight(bufnr, -1, 'NeutralFloat', 1, 0, -1)

    -- prefix
    va.nvim_buf_add_highlight(bufnr, -1, hlgr[hlidx], i+1, 0, len)

    -- TODO: jdtls entries are partially highlighted incorrectly
    -- body
    va.nvim_buf_add_highlight(bufnr, -1, 'NeutralFloatSp', i+1, len+#proc[i].msg, -1)
  end
end


local register_float_actions = function(data)
  local do_action = function(num)
    L.win.close(data.nwin, data.owin, data.pos)
    if data.res[num].result.edit then
      L.lsp.apply_edit(data.res[num])
    else
      v.lsp.buf.code_action({ filter = function(c)
        return c.title == data.res[num].result.title and true or false
      end, apply = true })
    end
  end

  -- register execute and abort keymaps
  L.key.nnmap('<C-c>', function()
    L.win.close(data.nwin, data.owin, data.pos) end, { buffer = true })
  L.key.nnmap('<CR>', function()
    local num = vf.line('.') - 2
    if num < 1 then return end
    do_action(num)
  end, { buffer = true })

  for i = 1, data.len do
    L.key.nnmap(tostring(i), function() do_action(i) end, { buffer = true})
  end

  -- disable unwanted keys
  for _, lhs in pairs({ 'h', 'l', 'w', 'W', 'b', 'B', 'e', 'E', 'f', 'F', 't', 'T', 'v', 'V', '<C-v>' }) do
    L.key.nnmap(lhs, '', { buffer = true })
  end

  -- register autocommands
  L.cmd.event({ 'WinLeave', 'QuitPre' }, data.nbuf, function()
    L.win.close(data.nwin, data.owin, data.pos) end)
end


local open = function(raw)
  local proc = preprocess(raw)
  local content = format(proc)

  -- insert header and separator
  table.insert(content, 1, ' Code Actions')
  table.insert(content, 2, L.win.separator(content))

  local data = L.win.open_cursor(content, false, true)
  data.res = raw
  data.pos = va.nvim_win_get_cursor(data.owin)
  data.len = #content - 2

  set_highlights(data.nbuf, proc)
  va.nvim_win_set_cursor(data.nwin, { 3, 0 })
  register_float_actions(data)
end


local try_action = function()
  local params    = vl.util.make_range_params()
  params.context  = { diagnostics = vl.diagnostic.get_line_diagnostics(0) }

  local res = L.lsp.request(L.lsp.clients_by_cap('codeAction'),
    'textDocument/codeAction', params, 0)
  if L.tbl.is_empty(res) then return end

  open(res)
end




M.codeaction = function() try_action() end
return M
