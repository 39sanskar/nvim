-- ================================================================================================
-- TITLE : keyguide.format
-- ABOUT : turns key notation ("<leader>ff", "<C-w>q") into readable text ("Space f f", "Ctrl+w q")
--         and mode letters into names. Shared by the floating guide and the DOCS.md generator.
-- ================================================================================================

local M = {}

local KEY_NAMES = {
	cr = "Enter",
	["return"] = "Enter",
	enter = "Enter",
	esc = "Esc",
	tab = "Tab",
	bs = "Backspace",
	space = "Space",
	up = "Up",
	down = "Down",
	left = "Left",
	right = "Right",
	insert = "Insert",
	del = "Delete",
	home = "Home",
	["end"] = "End",
	pageup = "PageUp",
	pagedown = "PageDown",
	bslash = "\\",
	lt = "<",
	bar = "|",
	["2-leftmouse"] = "Double-click",
}

local MODIFIERS = { c = "Ctrl", a = "Alt", m = "Alt", s = "Shift", d = "Cmd" }

local MODE_NAMES = {
	n = "Normal",
	x = "Visual",
	v = "Visual",
	i = "Insert",
	o = "Operator-pending",
	c = "Command",
	t = "Terminal",
}

-- short labels for the list column (max 8 cells)
local MODE_SHORT = {
	n = "normal",
	x = "visual",
	i = "insert",
	o = "op-pend",
	c = "command",
	t = "terminal",
	nx = "norm/vis",
	ox = "textobj",
	nxo = "motion",
	ni = "norm/ins",
}

--- Display name of the leader key ("Space" for the usual " ").
function M.leader_name()
	local leader = vim.g.mapleader
	if leader == nil then
		return "\\"
	end
	if leader == " " then
		return "Space"
	end
	return leader
end

-- "C-S-x" -> "Ctrl+Shift+x"
local function special_key(inner)
	local lower = inner:lower()
	if lower == "leader" then
		return M.leader_name(), true
	end
	if lower == "localleader" then
		local ll = vim.g.maplocalleader
		return (ll == " " and "Space") or ll or "\\", true
	end
	if KEY_NAMES[lower] then
		return KEY_NAMES[lower], false
	end

	local parts = vim.split(inner, "-", { plain = true })
	local key = parts[#parts]
	if key == "" and #parts > 1 then -- "<C-->"
		key = "-"
		table.remove(parts)
	end
	local words = {}
	local has_ctrl = false
	for i = 1, #parts - 1 do
		local mod = MODIFIERS[parts[i]:lower()]
		if not mod then
			return "<" .. inner .. ">", false
		end
		has_ctrl = has_ctrl or mod == "Ctrl"
		words[#words + 1] = mod
	end
	local lk = key:lower()
	if KEY_NAMES[lk] then
		key = KEY_NAMES[lk]
	elseif lk:match("^f%d+$") then
		key = key:upper()
	elseif has_ctrl and #key == 1 then
		key = lk -- Ctrl is case-insensitive
	end
	words[#words + 1] = key
	return table.concat(words, "+"), false
end

--- Readable form of a single key sequence: "<leader>ff" -> "Space f f", "<C-w>q" -> "Ctrl+w q".
---@param lhs string
---@return string
function M.pretty(lhs)
	if lhs:sub(1, 1) == ":" then
		return lhs
	end
	local tokens = {} -- { text, special }
	local after_leader = false
	local i = 1
	while i <= #lhs do
		local inner = lhs:match("^<([^<>%s]+)>", i)
		local brace = lhs:match("^({[^{}]+})", i)
		if inner then
			local text, is_leader = special_key(inner)
			tokens[#tokens + 1] = { text, true }
			after_leader = after_leader or is_leader
			i = i + #inner + 2
		elseif brace then
			tokens[#tokens + 1] = { brace, true }
			i = i + #brace
		else
			local ch = lhs:sub(i, i)
			local last = tokens[#tokens]
			if last and not last[2] and not after_leader then
				last[1] = last[1] .. ch -- glue plain characters: "gcc", "]d"
			else
				tokens[#tokens + 1] = { ch, after_leader }
			end
			i = i + 1
		end
	end
	local out = {}
	for _, t in ipairs(tokens) do
		out[#out + 1] = t[1]
	end
	return table.concat(out, " ")
end

--- Readable form of an entry's keys (one string or a list of alternatives).
--- `compact` shortens alternatives that share a modifier: "Ctrl+h / Ctrl+j" -> "Ctrl+h/j".
---@param keys string|string[]
---@param compact? boolean
---@return string
function M.pretty_keys(keys, compact)
	if type(keys) == "string" then
		return M.pretty(keys)
	end
	local out = {}
	for _, k in ipairs(keys) do
		out[#out + 1] = M.pretty(k)
	end
	local prefix = compact and #out > 1 and out[1]:match("^(.-%+)[^%+%s]+$")
	if prefix then
		local rest = {}
		for _, p in ipairs(out) do
			if p:sub(1, #prefix) ~= prefix or p:sub(#prefix + 1):find("[%+%s]") then
				return table.concat(out, " / ")
			end
			rest[#rest + 1] = p:sub(#prefix + 1)
		end
		return prefix .. table.concat(rest, "/")
	end
	return table.concat(out, " / ")
end

--- Raw notation of an entry's keys, as written in the config files.
function M.notation(keys)
	if type(keys) == "string" then
		return keys
	end
	return table.concat(keys, " / ")
end

--- "nx" -> "Normal + Visual"
function M.mode_long(mode)
	local names = {}
	for ch in mode:gmatch(".") do
		names[#names + 1] = MODE_NAMES[ch] or ch
	end
	return table.concat(names, " + ")
end

--- "nx" -> "norm/vis" (fits the list column)
function M.mode_short(mode)
	return MODE_SHORT[mode] or M.mode_long(mode):lower()
end

return M
