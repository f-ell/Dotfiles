---@param count integer
local function unmonocle_if_count(count)
  ---@param win HL.Window
  return function(win)
    local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
    if ws == nil then
      hl.notification.create({
        text = 'Invalid workspace.',
        timeout = 3000,
      })
      return
    end

    if win.workspace.id ~= ws.id then
      return
    end

    if #ws:get_windows() == count and ws.tiled_layout == 'monocle' then
      hl.workspace_rule({
        workspace = tostring(ws.id),
        layout = LAYOUT,
      })
    end
  end
end

hl.on('window.close', unmonocle_if_count(1))
hl.on('window.close', unmonocle_if_count(2))
hl.on('window.move_to_workspace', unmonocle_if_count(1))
