local snippets = {
  -- hashbang
  s('_!',
    fmt('#!/usr/bin/lua', {})
  ),

  -- require
  s('_req',
    fmt([[local {} = require('{}')]], {
      i(1),
      c(2, {rep(1), i()})
    })
  )
}

return snippets, {}
