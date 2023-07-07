local snippets = {
  -- inline code
  s('_i',
    fmt('`{}`', { i(1) })
  ),

  -- block code
  s('_b',
    fmt('```{}\n{}\n```', { i(1), i(2) })
  )
}

return snippets, {}
