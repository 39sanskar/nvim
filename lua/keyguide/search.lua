-- ================================================================================================
-- TITLE : keyguide.search
-- ABOUT : offline "plain English" search over keymap entries. No AI involved: the query is split
--         into words, filler words are dropped ("how do i ..."), words are reduced to a stem
--         ("renaming" -> "renam"), expanded with synonyms ("kill" ~ "close"), matched with
--         typo tolerance ("defintion"), and weighted so rare words count more than common ones.
--         Typing a key itself ("space f f", "ctrl d", "<leader>gd", ":Git") finds that key.
-- ================================================================================================

local format = require("keyguide.format")

local M = {}

-- words that carry no meaning in a question about shortcuts
local STOP_WORDS = [[
a an the i im me my mine to do does did doing done how can could would should what whats which
is are was were be been being in on of for with and or it its this that these those want wanna
need please way some there from into by at you your we us our get got let lets make
press pressing hit use using nvim neovim vim where when thing something then so just also any
between
]]
local STOP = {}
for w in STOP_WORDS:gmatch("%S+") do
	STOP[w] = true
end

-- groups of words that mean (roughly) the same thing here
local SYNONYMS = {
	"find search look locate lookup seek grep hunt discover query browse",
	"file files document filename",
	"open show view display see reveal launch bring list",
	"toggle switch flip enable disable turn",
	"close quit exit kill leave dismiss shut hide",
	"save write store",
	"error diagnostic warning problem issue bug lint linter mistake wrong squiggle squiggly red",
	"rename refactor",
	"definition declaration source defined define def implementation impl",
	"reference references usage usages used uses caller callers calls called",
	"copy yank clipboard duplicate",
	"paste put",
	"delete remove erase cut clear wipe drop destroy trash",
	"undo revert undone oops",
	"comment uncomment commented",
	"split divide side pane",
	"window pane panel split screen",
	"buffer opened",
	"tab tabpage",
	"move jump go goto going navigate navigation travel switch",
	"next forward following another",
	"previous prev back backward backwards before",
	"up above top upward upwards",
	"down below bottom downward downwards",
	"explorer tree sidebar folder directory nerdtree netrw filetree project",
	"git github vcs version commit branch repo repository",
	"blame author who wrote",
	"change changes changed hunk hunks diff modified modification",
	"format formatting formatter prettier beautify prettify tidy pretty",
	"indent indentation unindent dedent shift",
	"action actions fix lightbulb",
	"hover documentation docs doc info information signature description describe explain",
	"symbol function method class variable outline structure struct identifier",
	"debug debugger debugging breakpoint step dap",
	"completion complete autocomplete autocompletion suggest suggestion intellisense",
	"ai copilot codeium windsurf assistant",
	"zen focus distraction minimal",
	"reload refresh resource restart reread",
	"plugin plugins lazy package install update sync upgrade",
	"resize size bigger smaller wider narrower taller shorter height width grow shrink enlarge",
	"line lines row",
	"word token",
	"select selection visual highlight mark",
	"text content string phrase",
	"recent recently history frecency last old",
	"surround wrap quote quotes parenthesis parentheses paren parens bracket brace tag",
	"color colour hex rgb palette",
	"path location filepath fullpath absolute relative",
	"import imports organize organise sort",
	"everywhere project workspace whole entire global codebase all",
	"help guide cheatsheet cheat remember forgot forget learn which",
	"quickfix loclist trouble",
	"scroll page half",
	"middle center centre centered centred",
	"join merge combine concatenate",
	"replace substitute swap",
	"fold collapse unfold expand",
	"run execute call try",
	"new create add make",
	"shortcut keymap keybind keybinding binding hotkey key",
}

local function has_vowel(s)
	return s:find("[aeiouy]") ~= nil
end

--- Reduces a word to a rough stem so "closing", "closed" and "close" all match.
---@param w string lowercase word
---@return string
function M.stem(w)
	if #w <= 3 then
		return w
	end
	local tail3 = w:sub(-3)
	if (tail3 == "ies" or tail3 == "ied") and #w > 4 then
		return w:sub(1, -4) .. "y"
	end
	-- plurals
	if w:sub(-2) == "es" and (w:sub(-3, -3):match("[sxz]") or w:sub(-4, -3) == "ch" or w:sub(-4, -3) == "sh") then
		w = w:sub(1, -3)
	elseif w:sub(-1) == "s" and not w:sub(-2):match("^[sui]s$") then
		w = w:sub(1, -2)
	end
	-- -ing / -ed
	local base
	if #w > 5 and w:sub(-3) == "ing" and has_vowel(w:sub(1, -4)) then
		base = w:sub(1, -4)
	elseif #w > 4 and w:sub(-2) == "ed" and has_vowel(w:sub(1, -3)) then
		base = w:sub(1, -3)
	end
	if base then
		local last = base:sub(-1)
		if last == base:sub(-2, -2) and not last:match("[lsz]") then
			base = base:sub(1, -2) -- "splitt" -> "split"
		end
		w = base
	end
	if #w > 3 and w:sub(-1) == "e" then
		w = w:sub(1, -2)
	end
	return w
