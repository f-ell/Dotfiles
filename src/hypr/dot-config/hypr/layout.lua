hl.on('window.close', function()
  local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
  if ws == nil then
    hl.notification.create({
      text = 'Invalid workspace.',
      timeout = 3000,
    })
    return
  end

  local count = #ws:get_windows() - 1
  if count == 1 and ws.tiled_layout == 'monocle' then
    hl.workspace_rule({
      workspace = tostring(ws.id),
      layout = LAYOUT,
    })
  end
end)
