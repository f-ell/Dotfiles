config.load_autoconfig(False)
c.changelog_after_upgrade      = 'major'
c.input.mode_override          = 'normal'
c.input.partial_timeout        = 2
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True

c.fonts.default_size          = '10pt'
c.fonts.default_family        = 'Azeret Mono'
#  c.fonts.web.family.standard   = 'Azeret Mono'
#  c.fonts.web.family.cursive    = 'Azeret Mono'
#  c.fonts.web.family.fixed      = 'Azeret Mono'
#  c.fonts.web.family.fantasy    = 'Azeret Mono'
#  c.fonts.web.family.serif      = 'Azeret Mono'
#  c.fonts.web.family.sans_serif = 'Azeret Mono'
c.messages.timeout          = 3000
c.editor.command            = ['nvim', '{file}']
#  c.colors.webpage.darkmode.enabled       = True
c.colors.webpage.preferred_color_scheme = 'dark'
c.colors.webpage.bg                     = '#374247'

c.window.title_format = 'qutebrowser'
c.window.transparent  = True
c.url.start_pages     = '/home/nico/.config/qutebrowser/index.html'
c.url.default_page    = '/home/nico/.config/qutebrowser/index.html'
c.zoom.levels         = ['25%', '50%', '75%', '100%', '125%', '150%', '175%', '200%', '300%']

c.prompt.radius     = 6
c.scrolling.bar     = 'overlay'
c.scrolling.smooth  = True
c.statusbar.widgets = ['keypress', 'url', 'history']

c.tabs.show            = 'multiple'
c.tabs.padding         = {'top': 3, 'right': 4, 'bottom': 3, 'left': 4}
c.tabs.tooltips        = False
c.tabs.last_close      = 'default-page'
c.tabs.undo_stack_size = 5
c.tabs.favicons.show   = 'never'

c.colors.prompts.fg            = '#9aa79d'
c.colors.prompts.selected.fg   = '#859289'
c.colors.prompts.selected.bg   = '#ffffff00'

c.hints.border          = '0px dashed #374247'
c.hints.leave_on_load   = True
c.colors.hints.fg       = '#374247'
c.colors.hints.bg       = '#83c092'
c.colors.hints.match.fg = '#859289'

c.colors.statusbar.normal.fg            = '#374247'
c.colors.statusbar.normal.bg            = '#63a072'
c.colors.statusbar.insert.fg            = '#374247'
c.colors.statusbar.insert.bg            = '#d3c6aa'
c.colors.statusbar.command.fg           = '#374247'
c.colors.statusbar.command.bg           = '#d699b6'
c.colors.statusbar.caret.fg             = '#374247'
c.colors.statusbar.caret.bg             = '#e67e80'
c.colors.statusbar.passthrough.fg       = '#374247'
c.colors.statusbar.passthrough.bg       = '#e67e80'
c.colors.statusbar.caret.selection.fg   = '#374247'
c.colors.statusbar.caret.selection.bg   = '#e67e80'
c.colors.statusbar.progress.bg          = '#d3c6aa'

c.colors.completion.fg                          = '#83c092'
c.colors.completion.odd.bg                      = '#374247'
c.colors.completion.even.bg                     = '#404c51'
c.colors.completion.match.fg                    = '#e67e80'
c.colors.completion.category.fg                 = '#da636a'
c.colors.completion.category.bg                 = '#2f383e'
c.colors.completion.category.border.top         = '#2f383e' 
c.colors.completion.category.border.bottom      = '#2f383e'
c.colors.completion.item.selected.fg            = '#569d79'
c.colors.completion.item.selected.bg            = '#4a555b'
c.colors.completion.item.selected.border.top    = '#4a555b'
c.colors.completion.item.selected.border.bottom = '#4a555b'
c.colors.completion.item.selected.match.fg      = '#da636a'
c.colors.completion.scrollbar.fg                = '#525c62'
c.colors.completion.scrollbar.bg                = '#374247'

c.colors.contextmenu.menu.fg     = '#83c092'
c.colors.contextmenu.menu.bg     = '#4a555b'
c.colors.contextmenu.selected.fg = '#35a77c'
c.colors.contextmenu.selected.bg = '#404c51'
#  c.colors.contextmenu.disabled.fg =
#  c.colors.contextmenu.disabled.bg =