end

local stem = M.stem

-- words about shortcuts themselves ("hotkey for saving"): they don't narrow a question down
local META_WORDS = "shortcut keymap keybind keybinding binding hotkey key"
local META = {}
for w in META_WORDS:gmatch("%S+") do
	META[stem(w)] = true
end

-- stem -> list of concept ids
local CONCEPTS = {}
for id, group in ipairs(SYNONYMS) do
	for word in group:gmatch("%S+") do
		local s = stem(word)
		CONCEPTS[s] = CONCEPTS[s] or {}
		if not vim.tbl_contains(CONCEPTS[s], id) then
			table.insert(CONCEPTS[s], id)
		end
	end
end

--- Meaningful lowercase words of a text (filler words removed).
---@param text string
---@return string[]
function M.words(text)
	local out = {}
	local clean = text:lower():gsub("['’]", "")
	for w in clean:gmatch("%w+") do
		if not STOP[w] then
			out[#out + 1] = w
		end
	end
	return out
end

-- Damerau-Levenshtein distance, giving up once it exceeds `max`
local function distance(a, b, max)
	local la, lb = #a, #b
	if math.abs(la - lb) > max then
		return max + 1
	end
	local prev2, prev = {}, {}
	for j = 0, lb do
		prev[j] = j
	end
	for i = 1, la do
		local cur = { [0] = i }
		local row_min = i
		local ca = a:byte(i)
		for j = 1, lb do
			local cb = b:byte(j)
			local v = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca == cb and 0 or 1))
			if i > 1 and j > 1 and ca == b:byte(j - 1) and a:byte(i - 1) == cb then
				v = math.min(v, prev2[j - 2] + 1)
			end
			cur[j] = v
			row_min = math.min(row_min, v)
		end
		if row_min > max then
			return max + 1
		end
		prev2, prev = prev, cur
	end
	return prev[lb]
end

local function typo_budget(s)
	if #s >= 7 then
		return 2
	elseif #s >= 4 then
		return 1
	end
	return 0
end

-- Spell-corrects a query stem that no entry and no synonym knows, unless it's a word still being
-- typed (a prefix of a known word). Prefers the closest, then the most common, known word.
local function correct(index, s)
	if index.df_t[s] or CONCEPTS[s] then
		return s
	end
	local budget = typo_budget(s)
	if budget == 0 then
		return s
	end
	local best, best_d, best_df = nil, budget + 1, -1
	local function consider(word)
		if #word >= 3 and word:sub(1, #s) == s then
			best_d = -1 -- prefix of a known word: leave it to prefix matching
		end
		if best_d < 0 or #word < 3 then
			return
		end
		local d = distance(s, word, budget)
		local df = index.df_t[word] or 0
		if d <= budget and (d < best_d or (d == best_d and df > best_df)) then
			best, best_d, best_df = word, d, df
		end
	end
	for word in pairs(index.df_t) do
		consider(word)
	end
	for word in pairs(CONCEPTS) do
		consider(word)
	end
	if best_d < 0 or not best then
		return s
	end
	return best
end

--- Key notation squashed for comparison: "<leader>ff" / "space f f" -> "spaceff", "<C-d>" -> "ctrld".
---@param text string
---@return string
function M.compact_key(text)
	local s = text:lower()
	if s:sub(1, 1) == ":" then
		return (s:gsub("%s+", ""))
	end
	s = s:gsub("%f[%w]control%f[%W]", "ctrl")
		:gsub("%f[%w]leader%f[%W]", "space")
		:gsub("%f[%w]escape%f[%W]", "esc")
		:gsub("%f[%w]return%f[%W]", "enter")
		:gsub("%f[%w]spc%f[%W]", "space")
		:gsub("%f[%w]meta%f[%W]", "alt")
		:gsub("%f[%w]option%f[%W]", "alt")
		:gsub("%f[%w]opt%f[%W]", "alt")
		:gsub("^c%-", "ctrl")
		:gsub("%sc%-", " ctrl")
		:gsub("^a%-", "alt")
		:gsub("%sa%-", " alt")
		:gsub("^m%-", "alt")
		:gsub("%sm%-", " alt")
		:gsub("^s%-", "shift")
		:gsub("%ss%-", " shift")
	if s:find("<") then
		s = format.pretty(s):lower()
	end
	return (s:gsub("[%s%+]", ""))
end

