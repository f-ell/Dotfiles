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
  local fh
  local head  = ''

  fh        = io.popen('git rev-parse --is-inside-work-tree 2>/dev/null', 'r')
  local git = F.chop(fh:read('*a')); fh:close()

  if git == 'true' then
    fh    = io.popen('git branch --show-current', 'r')
    head  = F.chop(fh:read('*a')); fh:close()
    if head == '' then
      fh    = io.popen('git rev-parse @', 'r')
      head  = fh:read('*a'); fh:close()
      head  = head:sub(1, 7)
    end
    head = strf(' %s %s%s', '%#SlGit#', head, '%#SlDef#')
  end
  return head
end

M.get_bufnr = function()
  return '%n'
end

M.get_filename = function()
  local filename = '%t'
  local readonly, reset = '', ''

  if vim.api.nvim_buf_get_option(0, 'readonly') then
    readonly  = '%#SlRo# '
    reset     = ' %#SlDef#'
  end

  return strf('%s%s%s', readonly, filename, reset)
end

M.get_modified = function()
  local modified_status = ''

  if vim.api.nvim_buf_get_option(0, 'modified') then
    modified_status = '-*- '
  end

  return modified_status
end

M.get_filetype = function()
  -- return string.format(' %s ', vim.fn.fnamemodify(vim.fn.expand('%'), ':e:e:e'))

  local filetype = vim.bo.filetype

  local get_icon_filetype = filetype
  -- FILETYPE EXCEPTIONS
  if      filetype == 'perl'        then get_icon_filetype = 'pl'
  elseif  filetype == 'javascript'  then get_icon_filetype = 'js'
  end

  local icon = require('nvim-web-devicons')
    .get_icon(get_icon_filetype, {default = true})

  local icon_and_filetype = ''
  if filetype ~= '' then
    if icon == nil then
      icon_and_filetype = strf('%s | ', filetype)
    else
      icon_and_filetype = strf('%s %s | ', icon, filetype)
    end
  end

  return icon_and_filetype
end

M.get_position = function()
  return '%l:%v'
end


M.set_statusline = function()
  local reset = '%#SlDef#'
  local mode_colour = M:get_mode_colour(vim.api.nvim_get_mode().mode)

  local mode
    = strf('%s %s %s', mode_colour, M:get_mode(), reset)

  local git = M:get_git()

  local modified  = M:get_modified()
  local filename  = strf('%s%s', M:get_filename(), reset)
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


_G.set_statusline = M.set_statusline
F.o('laststatus', 3)
F.o('statusline', '%!v:lua.set_statusline()')
