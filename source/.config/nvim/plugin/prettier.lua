local L   = require('utils.lib')
local v   = vim
local va  = v.api

local augroup = va.nvim_create_augroup('prettier', { clear = true })
local fs_info = {
  env_usr = os.getenv('USER'),
  env_dir = os.getenv('TMPDIR'),
  ft = { '*.js', '*.[cm]js', '*.ts', '*.[jt]sx' }
}

fs_info.dir = fs_info.env_dir == nil and '/tmp' or fs_info.env_dir
fs_info.dir = fs_info.env_usr == nil
  and fs_info.dir or fs_info.dir..'/nvim.'..fs_info.env_usr

fs_info.fn = fs_info.dir..'/nvim_prettier'..v.loop.os_getpid()


local write_tmpfile = function(lines)
  fs_info.fh = assert(io.open(fs_info.fn, 'w+'), 'couldn\'t open '..fs_info.fn)

  assert(
    fs_info.fh:write(table.concat(lines, '\n')),
    'couldn\'t write to '..fs_info.fn
  )

  fs_info.fh:close()
end




-- Save buffer to temporary file and update current buffer with prettier output
va.nvim_create_autocmd('BufWritePre', {
  group   = augroup,
  pattern = fs_info.ft,
  desc = 'Run buffer contents through prettier before writing to file.',
  callback = function()
    if not v.bo.modified then return end

    write_tmpfile(va.nvim_buf_get_lines(0, 0, -1, true))

    local fh = L.open({ 'prettier',
      '--cache-strategy', 'content', '--cache',
      '--parser', v.bo.filetype, fs_info.fn }, false, '')

    local lines = {}
    for ln in L.read_no_chop(fh):gmatch('(.-)\r?\n') do
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
