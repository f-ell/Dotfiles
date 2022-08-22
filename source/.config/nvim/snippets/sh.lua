local _space_if = function(node_index)
  return f(function(args)
    if args[1][1] ~= '' then return ' ' end
  end, {node_index})
end

local _gen_test_var = function(jump_pos, node_index, quote_trigger)
  return d(jump_pos,
    function(args)
      local result = sn(nil, {t'$', i(1)})

      for _, trigger in ipairs(quote_trigger) do
        if trigger == '*' or args[1][1] == '-'..trigger then
          result = sn(nil, {t'"$', i(1), t'"'})
          break
        end
      end

      return result
    end, {node_index})
end

local snippets = {
  -- hashbang
  s('_#!',
    fmt('#!/bin/sh', {})
  ),

  -- empty_tests
  s('_[',
    fmt('[ {} {} ] {} ', {
      c(1, {t'-z', t'-n'}),
      _gen_test_var(2, 1, {'n'}),
      c(3, {t'&&', t'||'})
    })
  ),

  -- file_tests
  s('_]',
    fmt('[{}{} {}{}{} ] {} ',{
      _space_if(1),
      c(1, {t'', t'!'}),
      c(2, {t'-e', t'-f', t'-d', i()}),
      _space_if(2),
      _gen_test_var(3, 2, {'*'}),
      c(4, {t'&&', t'||'})
    })
  ),
}

return snippets, {}
