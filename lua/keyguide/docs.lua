-- ================================================================================================
-- TITLE : keyguide.docs
-- ABOUT : renders DOCS.md (the cheat sheet) from the registry. Run :KeysExport after editing
--         lua/keyguide/registry.lua.
-- ================================================================================================

local keyguide = require("keyguide")
local registry = require("keyguide.registry")
local format = require("keyguide.format")

local M = {}

-- GitHub heading anchor
local function slug(name)
	return (name:lower():gsub("[^%w%s%-_]", ""):gsub(" ", "-"))
end

local function code(text)
	text = text:gsub("|", "\\|")
	if text:find("`", 1, true) then
		return "`` " .. text .. " ``"
	end
	return "`" .. text .. "`"
end

-- plain text in a table cell: escape what markdown would treat as formatting or HTML
local function cell(text)
	return (text:gsub("[|*_]", "\\%0"):gsub("<", "&lt;"))
end

local function keys_cell(e)
	if e.display then
		return code(e.display)
	end
	if type(e.keys) == "string" then
		return code(format.pretty(e.keys))
	end
	local parts = {}
	for _, k in ipairs(e.keys) do
		parts[#parts + 1] = code(format.pretty(k))
	end
	return table.concat(parts, " / ")
end

local function from_cell(e)
	if e.src == "config" then
		return e.file and code((e.file:gsub("^lua/", ""))) or "config"
	elseif e.src == "plugin" then
		return e.plugin or "plugin"
	end
	return "built-in"
end

local function what_cell(e, brief)
	local text = cell(e.desc)
	local extra = {}
	-- "inside the fff finder" & co. are already said by the section heading
	if e.scope and not (e.scope:match("^inside") or e.scope:match("^while")) then
		extra[#extra + 1] = "Works in " .. e.scope .. "."
	end
	if e.note and not brief then
		extra[#extra + 1] = e.note
	end
	if #extra > 0 then
		text = text .. "<br>*" .. cell(table.concat(extra, " ")) .. "*"
	end
	return text
end

local function table_lines(entries, brief)
	local out = {
		"| Keys | Mode | What it does | From |",
		"| --- | --- | --- | --- |",
	}
	for _, e in ipairs(entries) do
		out[#out + 1] = string.format(
			"| %s | %s | %s | %s |",
			keys_cell(e),
			format.mode_long(e.mode),
			what_cell(e, brief),
			from_cell(e)
		)
	end
	return out
end

local INTRO = [[
# Neovim keymap guide

Every shortcut in this config, plus the built-in and plugin keys worth knowing.

> **Search all of this inside Neovim:** press `Space k` (or run `:Keys`) and describe what you want
> in your own words: *"rename variable"*, *"close file"*, *"who wrote this line"*, *"split screen"*.
> Typos are fine. Type a key like *"space f f"* or *"ctrl d"* to see what it does, and press
> `Enter` to run the selected shortcut.

This file is generated from `lua/keyguide/registry.lua` by `:KeysExport`. Edit the registry (not
this file) when you add or change a keymap, then run `:KeysExport` again.

## How to read the keys

| Written as | Means |
| --- | --- |
| `Space f f` | Press Space, then `f`, then `f`, one after another. Space is the *leader* key, written `<leader>` in the config files. |
| `Ctrl+d` | Hold Ctrl and press `d`. |
| `Alt+j` | Hold Alt (Option on a Mac) and press `j`. |
| `Shift+Tab` | Hold Shift and press Tab. |
| `gcc` | Press `g`, `c`, `c` one after another. |
| `:w` | A command: type it (starting with `:`) and press Enter. |
| `Ctrl+j / Ctrl+n` | Either key does the same thing. |

**Modes.** *Normal* mode is the default: keys are commands. *Insert* mode is for typing text (enter
with `i`, leave with `Esc`). *Visual* mode is for selecting (`v`, `V`, `Ctrl+v`). *Command* mode is
the `:` line. *Operator-pending* means right after `d`, `c` or `y` (that's where text objects go).

Tip: press `Space` and wait a moment. A popup (which-key) shows every key that can follow.
]]

--- DOCS.md content as a list of lines.
---@return string[]
function M.render()
	local entries = keyguide.entries()
	local by_cat = {}
	for _, e in ipairs(entries) do
		by_cat[e.cat] = by_cat[e.cat] or {}
		table.insert(by_cat[e.cat], e)
	end

	local lines = vim.split(INTRO, "\n", { plain = true })

	local starter = {}
	for _, e in ipairs(entries) do
		if e.starter then
			starter[#starter + 1] = e
		end
	end
	table.sort(starter, function(a, b)
		return a.starter < b.starter
	end)
	vim.list_extend(lines, { "## Start here", "", "The keys you'll use every day.", "" })
	vim.list_extend(lines, table_lines(starter, true))
	lines[#lines + 1] = ""

	lines[#lines + 1] = "## Contents"
	lines[#lines + 1] = ""
	for _, c in ipairs(registry.categories) do
		lines[#lines + 1] = string.format("- [%s](#%s)", c.name, slug(c.name))
	end
	lines[#lines + 1] = ""

	for _, c in ipairs(registry.categories) do
		lines[#lines + 1] = "## " .. c.name
		lines[#lines + 1] = ""
		if c.about then
			lines[#lines + 1] = c.about
			lines[#lines + 1] = ""
		end
		vim.list_extend(lines, table_lines(by_cat[c.id] or {}))
		lines[#lines + 1] = ""
	end
	while lines[#lines] == "" do
		lines[#lines] = nil
	end
	return lines
end

return M
