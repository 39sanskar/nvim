-- ================================================================================================
-- TITLE : keyguide
-- ABOUT : searchable keymap guide. <leader>k (or :Keys [words]) opens a floating window where you
--         describe what you want to do in plain English and get the matching shortcuts.
--         :KeysSheet opens DOCS.md, :KeysExport regenerates DOCS.md from the registry.
-- FILES :
--   > registry.lua : the list of shortcuts (edit this when you change a keymap)
--   > search.lua   : plain English matching
--   > ui.lua       : the floating window
--   > docs.lua     : DOCS.md generator
-- ================================================================================================

-- the registry and helpers load on first use, so startup only pays for the commands below
local M = {}

M.docs_path = vim.fn.stdpath("config") .. "/DOCS.md"

-- keymaps found by scanning Neovim that the registry doesn't describe (yet)
local MORE = { id = "more", name = "More active keymaps" }

local function category_names()
	local names = {}
	for _, c in ipairs(require("keyguide.registry").categories) do
		names[c.id] = c.name
	end
	return names
end

--- Registry entries as plain records (positional fields named, false sentinels removed).
---@return table[]
function M.entries()
	local registry = require("keyguide.registry")
	local names = category_names()
	local starter_pos, starter_taken = {}, {}
	for i, id in ipairs(registry.starter) do
		starter_pos[id] = i
	end
	local out = {}
	for _, e in ipairs(registry.entries) do
		local first_key = type(e[1]) == "table" and e[1][1] or e[1]
		local starter_id = e[2] .. " " .. first_key
		local inside = e.scope and (e.scope:match("^inside") or e.scope:match("^while"))
		-- first non-window-specific match only: "n u" is Undo, not fugitive's u
		local is_starter = starter_pos[starter_id] and not inside and not starter_taken[starter_id]
		if is_starter then
			starter_taken[starter_id] = true
		end
		out[#out + 1] = {
			keys = e[1],
			mode = e[2],
			desc = e[3],
			tags = e.tags,
			scope = e.scope or nil,
			note = e.note,
			norun = e.norun or false,
			secondary = e.secondary or false,
			cmd = e.cmd,
			display = e.display,
			src = e.src,
			file = e.file or nil,
			plugin = e.plugin or nil,
			cat = e.cat,
			cat_name = names[e.cat],
			starter = is_starter and starter_pos[starter_id] or nil,
		}
	end
	return out
end

local function key_list(e)
	return type(e.keys) == "table" and e.keys or { e.keys }
end

local function is_command(e)
	return e.mode == "c"
end

-- keys that only exist inside a specific window (pickers, explorer, completion menu ...)
local function is_inside(e)
	return e.scope ~= nil and (e.scope:match("^inside") or e.scope:match("^while")) ~= nil
end

-- keymaps worth listing: has a description and isn't an internal / default-help mapping
local function useful(map)
	local lhs, desc = map.lhs, map.desc
	if not desc or desc == "" then
		return false
	end
	if lhs:match("^<Plug>") or lhs:match("^<SNR>") or lhs:find("Mouse>") then
		return false
	end
	return not (desc:match("^:help ") or desc:match("^which%-key%-trigger"))
end

