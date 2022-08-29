local ls  = require('luasnip')
local c   = ls.choice_node
local d   = ls.dynamic_node
local f   = ls.function_node
local i   = ls.insert_node
local s   = ls.snippet
local t   = ls.text_node
local sn  = ls.snippet_node
local fmt = require('luasnip.extras.fmt').fmt

local M = {}


M.space_if = function(node_index)
  return f(function(args)
    if args[1][1] ~= '' then return ' ' end
  end, {node_index})
end

M.gen_test_var = function(jump_pos, node_index, quote_trigger)
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


return M
