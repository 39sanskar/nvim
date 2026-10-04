-- ================================================================================================
-- TITLE : keyguide.ui
-- ABOUT : the floating keymap guide: a prompt on top, matching shortcuts in the middle and the
--         selected shortcut's details at the bottom. Enter runs the selected shortcut.
-- ================================================================================================

local keyguide = require("keyguide")
local search = require("keyguide.search")
local format = require("keyguide.format")

local M = {}

local ns = vim.api.nvim_create_namespace("keyguide")
local PROMPT = "❯ "
local PLACEHOLDER = "describe what you want to do, e.g. rename variable · close file · space f f"
local MODE_W = 8
local DETAILS_H = 5
local FLOAT_HL = "Normal:NormalFloat,FloatBorder:FloatBorder"
local HINT = " Enter run · ↑/↓ move · Esc close "

local state = nil

local function set_highlights()
	local links = {
		KeyguideKey = "Function",
		KeyguideMode = "Comment",
		KeyguideCategory = "Comment",
		KeyguideMatch = "Special",
		KeyguideLabel = "Comment",
		KeyguideActive = "DiagnosticOk",
		KeyguideInactive = "DiagnosticWarn",
		KeyguideFlash = "WarningMsg",
	}
	for name, target in pairs(links) do
		vim.api.nvim_set_hl(0, name, { link = target, default = true })
	end
end

-- cut `s` to `width` display cells, ending with "…" when shortened
local function fit(s, width)
	if width <= 0 then
		return ""
	end
	if vim.fn.strdisplaywidth(s) <= width then
		return s
	end
	local chars = vim.fn.strchars(s)
	while chars > 0 and vim.fn.strdisplaywidth(vim.fn.strcharpart(s, 0, chars)) > width - 1 do
		chars = chars - 1
	end
	return vim.fn.strcharpart(s, 0, chars) .. "…"
end

local function pad(s, width)
	return s .. string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(s)))
end

local function key_text(e, compact)
	return e.display or format.pretty_keys(e.keys, compact)
end

local function layout()
	local columns = vim.o.columns
	local lines = vim.o.lines - vim.o.cmdheight
	local width = math.max(math.min(110, columns - 6), math.min(columns - 2, 30))
	local height = math.min(38, lines - 2)
	local show_details = height >= 18
	local list_h = math.max(3, height - 3 - 2 - (show_details and DETAILS_H + 2 or 0))
	local total = 3 + list_h + 2 + (show_details and DETAILS_H + 2 or 0)
	local row = math.max(0, math.floor((lines - total) / 2))
	local col = math.max(0, math.floor((columns - width - 2) / 2))
	local base = { relative = "editor", style = "minimal", border = "rounded", width = width, col = col, zindex = 60 }
	return {
		prompt = vim.tbl_extend("force", base, { row = row, height = 1 }),
		list = vim.tbl_extend("force", base, { row = row + 3, height = list_h, focusable = false }),
		details = show_details
				and vim.tbl_extend("force", base, { row = row + 3 + list_h + 2, height = DETAILS_H, focusable = false })
			or nil,
	}
end

local function valid_win(win)
	return win and vim.api.nvim_win_is_valid(win)
end

