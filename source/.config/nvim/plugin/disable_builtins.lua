local builtins = {
  'gzip',
  'man',
  'matchit',
  'matchparen',
  'netrwPlugin',
  'remote_plugins',
  'shada_plugin',
  'tarPlugin',
  '2html_plugin',
  'tutor_mode_plugin',
  'zipPlugin'
}

for _, plugin in pairs(builtins) do
  vim.g['loaded_' .. plugin] = true
end
