local snippets = {
  -- single backticks / inline code
  s('_ibt',
    fmt('`{}`', { i(1) })
  ),

  -- triple backticks / block code
  s('_bbt',
    fmt('```{}\n{}\n```', { i(1), i(2) })
  )
}

return snippets, {}