local function query()
	local line = vim.api.nvim_buf_get_lines(state.prompt_buf, 0, 1, false)[1] or ""
	if line:sub(1, #PROMPT) == PROMPT then
		line = line:sub(#PROMPT + 1)
	end
	return line
end

local function selected()
	return state.results[state.sel]
end

-- =============================================================================
-- RENDERING
-- =============================================================================

local function render_details()
	if not valid_win(state.details_win) then
		return
	end
	local buf = state.details_buf
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local r = selected()
	local lines, marks = {}, {}
	local function add(text, hl_ranges)
		lines[#lines + 1] = text
		for _, m in ipairs(hl_ranges or {}) do
			marks[#marks + 1] = { #lines - 1, m[1], m[2], m[3] }
		end
	end

	if state.flash then
		add(" " .. state.flash, { { 0, -1, "KeyguideFlash" } })
	end
	if r then
		local e = r.entry
		local keys = key_text(e)
		local notation = format.notation(e.keys)
		local head = " " .. keys
		local ranges = { { 1, #head, "KeyguideKey" } }
		if notation ~= keys and e.mode ~= "c" and not e.display then
			local from = #head
			head = head .. "   " .. notation
			ranges[#ranges + 1] = { from + 3, #head, "KeyguideLabel" }
		end
		local from = #head
		head = head .. "   " .. format.mode_long(e.mode) .. (e.mode == "c" and " (type it after :)" or " mode")
		ranges[#ranges + 1] = { from + 3, #head, "KeyguideLabel" }
		add(head, ranges)
		add(" " .. e.desc)

		local where = {}
		if e.scope then
			where[#where + 1] = "Works " .. (e.scope:match("^inside") and "" or "in ") .. e.scope
		end
		if e.active == true then
			where[#where + 1] = "✓ active here"
		elseif e.active == false then
			where[#where + 1] = "✗ not active in this buffer"
		end
		if #where > 0 then
			local text = " " .. table.concat(where, " · ")
			local hl = e.active == false and "KeyguideInactive" or (e.active and "KeyguideActive" or "KeyguideLabel")
			add(text, { { 0, -1, hl } })
		end
		if e.note then
			add(" Note: " .. e.note, { { 1, 6, "KeyguideLabel" } })
		end
		local origin
		if e.src == "config" then
			origin = "Defined in " .. (e.file or "your config")
		elseif e.src == "plugin" then
			origin = "Default key of " .. (e.plugin or "a plugin")
		elseif e.src == "detected" then
			origin = "Found among the active keymaps"
		else
			origin = "Built into Vim / Neovim"
		end
		add(" " .. origin, { { 0, -1, "KeyguideLabel" } })
	elseif not state.flash then
		add(
			" No matching shortcut. Try other words, e.g. 'open file', 'undo', 'split'.",
			{ { 0, -1, "KeyguideLabel" } }
		)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	for _, m in ipairs(marks) do
		local line_len = #lines[m[1] + 1]
		local finish = m[3] < 0 and line_len or math.min(m[3], line_len)
		vim.api.nvim_buf_set_extmark(buf, ns, m[1], math.min(m[2], line_len), { end_col = finish, hl_group = m[4] })
	end
	vim.bo[buf].modifiable = false
end

local function render_list()
	local buf, win = state.list_buf, state.list_win
	local width = vim.api.nvim_win_get_width(win)
	local results = state.results

	local key_w = 6
	for _, r in ipairs(results) do
		key_w = math.max(key_w, vim.fn.strdisplaywidth(key_text(r.entry, true)))
	end
	key_w = math.min(key_w, 16) -- longer key lists are cut here; the details pane shows them all
	local cat_w = width >= 90 and math.min(24, math.floor(width * 0.22)) or 0 -- no room on narrow screens

	local lines, marks = {}, {}
	for i, r in ipairs(results) do
		local e = r.entry
		local keys = pad(fit(key_text(e, true), key_w), key_w)
		local mode = pad(format.mode_short(e.mode), MODE_W)
		local prefix = " " .. keys .. "  " .. mode .. "  "
		local desc_w = width - vim.fn.strdisplaywidth(prefix) - (cat_w > 0 and cat_w + 2 or 1)
		local desc = fit(e.desc, desc_w)
		lines[i] = prefix .. desc

		local key_end = 1 + #keys
		marks[#marks + 1] = { i - 1, 1, key_end, "KeyguideKey" }
		marks[#marks + 1] = { i - 1, key_end + 2, key_end + 2 + #mode, "KeyguideMode" }
		for from, word, to in desc:gmatch("()(%w+)()") do
			if r.hits[search.stem(word:lower())] then
				marks[#marks + 1] = { i - 1, #prefix + from - 1, #prefix + to - 1, "KeyguideMatch" }
			end
		end
		if cat_w > 0 then
			marks[#marks + 1] = { i - 1, "cat", fit(e.cat_name or "", cat_w) }
		end
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	for _, m in ipairs(marks) do
		if m[2] == "cat" then
			vim.api.nvim_buf_set_extmark(buf, ns, m[1], 0, {
				virt_text = { { m[3] .. " ", "KeyguideCategory" } },
				virt_text_pos = "right_align",
			})
		else
			vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
		end
	end
	vim.bo[buf].modifiable = false

	local count = #results == 1 and "1 shortcut" or (#results .. " shortcuts")
	local title = state.query == "" and (" All shortcuts (" .. #results .. ") ") or (" " .. count .. " ")
	local footer = nil
	if #state.unmatched > 0 then
		footer = { { " nothing mentions: " .. table.concat(state.unmatched, ", ") .. " ", "KeyguideInactive" } }
	elseif not valid_win(state.details_win) then
		footer = HINT
	end
	vim.api.nvim_win_set_config(win, { title = title, title_pos = "left", footer = footer or "", footer_pos = "right" })
	if #results > 0 then
		vim.api.nvim_win_set_cursor(win, { state.sel, 0 })
	end
end

local function render()
	render_list()
	render_details()
end

local function refresh()
	if not state then
		return
	end
	state.query = query()
	state.results, state.unmatched = search.search(state.index, state.query)
	state.sel = 1
	state.flash = nil

	local buf = state.prompt_buf
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	if state.query == "" then
		vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
			virt_text = { { PLACEHOLDER, "KeyguideLabel" } },
			virt_text_pos = "eol",
		})
	end
	render()
end

local function move(delta)
	local n = #state.results
	if n == 0 then
		return
	end
	state.sel = ((state.sel - 1 + delta) % n) + 1
	state.flash = nil
	render_list()
	render_details()
end

-- =============================================================================
-- OPEN / CLOSE
-- =============================================================================

local function close()
	if not state then
		return
	end
	local s = state
	state = nil
	pcall(vim.api.nvim_del_augroup_by_id, s.group)
	if vim.api.nvim_get_current_win() == s.prompt_win and vim.fn.mode() == "i" then
		vim.cmd("stopinsert")
	end
	for _, win in ipairs({ s.prompt_win, s.list_win, s.details_win }) do
		if valid_win(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end
	for _, buf in ipairs({ s.prompt_buf, s.list_buf, s.details_buf }) do
		if buf and vim.api.nvim_buf_is_valid(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
	if valid_win(s.origin_win) then
		vim.api.nvim_set_current_win(s.origin_win)
	end
end

-- leave Insert mode first, then close once Neovim has settled
local function close_later(after)
	vim.cmd("stopinsert")
	vim.schedule(function()
		close()
		if after then
			after()
		end
	end)
end

local function accept()
	local r = selected()
	if not r then
		return
	end
	local run, why = keyguide.action(r.entry)
	if not run then
		state.flash = why
		render_details()
		if not valid_win(state.details_win) then
			vim.api.nvim_echo({ { why, "WarningMsg" } }, false, {})
		end
		return
	end
	close_later(run)
end

local function scratch(name)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = name
	return buf
end

local function window_options(win, winhl)
	vim.wo[win].wrap = false
	vim.wo[win].cursorline = false
	vim.wo[win].winhighlight = winhl
end

local function details_config(cfg)
	return vim.tbl_extend("force", cfg.details, { footer = HINT, footer_pos = "center" })
end

local function relayout()
	if not state then
		return
	end
	local cfg = layout()
	vim.api.nvim_win_set_config(state.prompt_win, cfg.prompt)
	vim.api.nvim_win_set_config(state.list_win, cfg.list)
	if cfg.details and valid_win(state.details_win) then
		vim.api.nvim_win_set_config(state.details_win, cfg.details)
	elseif cfg.details then
		state.details_win = vim.api.nvim_open_win(state.details_buf, false, details_config(cfg))
		window_options(state.details_win, FLOAT_HL)
		vim.wo[state.details_win].wrap = true
		vim.wo[state.details_win].linebreak = true
		vim.wo[state.details_win].breakindent = true
	elseif valid_win(state.details_win) then
		vim.api.nvim_win_close(state.details_win, true)
		state.details_win = nil
	end
	render()
end

local function set_keymaps(buf)
	local function map(modes, lhs, fn)
		vim.keymap.set(modes, lhs, fn, { buffer = buf, nowait = true, silent = true })
	end
	local next_result = function()
		move(1)
	end
	local prev_result = function()
		move(-1)
	end
	map({ "i", "n" }, "<CR>", accept)
	map({ "i", "n" }, "<Down>", next_result)
	map({ "i", "n" }, "<Up>", prev_result)
	map("i", "<C-n>", next_result)
	map("i", "<C-p>", prev_result)
	map("i", "<C-j>", next_result)
	map("i", "<C-k>", prev_result)
	map("i", "<Tab>", next_result)
	map("i", "<S-Tab>", prev_result)
	map("n", "j", next_result)
	map("n", "k", prev_result)
	map("i", "<Esc>", function()
		close_later()
	end)
	map({ "i", "n" }, "<C-c>", function()
		close_later()
	end)
	map("n", "<Esc>", close)
	map("n", "q", close)
end

--- Opens the guide. `initial` pre-fills the search.
---@param initial? string
function M.open(initial)
	if state then
		close()
	end
	set_highlights()

	local origin_win = vim.api.nvim_get_current_win()
	local origin_buf = vim.api.nvim_get_current_buf()
	local entries = keyguide.collect(origin_buf)

	state = {
		origin_win = origin_win,
		index = search.build(entries),
		results = {},
		unmatched = {},
		sel = 1,
		query = "",
	}

	state.prompt_buf = scratch("keyguide_prompt")
	state.list_buf = scratch("keyguide_list")
	state.details_buf = scratch("keyguide_details")
	vim.bo[state.prompt_buf].buftype = "prompt" -- also keeps completion plugins away
	vim.fn.prompt_setprompt(state.prompt_buf, PROMPT)
	vim.b[state.prompt_buf].minipairs_disable = true
	vim.b[state.prompt_buf].completion = false

	local cfg = layout()
	state.list_win = vim.api.nvim_open_win(state.list_buf, false, cfg.list)
	if cfg.details then
		state.details_win = vim.api.nvim_open_win(state.details_buf, false, details_config(cfg))
	end
	state.prompt_win = vim.api.nvim_open_win(
		state.prompt_buf,
		true,
		vim.tbl_extend("force", cfg.prompt, {
			title = " Keymap guide · search in plain English ",
			title_pos = "center",
		})
	)

	window_options(state.prompt_win, FLOAT_HL)
	window_options(state.list_win, FLOAT_HL .. ",CursorLine:Visual")
	vim.wo[state.list_win].cursorline = true
	vim.wo[state.list_win].scrolloff = 2
	if state.details_win then
		window_options(state.details_win, FLOAT_HL)
		vim.wo[state.details_win].wrap = true
		vim.wo[state.details_win].linebreak = true
		vim.wo[state.details_win].breakindent = true
	end

	set_keymaps(state.prompt_buf)

	state.group = vim.api.nvim_create_augroup("keyguide_ui", { clear = true })
	vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
		group = state.group,
		buffer = state.prompt_buf,
		callback = refresh,
	})
	vim.api.nvim_create_autocmd("WinLeave", {
		group = state.group,
		buffer = state.prompt_buf,
		callback = function()
			vim.schedule(function()
				if state and vim.api.nvim_get_current_win() ~= state.prompt_win then
					close()
				end
			end)
		end,
	})
	vim.api.nvim_create_autocmd("VimResized", {
		group = state.group,
		callback = function()
			vim.schedule(relayout)
		end,
	})

	if initial and initial ~= "" then
		vim.api.nvim_buf_set_lines(state.prompt_buf, 0, -1, false, { PROMPT .. initial })
	end
	refresh()
	vim.cmd("startinsert!")
end

M.close = close

return M
