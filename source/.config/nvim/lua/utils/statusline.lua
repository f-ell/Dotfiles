local F     = require('utils.functions')
local strf  = string.format


M = {}


M.get_mode = function()
  local mode = vim.api.nvim_get_mode().mode

  if      mode == 'V'   then mode = 'VL'
  elseif  mode == ''  then mode = 'VB' end

  return mode:upper()
end

M.get_mode_colour = function()
  local mode = vim.api.nvim_get_mode().mode

  if      mode == 'V' or mode == '' then mode = 'v'
  elseif  mode == 'nt'                then mode = 'n' end

  return strf('%s%s#', '%#mode', mode:upper())
end

M.get_git = function()
  -- au WinEnter,BufEnter * let b:branch_info = system('git rev-parse --is-inside-work-tree 2>/dev/null')
  -- local branch_info = vim.b.branch_info
  -- if branch_info then branch_info = strf('  %s ', branch_info) end
  -- return branch_info

  -- local branch = ''
  -- if os.execute('git ls-files % 2>/dev/null') ~= '' then branch = strf('  %s', 'git') end

  local branch = ''

  local fh = io.popen('git ls-files --error-unmatch % 2>/dev/null')
  if fh ~= nil then
    if fh:read('*a') ~= '' then
      branch = 'hey there'
    end
    fh:close()
  end
  -- if branch ~= '' then branch = strf('  %s', 'git') end
  return branch
end

M.get_bufnr = function()
  return '%n'
end

M.get_filename = function()
  local filename = '%t'
  local readonly, bgreset = '', ''

  if vim.api.nvim_buf_get_option(0, 'readonly') then
    readonly  = '%#ro# '
    bgreset   = ' %#bg#'
  end

  return strf('%s%s%s', readonly, filename, bgreset)
end

M.get_modified = function()
  local modified_status = ''

  if vim.api.nvim_buf_get_option(0, 'modified') then
    modified_status = '-+- '
  end

  return modified_status
end

M.get_filetype = function()
  -- return string.format(' %s ', vim.fn.fnamemodify(vim.fn.expand('%'), ':e:e:e'))

  local file_name = vim.fn.expand('%')
  local file_ext  = vim.fn.expand(file_name..':e')
  local file_icon = require('nvim-web-devicons')
    .get_icon(file_name, file_extension, {default = true})

  local filetype      = vim.bo.filetype
  local filetype_icon = ''
  if filetype ~= '' then
    filetype_icon = strf('%s %s | ', file_icon, filetype)
  end

  return filetype_icon
end

M.get_position = function()
  return '%l:%v'
end


M.set_statusline = function()
  local bg = '%#bg#'
  local mode_colour = M:get_mode_colour(vim.api.nvim_get_mode().mode)

  local mode
    = strf('%s %s %s', mode_colour, M:get_mode(), bg)

  local git = M:get_git()

  local modified  = M:get_modified()
  local filename  = strf('%s%s', M:get_filename(), bg)
  local bufnr     = strf('(%s)', M:get_bufnr())

  local filetype  = strf('%s %s', mode_colour, M:get_filetype())
  local position  = M:get_position()

  return table.concat({
    mode, '%<', git,
    '%=',
    modified, filename, bufnr,
    '%=',
    filetype, position, ' '
  })
end


F.gset('laststatus', 3)
F.gset('statusline', '%!v:lua.M.set_statusline()')
