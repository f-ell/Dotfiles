---@diagnostic disable: undefined-global

-- Status:children_remove(id, Status.LEFT|Status.RIGHT)
--
-- function Status:greet()
-- 	return ui.Line({ ui.Span("hi mom"):fg("magenta") })
-- end
--
-- Status:children_add("greet", 1000, Status.RIGHT)

function Status:mode()
	local mode = tostring(self._tab.mode):sub(1, 1):upper()

	return ui.Line({
		ui.Span(" " .. mode .. " "):style(self:style()),
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
		local style = THEME.status.permissions_t
		if c == "-" or c == "?" then
			style = THEME.status.permissions_s
		elseif c == "r" then
			style = THEME.status.permissions_r
		elseif c == "w" then
			style = THEME.status.permissions_w
		elseif c == "x" or c == "s" or c == "S" or c == "t" or c == "T" then
			style = THEME.status.permissions_x
		end
		spans[i] = ui.Span(c):style(style)
	end

	table.insert(spans, 1, ui.Span(" "))
	table.insert(spans, #spans + 1, ui.Span(" "))

	return ui.Line(spans)
end

function Status:size()
	local h = self._tab.current.hovered
	if not h then
		return ui.Line({})
	end

	return ui.Line({
		ui.Span(" " .. ya.readable_size(h:size() or h.cha.length) .. " ")
			:fg(self:style().bg)
			:bg(THEME.status.separator_style.bg),
	})
end

function Status:position()
	local cursor = self._tab.current.cursor
	local length = #self._tab.current.files

	return ui.Line({
		ui.Span(string.format(" %2d/%-2d ", cursor + 1, length)):style(self:style()),
	})
end

Status._left = {
	{ "mode", id = nil, order = 1 },
	{ "name", id = nil, order = 2 },
}
Status._right = {
	{ "permissions", id = nil, order = 1 },
	{ "size", id = nil, order = 2 },
	{ "position", id = nil, order = 3 },
}
