-- local ls    = require('luasnip')
-- local snip  = ls.snippet
-- local c = ls.choice_node
-- local f = ls.function_node
-- local i = ls.insert_node
-- local t = ls.text_node
-- local fmt = require('luasnip.extras.fmt').fmt

local snippets = {
  -- hashbang
  s('_#!',
    fmt('#!/usr/bin/lua', {})
  ),

  -- require
  -- snip('req', { t'local ', i(1), t' = require(\'', c(2, {rep(1), i()}), t'\')' }),
  s('_req',
    fmt([[local {} = require('{}')]], {
      i(1),
      c(2, {rep(1), i()})
    })
  )
}

return snippets, {}
