import os

config.load_autoconfig(False)
c.changelog_after_upgrade      = 'major'
c.input.mode_override          = 'normal'
c.input.partial_timeout        = 2
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True

c.fonts.default_size          = '10pt'
c.fonts.default_family        = 'Ellograph CF'
c.fonts.web.family.standard   = 'Ellograph CF'
c.fonts.web.family.cursive    = 'Ellograph CF'
c.fonts.web.family.fixed      = 'Ellograph CF'
c.fonts.web.family.fantasy    = 'Ellograph CF'
c.fonts.web.family.serif      = 'Ellograph CF'
c.fonts.web.family.sans_serif = 'Ellograph CF'
c.messages.timeout            = 4000
c.editor.command              = ['nvim', '{file}']
c.colors.webpage.darkmode.enabled       = False
c.colors.webpage.preferred_color_scheme = 'light'
c.colors.webpage.darkmode.policy.images = 'never'
c.colors.webpage.bg                     = '#fffbef'

c.window.title_format = 'qutebrowser'
c.window.transparent  = True
c.url.start_pages     = f"{os.environ.get('XDG_CONFIG_HOME', os.environ['HOME'] + '/.config')}/browser/index.html"
c.url.default_page    = f"{os.environ.get('XDG_CONFIG_HOME', os.environ['HOME'] + '/.config')}/browser/index.html"
c.zoom.levels = [
    '25%', '50%', '75%', '100%', '125%', '150%', '175%', '200%', '300%'
]

c.prompt.radius     = 6
c.scrolling.bar     = 'overlay'
c.scrolling.smooth  = True
c.statusbar.widgets = ['keypress', 'url', 'history']

c.tabs.show            = 'multiple'
c.tabs.padding         = { 'top': 4, 'right': 4, 'bottom': 4, 'left': 4 }
c.tabs.tooltips        = True
c.tabs.last_close      = 'default-page'
c.tabs.undo_stack_size = 16
c.tabs.favicons.show   = 'always'

c.colors.prompts.fg            = '#9aa79d'
c.colors.prompts.selected.fg   = '#859289'
c.colors.prompts.selected.bg   = '#ffffff00'

c.hints.border          = '0px solid #fffbef'
c.hints.leave_on_load   = True
c.colors.hints.fg       = '#374247'
c.colors.hints.bg       = '#a7c080'
c.colors.hints.match.fg = '#859289'

c.colors.statusbar.normal.fg            = '#374247'
c.colors.statusbar.normal.bg            = '#a7c080'
c.colors.statusbar.insert.fg            = '#374247'
c.colors.statusbar.insert.bg            = '#7fbbb3'
c.colors.statusbar.command.fg           = '#374247'
c.colors.statusbar.command.bg           = '#d699b6'
c.colors.statusbar.caret.fg             = '#374247'
c.colors.statusbar.caret.bg             = '#e67e80'
c.colors.statusbar.passthrough.fg       = '#374247'
c.colors.statusbar.passthrough.bg       = '#e67e80'
c.colors.statusbar.caret.selection.fg   = '#374247'
c.colors.statusbar.caret.selection.bg   = '#e67e80'
c.colors.statusbar.progress.bg          = '#fdf6e3'

c.colors.completion.fg                          = '#fdf6e3'
c.colors.completion.odd.bg                      = '#374247'
c.colors.completion.even.bg                     = '#374247'
c.colors.completion.match.fg                    = '#e67e80'
c.colors.completion.category.fg                 = '#a7c080'
c.colors.completion.category.bg                 = '#374247'
c.colors.completion.category.border.top         = '#374247' 
c.colors.completion.category.border.bottom      = '#374247'
c.colors.completion.item.selected.fg            = '#fdf6e3'
c.colors.completion.item.selected.bg            = '#434f55'
c.colors.completion.item.selected.border.top    = '#434f55'
c.colors.completion.item.selected.border.bottom = '#434f55'
c.colors.completion.item.selected.match.fg      = '#e67c80'
c.colors.completion.scrollbar.fg                = '#525c62'
c.colors.completion.scrollbar.bg                = '#374247'

c.colors.contextmenu.menu.fg     = '#fdf6e3'
c.colors.contextmenu.menu.bg     = '#374247'
c.colors.contextmenu.selected.fg = '#e67e80'
c.colors.contextmenu.selected.bg = '#434f55'
c.colors.contextmenu.disabled.fg = '#525c62'
c.colors.contextmenu.disabled.bg = '#374247'

c.colors.downloads.bar.bg        = '#374247'
c.colors.downloads.start.fg      = '#a7c080'
c.colors.downloads.start.bg      = '#374247'
c.colors.downloads.stop.fg       = '#8da101'
c.colors.downloads.stop.bg       = '#374247'
c.colors.downloads.error.fg      = '#e67e80'
c.colors.downloads.error.bg      = '#374247'

c.colors.messages.warning.fg     = '#dbbc7f'
c.colors.messages.warning.bg     = '#374247'
c.colors.messages.warning.border = '#374247'
c.colors.messages.error.fg       = '#e67e80'
c.colors.messages.error.bg       = '#374247'
c.colors.messages.error.border   = '#374247'

c.colors.statusbar.url.fg               = '#374247'
c.colors.statusbar.url.warn.fg          = '#dbbc7f'
c.colors.statusbar.url.error.fg         = '#e67e80'
c.colors.statusbar.url.hover.fg         = '#525c62'
c.colors.statusbar.url.success.http.fg  = '#374247'
c.colors.statusbar.url.success.https.fg = '#374247'

c.colors.tabs.bar.bg            = '#4a555b'
c.colors.tabs.odd.fg            = '#fdf6e3'
c.colors.tabs.odd.bg            = '#4a555b'
c.colors.tabs.even.fg           = '#fdf6e3'
c.colors.tabs.even.bg           = '#4a555b'
c.colors.tabs.selected.odd.fg   = '#fdf6e3'
c.colors.tabs.selected.odd.bg   = '#374247'
c.colors.tabs.selected.even.fg  = '#fdf6e3'
c.colors.tabs.selected.even.bg  = '#374247'
c.colors.tabs.indicator.start   = '#374247'
c.colors.tabs.indicator.stop    = '#a7c080'
c.colors.tabs.indicator.error   = '#e67e80'
c.colors.tabs.pinned.odd.fg     = '#374247'
c.colors.tabs.pinned.odd.bg     = '#a7c080'
c.colors.tabs.pinned.even.fg    = '#374247'
c.colors.tabs.pinned.even.bg    = '#a7c080'

c.completion.height                = 200
c.completion.shrink                = True
c.completion.cmd_history_max_items = 16
c.completion.open_categories       = ['searchengines', 'bookmarks', 'history']
c.history_gap_interval             = 0
c.confirm_quit                     = ['downloads']

c.content.blocking.enabled                = False
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
c.downloads.location.directory      = f"{os.environ['HOME']}/Downloads"
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
