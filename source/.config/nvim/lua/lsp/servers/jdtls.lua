-- capabilities and extendedClientCapabilities via https://github.com/mfussenegger/nvim-jdtls
local vf  = vim.fn
local msn = vf.stdpath('data')..'/mason'
local mpc = msn..'/packages'

return {
  cmd = {
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
    '--jvm-arg=-javaagent:'..mpc..'/jdtls/lombok.jar',
    '-jar', vf.glob(mpc..'/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', mpc..'/jdtls/config_linux',
    '-data', vf.stdpath('data')..'/jdtls-workspace/'..vf.fnamemodify(vf.getcwd(), ':p:t')
  },

  handlers = {
    ['language/status'] = function(_, result) --[[ disable prints ]] end,
    ['$/progress'] = function(_, result, ctx) --[[ disable progress warnings ]] end
  },

  -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  settings = { java = {} },

  init_options = {
    bundles = {
      vf.glob(mpc..'/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'),
      vf.glob(mpc..'/java-test/extension/server/*.jar'),
    },

    extendedClientCapabilities = {
      classFileContentsSupport              = true,
      generateToStringPromptSupport         = true,
      hashCodeEqualsPromptSupport           = true,
      advancedExtractRefactoringSupport     = true,
      advancedOrganizeImportsSupport        = true,
      generateConstructorsPromptSupport     = true,
      generateDelegateMethodsPromptSupport  = true,
      moveRefactoringSupport                = true,
      overrideMethodsPromptSupport          = true,
      inferSelectionSupport = {
        'extractMethod',
        'extractVariable',
        'extractConstant',
        'extractVariableAllOccurrence'
      }
    }
  },

  capabilities = {
    textDocument = {
      codeAction = {
        codeActionLiteralSupport = {
          codeActionKind = {
            valueSet = {
              'source.generate.toString',
              'source.generate.hashCodeEquals',
              'source.organizeImports',
            }
          }
        }
      }
    }
  }
}
