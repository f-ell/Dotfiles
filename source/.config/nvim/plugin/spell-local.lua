-- Dynamically detects spellfiles in any of the buffer's base directory or any
-- of its parents (see 'spellname' below). Allows scoping spellfiles to certain
-- directories / projects, while still using global ones.
--
-- * walks the directory tree down to the directory
--   * of the first editing buffer (i.e. dirname), or
--   * to the directory nvim was invoked from (i.e. cwd)
-- * at each level, checks for the existence of a local spellfile (see
-- 'spellname' below)
-- * prepends any spellfiles it finds to 'spellfile'
-- * local spellfiles have higher precendence than ones defined globally

local spellname = '.spell-local.utf-8.add'
local stat

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  pattern = '*',
  callback = function()
    local cwd = vim.fn.expand('%:p') ~= ''
      and vim.fn.expand('%:p')
      or vim.loop.cwd()
    cwd = cwd:gsub('^.-://', '')

    stat = vim.loop.fs_stat(cwd)
    if (stat and stat.type == 'file') or not stat then
      cwd = vim.fs.dirname(cwd)
    end

    if not vim.endswith(cwd, '/') then cwd = cwd..'/' end

    local dir = ''
    local files = vim.bo.spellfile ~= ''
      and vim.fn.split(vim.bo.spellfile, ',')
      or {}

    for d in cwd:sub(2):gmatch('([^/]-)/') do
      dir = dir..'/'..d
      local file = dir..'/'..spellname

      stat = vim.loop.fs_stat(file)
      if stat and stat.type == 'file' then
        table.insert(files, 1, file)
      end
    end

    -- PERF: incurs a potentially significant runtime cost, but respects the
    -- users global spellfile, as well as any that are added at runtime
    local uniq = {}
    for _, v in ipairs(files) do
      if not vim.tbl_contains(uniq, v) then
        table.insert(uniq, v)
      end
    end

    vim.bo.spellfile = table.concat(uniq, ',')
  end
})
