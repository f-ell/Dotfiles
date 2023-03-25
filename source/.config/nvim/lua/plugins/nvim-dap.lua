return {
  'mfussenegger/nvim-dap',
  lazy = true,
  keys = {
    -- TODO: dap.run() with only console window
    { '<leader>dr',     '<CMD>DapContinue<CR>' },
    { '<leader>dq',     '<CMD>DapTerminate<CR>' },
    { '<leader>di',     '<CMD>DapStepInto<CR>' },
    { '<leader>do',     '<CMD>DapStepOut<CR>' },
    { '<leader>d<S-o>', '<CMD>DapStepOver<CR>' },
    { '<leader>dc',     function() require('dap').clear_breakpoints() end },
    { '<leader>dt',     '<CMD>DapToggleBreakpoint<CR>' },
    { '<leader>du',     function() require('dapui').toggle() end }
  },
  dependencies = 'rcarriga/nvim-dap-ui',
  config = function()
    local L = require('utils.lib')
    local dap, ui = require('dap'), require('dapui')

    local signs = {
      { 'DapStopped',             '' },
      { 'DapLogPoint',            'L' },
      { 'DapBreakpoint',          'B' },
      { 'DapBreakpointCondition', 'C' },
      { 'DapBreakpointRejected',  'R' }
    }
    for _, sign in pairs(signs) do
      vim.fn.sign_define(sign[1], { texthl = sign[1], text = sign[2] })
    end

    ui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = function() ui.open() end

    local clients = L.lsp.clients_by_cap('executeCommand')
    local execute = function(clients, args)
      return L.lsp.request(clients, 'workspace/executeCommand', args, 0)
    end

    ----------------------------------------------------------------------- java
    local resolve = execute(clients, { command = 'vscode.java.resolveMainClass' })[1].result
    local main, proj = resolve.mainClass, resolve.project or ''
    local exec  = execute(clients, { command = 'vscode.java.resolveJavaExecutable', arguments = { main, proj }})[1].result
    local paths = execute(clients, { command = 'vscode.java.resolveClasspath',      arguments = { main, proj }})

    dap.configurations.java = {{
      name = 'launch '..proj..':'..main,
      type = 'java',
      request     = 'launch',
      console     = 'integratedTerminal',
      vmArgs      = '--enable-preview',
      javaExec    = exec,
      projectName = proj,
      mainClass   = main,
      modulePaths = paths[1].result or {},
      classPaths  = paths[2].result or {}
    }}
    dap.adapters.java = function(callback, _)
      L.lsp.request(clients, 'workspace/executeCommand',
        { command = 'vscode.java.startDebugSession' }, 0, function(tbl)
          assert(not tbl.err, vim.pretty_print(tbl.err))
          callback({ type = 'server', host = '127.0.0.1', port = tbl.result })
        end)
    end
  end
}