local function readable_lhs(lhs)
	local leader = vim.g.mapleader
	if leader == " " then
		lhs = lhs:gsub("^<Space>", "<leader>"):gsub("^ ", "<leader>")
	elseif leader and leader ~= "" and lhs:sub(1, #leader) == leader then
		lhs = "<leader>" .. lhs:sub(#leader + 1)
	end
	return lhs
end

--- Entries for the guide window: the registry plus anything else currently mapped with a
--- description, and whether each registry shortcut is active in `buf`.
---@param buf integer buffer the guide was opened from
---@return table[]
function M.collect(buf)
	local entries = M.entries()
	local known = {}
	for _, e in ipairs(entries) do
		if not is_command(e) and not is_inside(e) then
			for _, k in ipairs(key_list(e)) do
				for m in e.mode:gmatch("[nxio]") do
					known[m .. "\0" .. vim.keycode(k)] = true
				end
			end
		end
	end

	-- is the shortcut mapped right now? (only checked for keymaps defined in this config)
	vim.api.nvim_buf_call(buf, function()
		for _, e in ipairs(entries) do
			if e.src == "config" and not is_command(e) and not is_inside(e) then
				e.active = vim.fn.maparg(key_list(e)[1], e.mode:sub(1, 1), false, true).lhs ~= nil
			end
		end
	end)

	local found, order = {}, {}
	for _, m in ipairs({ "n", "x", "i", "o" }) do
		local maps = vim.api.nvim_get_keymap(m)
		vim.list_extend(maps, vim.api.nvim_buf_get_keymap(buf, m))
		for _, map in ipairs(maps) do
			if useful(map) and not known[m .. "\0" .. vim.keycode(map.lhs)] then
				local lhs = readable_lhs(map.lhs)
				local id = lhs .. "\0" .. map.desc
				if found[id] then
					if not found[id].mode:find(m, 1, true) then
						found[id].mode = found[id].mode .. m
					end
				else
					found[id] = {
						keys = lhs,
						mode = m,
						desc = map.desc,
						src = "detected",
						scope = map.buffer ~= 0 and "this buffer only" or nil,
						active = true,
						cat = MORE.id,
						cat_name = MORE.name,
					}
					order[#order + 1] = found[id]
				end
			end
		end
	end
	vim.list_extend(entries, order)
	return entries
end

--- What pressing <CR> on an entry does. Returns a function to run, or nil and a reason.
---@param e table
---@return function|nil, string|nil
function M.action(e)
	local format = require("keyguide.format")
	if is_command(e) then
		local text = e.cmd or e.keys:sub(2)
		return function()
			vim.api.nvim_feedkeys(":" .. text, "n", false)
		end
	end
	local keys = format.pretty_keys(e.keys)
	if is_inside(e) then
		return nil, "This one works " .. e.scope .. "."
	end
	if e.active == false then
		return nil, "Not active in this buffer. It works in " .. (e.scope or "another context") .. "."
	end
	if e.norun or not e.mode:find("n") then
		if e.mode == "x" then
			return nil, "Select some text first (v or V), then press " .. keys .. "."
		elseif e.mode == "i" then
			return nil, "Use it while typing (Insert mode): " .. keys .. "."
		elseif e.mode == "t" then
			return nil, "Use it inside a terminal window (:terminal): " .. keys .. "."
		elseif e.mode:find("o") then
			return nil, "Use it after d, c, y or v, e.g. d + " .. format.pretty(key_list(e)[1]) .. "."
		end
		return nil, "Press it yourself in your file: " .. keys .. "."
	end
	local lhs = key_list(e)[1]
	return function()
		vim.api.nvim_feedkeys(vim.keycode(lhs), "m", false)
	end
end

--- Opens the guide window, optionally with a search already typed.
---@param query? string
function M.open(query)
	require("keyguide.ui").open(query)
end

--- Writes DOCS.md from the registry.
---@param path? string
function M.export(path)
	path = path or M.docs_path
	local lines = require("keyguide.docs").render()
	vim.fn.writefile(lines, path)
	vim.api.nvim_echo({ { "Keymap guide written to " .. path } }, false, {})
end

--- Opens DOCS.md read-only in a new tab.
function M.sheet()
	if vim.fn.filereadable(M.docs_path) == 0 then
		M.export()
	end
	vim.cmd("tabnew " .. vim.fn.fnameescape(M.docs_path))
	vim.bo.modifiable = false
	vim.bo.readonly = true
end

function M.setup()
	vim.api.nvim_create_user_command("Keys", function(args)
		M.open(args.args)
	end, { nargs = "*", desc = "Search keymaps in plain English" })
	vim.api.nvim_create_user_command("KeysSheet", M.sheet, { desc = "Open the keymap cheat sheet (DOCS.md)" })
	vim.api.nvim_create_user_command("KeysExport", function(args)
		M.export(args.args ~= "" and vim.fn.expand(args.args) or nil)
	end, { nargs = "?", complete = "file", desc = "Regenerate DOCS.md from the keymap guide" })
end

return M
