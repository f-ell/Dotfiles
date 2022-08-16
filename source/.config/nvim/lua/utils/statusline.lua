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
  -- branch = os.execute('git branch --show-current 2>/dev/null')
  local fh = io.popen('git branch --show-current 2>/dev/null', 'r')
    local branch = fh:read('*a')
  fh:close()

  if branch ~= '' then
    branch = string.reverse(branch)
    local char = string.sub(branch, 0, 1)
    branch = string.gsub(branch, char, '')
    branch = string.reverse(branch)
    branch = strf('  %s', branch)
  end
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

  local filetype = vim.bo.filetype

  -- FILETYPE EXCEPTIONS
  if      filetype == 'perl'        then filetype = 'pl'
  elseif  filetype == 'javascript'  then filetype = 'js'
  end

  local file_icon = require('nvim-web-devicons')
    .get_icon(filetype, {default = true})

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
  local filename  = strf('%s%s', M:get_filename(), bg) -- 'bg' for 'readonly'
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