local META_FACTOR = 0.3 -- "shortcut", "key" ... next to real words only add a little
local INSIDE_FACTOR = 0.8 -- keys that only work inside a specific window rank a bit lower
local SECONDARY_FACTOR = 0.85 -- fallbacks / built-in duplicates of a configured key
local FIRST_WORD_FACTOR = 1.3 -- descriptions start with the action: "Rename ...", "Commit ..."

--- Prepares entries for searching. Call again when the entry list changes.
---@param entries table[] normalized entries (see keyguide.collect)
---@return table index
function M.build(entries)
	local index = { entries = entries, df_t = {}, df_c = {}, n = #entries }
	for _, e in ipairs(entries) do
		local terms, concepts = {}, {}
		local function feed(text, weight)
			if not text or text == "" then
				return
			end
			for _, w in ipairs(M.words(text)) do
				if #w >= 2 then
					local s = stem(w)
					if (terms[s] or 0) < weight then
						terms[s] = weight
					end
					for _, c in ipairs(CONCEPTS[s] or {}) do
						if (concepts[c] or 0) < weight then
							concepts[c] = weight
						end
					end
				end
			end
		end
		feed(e.desc, 3)
		feed(e.tags, 2.2)
		feed(e.cat_name, 1.0)
		feed(e.scope, 0.6)
		feed(e.note, 0.6)
		feed(format.mode_long(e.mode) .. " " .. (e.plugin or ""), 0.5)
		e._terms, e._concepts = terms, concepts

		local seq = {}
		for _, w in ipairs(M.words((e.desc or "") .. " " .. (e.tags or ""))) do
			seq[#seq + 1] = stem(w)
		end
		e._seq = " " .. table.concat(seq, " ") .. " "
		local first = M.words(e.desc or "")[1]
		e._first = first and stem(first) or nil

		e._keys = {}
		for _, k in ipairs(type(e.keys) == "table" and e.keys or { e.keys }) do
			e._keys[#e._keys + 1] = { raw = k, compact = M.compact_key(k) }
		end
		e._inside = e.scope ~= nil and (e.scope:match("^inside") or e.scope:match("^while")) and true or false

		for s in pairs(terms) do
			index.df_t[s] = (index.df_t[s] or 0) + 1
		end
		for c in pairs(concepts) do
			index.df_c[c] = (index.df_c[c] or 0) + 1
		end
	end
	return index
end

local function idf(n, df)
	return math.log(1 + n / (1 + (df or 0)))
end

-- how well one query stem matches an entry; returns the score, the entry stem that matched (if
-- any) and the synonym concept that matched (if any)
local function match_term(index, e, s, s_concepts)
	local best, hit, concept = 0, nil, nil
	local w = e._terms[s]
	if w then
		best, hit = w * idf(index.n, index.df_t[s]), s
		if e._first == s then
			best = best * FIRST_WORD_FACTOR
		end
	end
	for _, c in ipairs(s_concepts or {}) do
		local cw = e._concepts[c]
		if cw then
			local v = cw * 0.7 * idf(index.n, index.df_c[c])
			if v > best then
				best, hit, concept = v, nil, c
			end
		end
	end
	if w or #s < 3 then
		return best, hit, concept
	end
	for t, tw in pairs(e._terms) do
		if #t > #s and t:sub(1, #s) == s then -- still typing: "ren" -> "rename"
			local v = tw * 0.75 * idf(index.n, index.df_t[t])
			if v > best then
				best, hit, concept = v, t, nil
			end
		end
	end
	return best, hit, concept
end

-- bonus for queries that are (part of) a key: "space f f", "ctrl d", "ff", ":git"
local function key_bonus(e, raw, compact)
	if compact == "" then
		return 0
	end
	local bonus = 0
	local is_prefix_query = compact:match("^space")
		or compact:match("^ctrl")
		or compact:match("^alt")
		or compact:match("^shift")
		or compact:sub(1, 1) == ":"
	for _, k in ipairs(e._keys) do
		if k.raw == raw then
			bonus = math.max(bonus, 34) -- exact, case included ("J" vs "j")
		elseif k.compact == compact then
			bonus = math.max(bonus, 30)
		elseif k.compact == "space" .. compact and #compact >= 2 then
			bonus = math.max(bonus, 22) -- "ff" -> <leader>ff
		elseif is_prefix_query and #compact >= 4 and k.compact:sub(1, #compact) == compact then
			bonus = math.max(bonus, 12) -- "space g" -> every <leader>g...
		end
	end
	return bonus
end

-- fallback for abbreviations ("cmnt" -> "comment", "brkpt" -> "breakpoint"): a word that starts
-- with the query's first letter and contains all its letters in order
local function abbreviation_score(text, q)
	local best = 0
	for word in text:lower():gmatch("%w+") do
		if #word > #q and word:sub(1, 1) == q:sub(1, 1) then
			local pos = 2
			for i = 2, #q do
				pos = word:find(q:sub(i, i), pos, true)
				if not pos then
					break
				end
				pos = pos + 1
			end
			if pos then
				best = math.max(best, #q / #word)
			end
		end
	end
	return best
end

--- Ranks entries for a query. Empty query returns everything in guide order.
---@param index table from M.build
---@param query string
---@return table[] results { entry = e, score = number, hits = { [stem] = true } }
---@return string[] unmatched query words no shortcut mentions at all
function M.search(index, query)
	local results = {}
	local raw = vim.trim(query or "")
	if raw == "" then -- everything: the everyday keys first, then the guide's order
		local rest = {}
		for _, e in ipairs(index.entries) do
			table.insert(e.starter and results or rest, { entry = e, score = 0, hits = {} })
		end
		table.sort(results, function(a, b)
			return a.entry.starter < b.entry.starter
		end)
		return vim.list_extend(results, rest), {}
	end

	-- query words, deduplicated by stem
	local qterms, seen = {}, {}
	local real_terms = 0
	for _, w in ipairs(M.words(raw)) do
		local s = correct(index, stem(w))
		if #w >= 2 and not seen[s] then
			seen[s] = true
			local meta = META[s] or w:match("^%d+$") ~= nil -- "line 50": numbers only add a little
			qterms[#qterms + 1] = { stem = s, word = w, concepts = CONCEPTS[s], meta = meta }
			real_terms = real_terms + (meta and 0 or 1)
		end
	end
	if real_terms == 0 then -- the question is about shortcuts themselves: "keys", "shortcuts"
		for _, t in ipairs(qterms) do
			t.meta = false
		end
		real_terms = #qterms
	end
	local used = {}
	local qseq = {}
	for _, t in ipairs(qterms) do
		if not t.meta then
			qseq[#qseq + 1] = t.stem
		end
	end
	local phrase = #qseq >= 2 and (" " .. table.concat(qseq, " ") .. " ") or nil

	-- key lookups use the query with filler words removed too ("what does space f f do")
	local compact_full = M.compact_key(raw)
	local compact_meaning = M.compact_key(table.concat(M.words(raw), " "))
	-- "space g", "ctrl w": the person is exploring keys, so words like "space" matter less
	local key_like = compact_meaning:match("^space.")
		or compact_meaning:match("^ctrl.")
		or compact_meaning:match("^alt.")
		or compact_meaning:match("^shift.")

	for _, e in ipairs(index.entries) do
		local total, matched, hits = 0, 0, {}
		for _, t in ipairs(qterms) do
			local v, hit, concept = match_term(index, e, t.stem, t.concepts)
			if v > 0 then
				used[t.stem] = true
				if t.meta then
					total = total + v * META_FACTOR
				else
					total = total + v
					matched = matched + 1
				end
				hits[t.stem] = true
				if hit then
					hits[hit] = true
				end
				if concept then -- highlight the synonym that matched, e.g. "close" for "kill"
					for term in pairs(e._terms) do
						if vim.tbl_contains(CONCEPTS[term] or {}, concept) then
							hits[term] = true
						end
					end
				end
			end
		end
		local score = 0
		if matched > 0 then
			local coverage = matched / real_terms
			score = total * (0.35 + 0.65 * coverage * coverage)
			if phrase and e._seq:find(phrase, 1, true) then
				score = score + 4
			end
			if e._inside then
				score = score * INSIDE_FACTOR
			end
			if e.secondary then
				score = score * SECONDARY_FACTOR
			end
			if key_like then
				score = score * 0.3
			end
		end
		score = score + math.max(key_bonus(e, raw, compact_full), key_bonus(e, raw, compact_meaning))
		if score > 0 then
			results[#results + 1] = { entry = e, score = score, hits = hits }
		end
	end

	if #results == 0 and not raw:find("%s") and #raw >= 3 then
		local q = raw:lower()
		for _, e in ipairs(index.entries) do
			local v = abbreviation_score(e.desc .. " " .. (e.tags or ""), q)
			if v > 0 then
				results[#results + 1] = { entry = e, score = v, hits = {} }
			end
		end
	end

	for i, r in ipairs(results) do
		r.order = i
	end
	table.sort(results, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.order < b.order
	end)

	-- drop the long tail of weak matches
	local top = results[1] and results[1].score or 0
	local cut = top * 0.2
	local kept = {}
	for _, r in ipairs(results) do
		if r.score >= cut then
			kept[#kept + 1] = r
		end
	end

	local unmatched = {}
	for _, t in ipairs(qterms) do
		if not used[t.stem] and not t.meta then
			unmatched[#unmatched + 1] = t.word
		end
	end
	return kept, unmatched
end

return M
