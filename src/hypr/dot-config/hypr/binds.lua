---@class (exact) Bind
---@field key string
---@field dsp function|HL.Dispatcher
---@field opts HL.BindOptions?

---@param direction 'left'|'down'|'up'|'right'
local function focus(direction)
  return function()
    local win = hl.get_active_window()
    if win == nil then
      return
    end

    local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not ws then
      hl.notification.create({
        text = 'Invalid workspace.',
        timeout = 3000,
      })
      return
    end

    -- Normal focus passing.
    local layout = ws.tiled_layout
    if layout ~= 'monocle' then
      hl.dispatch(hl.dsp.focus({ direction = direction }))
      return
    end

    -- Allow passing focus sideways to adjacent monitors.
    if direction == 'left' or direction == 'right' then
      hl.dispatch(hl.dsp.focus({ direction = direction }))
      return
    end

    -- Monocle cycling.
    --
    -- FIX: this cycles in creation -- not layout -- order and causes weird
    -- reflow when windows are positioned out of order.
    hl.dispatch(
      hl.dsp.layout('cycle' .. (direction == 'up' and 'prev' or 'next'))
    )
  end
end

---@type table<string, Bind[]>
local binds = {
  misc = {
    { key = 'SUPER + SHIFT + W', dsp = hl.dsp.window.close() },
    { key = 'SUPER + CONTROL + Q', dsp = hl.dsp.exit() },
    {
      key = 'SUPER + F',
      dsp = hl.dsp.window.float({ action = 'toggle' }),
    },
    { key = 'SUPER + SHIFT + F', dsp = hl.dsp.window.fullscreen(0) },
    {
      key = 'SUPER + TAB',
      dsp = function()
        local ws = hl.get_active_special_workspace()
          or hl.get_active_workspace()
        if not ws then
          hl.notification.create({
            text = 'Invalid workspace.',
            timeout = 3000,
          })
          return hl.dsp.no_op()
        end

        hl.workspace_rule({
          workspace = tostring(ws.id),
          layout = ws.tiled_layout == 'monocle' and LAYOUT or 'monocle',
        })
      end,
    },
    { key = 'SUPER + mouse:272', dsp = hl.dsp.window.drag() },
    { key = 'SUPER + mouse:273', dsp = hl.dsp.window.resize() },
  },

  windows = {
    { key = 'SUPER + h', dsp = focus('left') },
    { key = 'SUPER + j', dsp = focus('down') },
    { key = 'SUPER + k', dsp = focus('up') },
    { key = 'SUPER + l', dsp = focus('right') },

    {
      key = 'SUPER + SHIFT + h',
      dsp = hl.dsp.window.swap({ direction = 'left' }),
    },
    {
      key = 'SUPER + SHIFT + j',
      dsp = hl.dsp.window.swap({ direction = 'down' }),
    },
    {
      key = 'SUPER + SHIFT + k',
      dsp = hl.dsp.window.swap({ direction = 'up' }),
    },
    {
      key = 'SUPER + SHIFT + l',
      dsp = hl.dsp.window.swap({ direction = 'right' }),
    },

    {
      key = 'SUPER + CONTROL + h',
      dsp = hl.dsp.window.resize({ x = -50, y = 0, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + CONTROL + j',
      dsp = hl.dsp.window.resize({ x = 0, y = 50, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + CONTROL + k',
      dsp = hl.dsp.window.resize({ x = 0, y = -50, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + CONTROL + l',
      dsp = hl.dsp.window.resize({ x = 50, y = 0, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + SHIFT + CONTROL + h',
      dsp = hl.dsp.window.resize({ x = 50, y = 0, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + SHIFT + CONTROL + j',
      dsp = hl.dsp.window.resize({ x = 0, y = -50, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + SHIFT + CONTROL + k',
      dsp = hl.dsp.window.resize({ x = 0, y = 50, relative = true }),
      opts = { repeating = true },
    },
    {
      key = 'SUPER + SHIFT + CONTROL + l',
      dsp = hl.dsp.window.resize({ x = -50, y = 0, relative = true }),
      opts = { repeating = true },
    },
  },

  workspaces = {
    { key = 'ALT + 1', dsp = hl.dsp.workspace.toggle_special('file') },
    { key = 'ALT + 2', dsp = hl.dsp.workspace.toggle_special('audio') },
    { key = 'ALT + 3', dsp = hl.dsp.workspace.toggle_special('mail') },
  },

  applications = {
    { key = 'SUPER + SHIFT + COMMA', dsp = hl.dsp.exec_cmd('hyprlock') },
    {
      key = 'SUPER + RETURN',
      dsp = hl.dsp.exec_cmd('footclient -D $HOME'),
    },
    {
      key = 'SUPER + R',
      dsp = hl.dsp.exec_cmd(
        'rofi -config $XDG_CONFIG_HOME/rofi/hypr.rasi -show drun -modes "drun,window"'
      ),
    },
    {
      key = 'SUPER + P',
      dsp = hl.dsp.exec_cmd(
        'rofi -config $XDG_CONFIG_HOME/rofi/hypr.rasi -show m -modes "m:$XDG_CONFIG_HOME/rofi/rofi-power"'
      ),
    },
    {
      key = 'SUPER + M',
      dsp = hl.dsp.exec_cmd(
        'slurp -d -c"a7c080" -b"323d4340" | grim -g - $HOME/Pictures/Screenshots/grim_`date +%Y%m%d-%H%M%S`.png'
      ),
    },
    {
      key = 'SUPER + SHIFT + M',
      dsp = hl.dsp.exec_cmd(
        'grim -c $HOME/Pictures/Screenshots/grim_`date +%Y%m%d-%H%M%S`.png'
      ),
    },
  },

  media = {
    {
      key = 'XF86AudioPlay',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox play-pause'),
    },
    {
      key = 'XF86AudioNext',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox next'),
    },
    {
      key = 'XF86AudioPrev',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox previous'),
    },
    {
      key = 'XF86AudioForward',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox position 5+'),
    },
    {
      key = 'XF86AudioRewind',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox position 5-'),
    },
    {
      key = 'XF86AudioRaiseVolume',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox volume 0.02+'),
    },
    {
      key = 'XF86AudioLowerVolume',
      dsp = hl.dsp.exec_cmd('playerctl -i firefox volume 0.02-'),
    },
  },
}

for _, category in pairs(binds) do
  for _, bind in pairs(category) do
    hl.bind(bind.key, bind.dsp, bind.opts)
  end
end

for _, ws in pairs(hl.get_workspaces()) do
  if ws.special then
    goto continue
  end

  hl.bind('SUPER + ' .. ws.id, hl.dsp.focus({ workspace = ws.id }))
  hl.bind(
    'SUPER + SHIFT + ' .. ws.id,
    hl.dsp.window.move({ workspace = ws.id, follow = false })
  )

  ::continue::
end
