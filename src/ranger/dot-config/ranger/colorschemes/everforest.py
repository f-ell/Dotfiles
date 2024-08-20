# Ivaylo Kuzev <ivkuzev@gmail.com>, 2014
# Zenburn like colorscheme for https://github.com/hut/ranger .

# default colorscheme.
# Copyright (C) 2009-2013  Roman Zimbelmann <hut@lepus.uberspace.de>
# This software is distributed under the terms of the GNU GPL version 3.

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import default_colors, reverse, bold, normal, default


# pylint: disable=too-many-branches,too-many-statements
class everforest(ColorScheme):
    progress_bar_color = 12

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse
            else:
                attr = normal
            if context.empty or context.error:
                fg = 7
                bg = 16
            if context.border:
                fg = 2
            if context.image:
                fg = 4
            if context.video:
                fg = 5
            if context.audio:
                fg = 2
            if context.document:
                fg = 7
            if context.container:
                attr |= bold
                fg = 1
            if context.directory:
                attr |= bold
                fg = 3
            elif context.executable and not \
                    any((context.media, context.container,
                         context.fifo, context.socket)):
                attr |= bold
                fg = 1
            if context.socket:
                fg = 8
                attr |= bold
            if context.fifo or context.device:
                fg = 3
                if context.device:
                    attr |= bold
            if context.link:
                fg = 4 if context.good else 1
            if context.bad:
                bg = 9
            if context.tag_marker and not context.selected:
                attr |= bold
                fg = 7
            if not context.selected and (context.cut or context.copied):
                fg = 8
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = 10
            if context.badinfo:
                if attr & reverse:
                    bg = 9
                else:
                    fg = 9

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = 7
            elif context.directory:
                fg = 7
            elif context.tab:
                if context.good:
                    bg = 8
            elif context.link:
                fg = 4

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 6
                elif context.bad:
                    fg = 1
            if context.marked:
                attr |= bold | reverse
                fg = 5
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 3
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = 4
                attr &= ~bold
            if context.vcscommit:
                fg = 6
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 7

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = 1
            elif context.vcschanged:
                fg = 4
            elif context.vcsunknown:
                fg = 8
            elif context.vcsstaged:
                fg = 2
            elif context.vcssync:
                fg = 4
            elif context.vcsignored:
                fg = default

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync:
                fg = 4
            elif context.vcsbehind:
                fg = 1
            elif context.vcsahead:
                fg = 2
            elif context.vcsdiverged:
                fg = 5
            elif context.vcsunknown:
                fg = 8

        return fg, bg, attr
