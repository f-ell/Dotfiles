local ls = require('luasnip')

local M = {
  snip  = ls.snippet,
  fmt   = require('luasnip.extras.fmt').fmt,
  rep   = require('luasnip.extras').rep,
  c = ls.choice_node,
  d = ls.dynamic_node,
  f = ls.function_node,
  i = ls.insert_node,
  t = ls.text_node,
  s = ls.snippet_node
}

M.space_if = function(node_index)
  return M.f(function(args)
    if args[1][1] ~= '' then return ' ' end
  end, {node_index})
end

M.gen_test_var = function(jump_pos, node_index, quote_trigger)
  return M.d(jump_pos,
    function(args)
      local result = M.s(nil, {M.t'$', M.i(1)})

      for _, trigger in ipairs(quote_trigger) do
        if trigger == '*' or args[1][1] == '-'..trigger then
          result = M.s(nil, {M.t'"$', M.i(1), M.t'"'})
          break
        end
      end

      return result
    end, {node_index})
end

return M
