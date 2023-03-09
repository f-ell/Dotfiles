local v   = vim
local vf  = v.fn
local msn = vf.stdpath('data')..'/mason'
local mpc = msn..'/packages'

-- TODO: verify this works
local wsfolder = vf.expand('%:p')

local getroot = function(patterns)
  local dir = vf.expand('%:p:h')
  local getparent = function(p) return vf.fnamemodify(p, ':h') end

  while getparent(dir) ~= dir do
    for _, pattern in ipairs(patterns) do
      if v.loop.fs_stat(dir..'/'..pattern) then return dir end
    end
    dir = getparent(dir)
  end
end

return {
  cmd = {
    -- '/usr/lib/jvm/java-19-openjdk/bin/java',
    msn..'/bin/jdtls',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vf.glob(mpc..'/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', mpc..'/jdtls/config_linux',
    '-data', wsfolder
  },

  root_dir = getroot({ '.git', 'mvnw', 'gradlew' }),
  -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  settings = { java = {} },
  init_options = {
    bundles = {
      vf.glob(mpc..'/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'),
      vf.glob(mpc..'/java-test/extension/server/*.jar'),
      -- mpc..'/jdtls/lombok.jar'
    }
  }}
