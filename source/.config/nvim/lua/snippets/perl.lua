local snippets = {
  -- hashbang
  s('_!',
    fmt('{}\n{}{}\n\n', {
      t'#!/usr/bin/perl',
      t'use warnings; use strict;',
      c(1, {t' $\\ = "\\n";', t''})
    })
  )
}

return snippets, {}
