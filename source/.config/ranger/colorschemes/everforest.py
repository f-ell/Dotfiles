# Ivaylo Kuzev <ivkuzev@gmail.com>, 2014
# Zenburn like colorscheme for https://github.com/hut/ranger .

# default colorscheme.
# Copyright (C) 2009-2013  Roman Zimbelmann <hut@lepus.uberspace.de>
# This software is distributed under the terms of the GNU GPL version 3.

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import default_colors, reverse, bold, normal, default


# pylint: disable=too-many-branches,too-many-statements
class everforest(ColorScheme):
    progress_bar_color = 8

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
                fg = 1
                bg = 17
            if context.border:
                fg = 9
            if context.image:
                fg = 7
            if context.video:
                fg = 15
            if context.audio:
                fg = 1
            if context.document:
                fg = 9
            if context.container:
                attr |= bold
                fg = 13
            if context.directory:
                attr |= bold
                fg = 15
            elif context.executable and not \
                    any((context.media, context.container,
                         context.fifo, context.socket)):
                attr |= bold
                fg = 13
            if context.socket:
                fg = 2
                attr |= bold
            if context.fifo or context.device:
                fg = 15
                if context.device:
                    attr |= bold
            if context.link:
                fg = 7 if context.good else 13
            if context.bad:
                bg = 14
            if context.tag_marker and not context.selected:
                attr |= bold
                fg = 1
            if not context.selected and (context.cut or context.copied):
                fg = 2
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = 10
            if context.badinfo:
                if attr & reverse:
                    bg = 14
                else:
                    fg = 14

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = 1
            elif context.directory:
                fg = 1
            elif context.tab:
                if context.good:
                    bg = 2
            elif context.link:
                fg = 7

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 5
                elif context.bad:
                    fg = 13
            if context.marked:
                attr |= bold | reverse
                fg = 11
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 15
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = 7
                attr &= ~bold
            if context.vcscommit:
                fg = 5
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 1

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
                fg = 13
            elif context.vcschanged:
                fg = 7
            elif context.vcsunknown:
                fg = 2
            elif context.vcsstaged:
                fg = 9
            elif context.vcssync:
                fg = 7
            elif context.vcsignored:
                fg = default

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync:
                fg = 7
            elif context.vcsbehind:
                fg = 13
            elif context.vcsahead:
                fg = 9
            elif context.vcsdiverged:
                fg = 11
            elif context.vcsunknown:
                fg = 2

        return fg, bg, attr
