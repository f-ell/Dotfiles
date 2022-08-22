local snippets = {
  -- single backticks / inline code
  s('ibacktick',
    fmt('`{}`', {
      i(1)
    })
  ),

  -- triple backticks / block code
  s('bbacktick',
    fmt('```{}\n{}\n```', {
      i(1),
      i(2)
    })
  )
}

return snippets, {}
