local L   = require('utils.lib')
local v   = vim
local va  = v.api
local vf  = v.fn


if vf.executable('prettier') ~= 1 then return end


local fs_info = {
  ft  = { '*.js', '*.[cm]js', '*.ts', '*.[jt]sx' },
  dir = vf.stdpath('run')..'/nvim.user'
}
fs_info.fn  = fs_info.dir..'/nvim_prettier'..v.loop.os_getpid()


-- INFO: for more efficient writing (prettier makes it slow enough as is), this
-- is only run once. Deleting or making fs_info.dir inaccessible while nvim is
-- running will break the autocommand.
if not v.loop.fs_stat(fs_info.dir) then
  local dir = v.loop.fs_mkdir(fs_info.dir, 111000000)
  if not dir then
    return v.notify('couldn\'t create temporary directory '..fs_info.dir, 4)
  end
end


local write_tmpfile = function(lines)
  fs_info.fh = assert(io.open(fs_info.fn, 'w+'), 'couldn\'t open '..fs_info.fn)

  assert(
    fs_info.fh:write(table.concat(lines, '\n')),
    'couldn\'t write to '..fs_info.fn
  )

  fs_info.fh:close()
end




-- Save buffer to temporary file and update current buffer with prettier output
local augroup = va.nvim_create_augroup('prettier', { clear = true })

va.nvim_create_autocmd('BufWritePre', {
  group   = augroup,
  pattern = fs_info.ft,
  desc = 'Run buffer contents through prettier before writing to file.',
  callback = function()
    if not v.bo.modified then return end

    write_tmpfile(va.nvim_buf_get_lines(0, 0, -1, true))

    local fh = L.util.open({ 'prettier',
      '--cache-strategy', 'content', '--cache',
      '--parser', v.bo.filetype, fs_info.fn }, false, '')

    local lines = {}
    for ln in L.util.read_no_chop(fh):gmatch('(.-)\r?\n') do
      table.insert(lines, ln)
    end

    va.nvim_buf_set_lines(0, 0, -1, true, lines)
  end
})


-- Remove temporary file when leaving instance
va.nvim_create_autocmd('VimLeavePre', {
  group   = augroup,
  pattern = fs_info.ft,
  desc = 'Remove temporary file.',
  callback = function()
    if io.type(fs_info.fh) == nil then return end
    if io.type(fs_info.fh) == 'file' then fs_info.fs:close() end

    assert(os.remove(fs_info.fn), 'couldn\'t remove temporary file '..fs_info.fn)
  end
})
