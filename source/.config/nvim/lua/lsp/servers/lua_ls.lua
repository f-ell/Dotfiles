return {
  before_init = require('neodev.lsp').before_init,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = {
        globals = { 'cmp', 'vim', 'use' }
      },
      telemetry = { enable = false }
    }
  }
}
