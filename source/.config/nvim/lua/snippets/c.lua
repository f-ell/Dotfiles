local F = require('snippets.default_functions')

local snippets = {
  -- printf
  s('pf',
    fmt('printf("{}\\n"{});', {
      i(1),
      i(2)
    })
  ),
}

return snippets, {}
