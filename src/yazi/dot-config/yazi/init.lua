---@diagnostic disable: undefined-global

function Status:mode()
	local mode = tostring(self._tab.mode):sub(1, 1):upper()

	return ui.Line({
		ui.Span(" " .. mode .. " "):style(self:style().main),
	})
end

function Status:name()
	local h = self._tab.current.hovered
	if not h then
		return ui.Line({})
	end

	return ui.Line({
		ui.Span(" [ "):style(THEME.status.separator_style),
		ui.Span(h.name),
		ui.Span(" ] "):style(THEME.status.separator_style),
	})
end

function Status:permissions()
	local h = self._tab.current.hovered
	if not h then
		return ui.Line({})
	end

	local perm = h.cha:permissions()
	if not perm then
		return ui.Line({})
	end

	local spans = {}
	for i = 1, #perm do
		local c = perm:sub(i, i)
		local style = THEME.status.perm_type
		if c == "-" or c == "?" then
			style = THEME.status.perm_sep
		elseif c == "r" then
			style = THEME.status.perm_read
		elseif c == "w" then
			style = THEME.status.perm_write
		elseif c == "x" or c == "s" or c == "S" or c == "t" or c == "T" then
			style = THEME.status.perm_exec
		end
		spans[i] = ui.Span(c):style(style)
	end

	table.insert(spans, 1, ui.Span(" "))
	table.insert(spans, #spans + 1, ui.Span(" "))

	return ui.Line(spans)
end

function Status:owner()
	local h = self._tab.current.hovered
	local o, g = ya.user_name(h.cha.uid), ya.group_name(h.cha.gid)

	return ui.Line({
		ui.Span((" %s:%s "):format(o, g)):style(THEME.status.separator_style),
	})
end

function Status:size()
	local h = self._tab.current.hovered
	if not h then
		return ""
	end

	return ui.Line({
		ui.Span((" %6s "):format(ya.readable_size(h:size() or h.cha.len))):style(THEME.status.separator_style),
	})
end

function Status:position()
	local cur = self._tab.current.cursor
	local len = #self._tab.current.files

	return ui.Line({
		ui.Span((" %2d/%-2d "):format(cur + 1, len)),
	})
end

Status._left = {
	{ "mode", id = 1, order = 1000 },
	{ "name", id = 2, order = 2000 },
}
Status._right = {
	{ "perm", id = 3, order = 1000 },
	{ "owner", id = 4, order = 2000 },
	{ "size", id = 5, order = 3000 },
	{ "position", id = 6, order = 4000 },
}
