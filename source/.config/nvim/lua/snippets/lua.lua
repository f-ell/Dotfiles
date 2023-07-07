local snippets = {
  -- require
  s('_req',
    fmt('local {} = require(\'{}{}\')', {
      i(1),
      rep(1),
      i(2)
    })
  )
}

return snippets, {}