c.colors.downloads.bar.bg        = '#374247'
c.colors.downloads.start.fg      = '#374247'
c.colors.downloads.start.bg      = '#83c092'
c.colors.downloads.stop.fg       = '#374247'
c.colors.downloads.stop.bg       = '#35a77c'
c.colors.downloads.error.fg      = '#da6362'
c.colors.downloads.error.bg      = '#374247'

c.colors.messages.warning.fg     = '#e67e80'
c.colors.messages.warning.bg     = '#374247'
c.colors.messages.warning.border = '#374247'
c.colors.messages.error.fg       = '#374247'
c.colors.messages.error.bg       = '#da6362'
c.colors.messages.error.border   = '#da6362'

c.colors.statusbar.url.fg               = '#374247'
c.colors.statusbar.url.warn.fg          = '#e67e80'
c.colors.statusbar.url.error.fg         = '#da6362'
c.colors.statusbar.url.hover.fg         = '#e0e0e0'
c.colors.statusbar.url.success.http.fg  = '#374247'
c.colors.statusbar.url.success.https.fg = '#374247'

c.colors.tabs.bar.bg            = '#4a555b'
c.colors.tabs.odd.fg            = '#9aa79d'
c.colors.tabs.odd.bg            = '#4a555b'
c.colors.tabs.even.fg           = '#9aa79d'
c.colors.tabs.even.bg           = '#4a555b'
c.colors.tabs.selected.odd.fg   = '#9aa79d'
c.colors.tabs.selected.odd.bg   = '#2f383e'
c.colors.tabs.selected.even.fg  = '#9aa79d'
c.colors.tabs.selected.even.bg  = '#2f383e'
c.colors.tabs.indicator.start   = '#83c092'
c.colors.tabs.indicator.stop    = '#83c092'
c.colors.tabs.indicator.error   = '#da6362'

c.completion.height                = 200
c.completion.shrink                = True
c.completion.cmd_history_max_items = 1
c.completion.open_categories       = ['searchengines', 'bookmarks', 'history']
c.history_gap_interval             = 0
c.confirm_quit                     = ['downloads']

c.content.blocking.enabled                = True
c.content.blocking.method                 = 'both'
c.content.blocking.hosts.block_subdomains = True
c.content.blocking.whitelist              = []
c.content.cookies.store                   = True
c.content.cookies.accept                  = 'no-3rdparty'
c.content.javascript.alert                = False
c.content.prefers_reduced_motion          = True
c.content.autoplay                        = False
c.content.media.audio_capture             = False
c.content.media.video_capture             = False

c.downloads.position                = 'bottom'
c.downloads.location.prompt         = True
c.downloads.location.directory      = '/home/nico/Downloads/'
c.downloads.open_dispatcher         = '/usr/bin/ranger'
c.fileselect.folder.command         = ['alacritty', '-e', 'ranger']
c.fileselect.single_file.command    = ['alacritty', '-e', 'ranger']
c.fileselect.multiple_files.command = ['alacritty', '-e', 'ranger']

config.bind('g', 'scroll-to-perc 0', 'normal')
config.bind('j', 'scroll-px 0 80', 'normal')
config.bind('k', 'scroll-px 0 -80', 'normal')
config.bind('H', 'back', 'normal')
config.bind('J', 'tab-prev', 'normal')
config.bind('K', 'tab-next', 'normal')
config.bind('L', 'forward', 'normal')

config.bind('<Ctrl+h>', 'tab-move -', 'normal')
config.bind('<Ctrl+j>', 'completion-item-focus next', 'command')
config.bind('<Ctrl+k>', 'completion-item-focus prev', 'command')
config.bind('<Ctrl+l>', 'tab-move +', 'normal')
config.bind('<Ctrl+r>', 'reload', 'normal')

c.aliases = {
    "cs": "config-source",
    "bl": "bookmark-list",
    "bo": "bookmark-load",
    "ba": "bookmark-add {url}",
    "bd": "bookmark-del",
    "qo": "quickmark-load",
    "qa": "quickmark-add {url}",
    "qd": "quickmark-del",
}
