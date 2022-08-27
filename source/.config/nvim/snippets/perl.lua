local snippets = {
  -- hashbang
  s('_#!',
    fmt('#!/usr/bin/perl', {})
  ),

  -- regex match - NOT YET FUNCTIONAL
  -- use function node to determine matching pair
  s('_match',
    fmt('/{}{}/', {
      c(1, {t'^$', t'^', t'$', t''}),
      i(2),
    })
  ),
}

return snippets, {}
