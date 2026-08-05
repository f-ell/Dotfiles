local animations = {
  {
    leaf = 'workspaces',
    enabled = true,
    speed = 1.5,
    bezier = 'default',
    style = 'fade',
  },
  {
    leaf = 'windows',
    enabled = true,
    speed = 0.8,
    bezier = 'default',
    style = 'gnomed',
  },
  { leaf = 'fade', enabled = true, speed = 0.6, bezier = 'default' },
  { leaf = 'border', enabled = true, speed = 4, bezier = 'default' },

  {
    leaf = 'fadeLayers',
    enabled = true,
    speed = 1.5,
    bezier = 'default',
  },
  -- Affects layer resizes (e.g. for Rofi); has no effect on initial layer creation.
  {
    leaf = 'layersIn',
    enabled = true,
    speed = 1,
    bezier = 'default',
    style = 'fade',
  },
}

for _, a in pairs(animations) do
  hl.animation(a)
end
