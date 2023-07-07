local snippets = {
  -- print
  s('_p',
    fmt('print!("{}\\n"{});', {
      i(1),
      i(2)
    })
  ),
}

return snippets, {}
