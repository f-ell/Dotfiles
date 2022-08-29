local F = require('snippets.default_functions')

local snippets = {
  -- hashbang
  s('_#!',
    fmt('#!/bin/bash', {})
  ),

  -- empty_tests
  s('_[[',
    fmt('[[ {} {} ]] {} ', {
      c(1, {t'-z', t'-n'}),
      F.gen_test_var(2, 1, {'n'}),
      c(3, {t'&&', t'||'})
    })
  ),

  -- file_tests
  s('_]]',
    fmt('[[{}{} {}{}{} ]] {} ',{
      F.space_if(1),
      c(1, {t'', t'!'}),
      c(2, {t'-e', t'-f', t'-d', i()}),
      F.space_if(2),
      F.gen_test_var(3, 2, {'*'}),
      c(4, {t'&&', t'||'})
    })
  ),
}

return snippets, {}
