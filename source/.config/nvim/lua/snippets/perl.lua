local snippets = {
  -- hashbang
  s('_!',
    fmt('{}\n{}\n\n', {
      t'#!/usr/bin/perl',
      t'use warnings; use strict;',
    })
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
