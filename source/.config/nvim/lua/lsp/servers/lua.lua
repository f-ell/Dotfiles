return {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = {
        globals = {
          'cmp',
          'vim',
          'use'
        }
      },
      telemetry = {
        enable = false
      }
    }
  }
}
