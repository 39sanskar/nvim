-- ================================================================================================
-- TITLE : keyguide.registry
-- ABOUT : every shortcut in this config (plus the most useful built-in & plugin keys), with plain
--         English descriptions and extra search words. This list feeds both the in-editor guide
--         (<leader>k / :Keys) and DOCS.md (:KeysExport). When you add or change a keymap, add or
--         update its line here too.
--
-- ENTRY : { keys, mode, description, tags = "...", scope = "...", note = "...", norun = true }
--   keys  : "<leader>ff", or a list of alternatives { "<Down>", "<C-n>" }, or ":Command"
--   mode  : any of n (normal) x (visual) i (insert) o (after an operator like d/c/y) c (command)
--   tags  : extra words people might use when searching (synonyms, phrasings)
--   scope : when the shortcut works, if not everywhere ("inside the file explorer", ...)
--   note  : caveats or tips
--   norun : the guide can't run it for you (needs a motion, a selection, or a specific window)
--   cmd   : text to put on the command line instead of the keys (for ":" entries)
--   secondary : a fallback / built-in duplicate of a configured key (ranks a little lower)
-- ================================================================================================

local M = {}

M.categories = {}
M.entries = {}

-- the everyday keys: listed first in the guide and under "Start here" in DOCS.md ("mode first-key")
M.starter = {
	"n <leader>k",
	"n <leader>ff",
	"n <leader>fg",
	"n <leader>e",
	"n <leader>w",
	"n <leader>q",
	"n u",
	"n gcc",
	"n K",
	"n <leader>gD",
	"n <leader>rn",
	"n <leader>ca",
	"n <leader>xx",
	"n <leader>bn",
	"n <C-h>",
	"n <leader>sv",
	"nx <A-j>",
}

local function category(id, name, about)
	M.categories[#M.categories + 1] = { id = id, name = name, about = about }
end

--- Adds entries to a category; `defaults` fills fields (src, file, plugin, scope, norun, ...)
local function add(cat, defaults, list)
	for _, e in ipairs(list) do
		e.cat = cat
		for k, v in pairs(defaults) do
			if e[k] == nil then
				e[k] = v
			end
		end
		M.entries[#M.entries + 1] = e
	end
end

local KEYMAPS = "lua/config/keymaps.lua"
local LSP = "lua/utils/lsp.lua"
local LSP_SCOPE = "files with a language server attached"

-- =============================================================================
-- HELP & DISCOVERY
-- =============================================================================
category("help", "Help & discovery", "Ways to find shortcuts and answers without leaving Neovim.")
add("help", { src = "config", file = KEYMAPS }, {
	{
		"<leader>k",
		"n",
		"Open the keymap guide: search every shortcut in plain English",
		tags = "help keys keymaps shortcuts hotkeys bindings cheatsheet cheat sheet guide forgot remember list all what key does how",
	},
	{
		":Keys",
		"c",
		"Open the keymap guide with a search already typed, e.g. :Keys split window",
		tags = "help keymaps shortcuts cheatsheet guide search",
		file = "lua/keyguide/init.lua",
		cmd = "Keys ",
	},
	{
		":KeysSheet",
		"c",
		"Open the full cheat sheet (DOCS.md) in a new tab",
		tags = "docs documentation cheatsheet list all shortcuts read markdown",
		file = "lua/keyguide/init.lua",
	},
	{
		":KeysExport",
		"c",
		"Regenerate DOCS.md from the keymap guide's list",
		tags = "docs documentation update generate write markdown export",
		file = "lua/keyguide/init.lua",
	},
	{
		"<leader>",
		"n",
		"Press Space and wait: a popup lists every shortcut that starts with Space",
		tags = "which key popup menu leader hints help prefix",
		src = "plugin",
		plugin = "which-key.nvim",
		file = false,
	},
	{
		"<leader>?",
		"n",
		"Show the shortcuts that only exist in the current buffer (which-key)",
		tags = "which key buffer local help popup",
		file = "lua/plugins/which-key.lua",
	},
	{
		"<leader>fh",
		"n",
		"Search Neovim's help pages (fzf-lua)",
		tags = "help manual documentation docs vim help tags",
		file = "lua/plugins/fzf-lua.lua",
	},
	{
		":help",
		"c",
		"Open Neovim's built-in manual on a topic, e.g. :help motion",
		tags = "manual documentation docs reference",
		src = "vim",
		file = false,
		cmd = "help ",
	},
	{
		":Tutor",
		"c",
		"Start the interactive Vim tutorial (about 30 minutes, practice by doing)",
		tags = "learn tutorial practice lesson course basics training",
		src = "vim",
		file = false,
	},
	{
		":FzfLua keymaps",
		"c",
		"Fuzzy-search the raw list of every active keymap (fzf-lua)",
		tags = "keymaps list all raw mappings",
		src = "plugin",
		plugin = "fzf-lua",
		file = false,
	},
})

-- =============================================================================
-- VIM BASICS
-- =============================================================================
category(
	"basics",
	"Basics: modes, saving, undo",
	"Neovim starts in Normal mode, where keys are commands. Press i to type text and Esc to go back."
)
add("basics", { src = "vim" }, {
	{
		"i",
		"n",
		"Start typing before the cursor (Insert mode)",
		tags = "insert mode type write text edit start typing",
	},
	{ "a", "n", "Start typing after the cursor", tags = "append insert type after" },
	{ "A", "n", "Start typing at the end of the line", tags = "append end line insert type" },
	{ "I", "n", "Start typing at the beginning of the line", tags = "insert start beginning line type" },
	{ "o", "n", "Open a new line below and start typing", tags = "new line below add insert" },
	{ "O", "n", "Open a new line above and start typing", tags = "new line above add insert" },
	{
		"<Esc>",
		"i",
		"Go back to Normal mode (leave Insert or Visual mode)",
		tags = "escape exit insert mode normal mode stop typing cancel leave",
		norun = true,
	},
	{ "v", "n", "Select characters (Visual mode)", tags = "select selection highlight visual mode mark text" },
	{ "V", "n", "Select whole lines (Visual Line mode)", tags = "select lines selection visual line" },
	{ "ggVG", "n", "Select the whole file", tags = "select all everything entire whole file" },
	{
		"<C-v>",
		"n",
		"Select a rectangle / column (Visual Block mode)",
		tags = "block column vertical select multiple lines multi cursor",
	},
	{ "u", "n", "Undo", tags = "undo revert mistake oops back" },
	{ "<C-r>", "n", "Redo", tags = "redo again undo undo" },
	{ ".", "n", "Repeat the last change", tags = "repeat again redo last action dot" },
	{
		"<leader>w",
		"n",
		"Save the file (also formats it and trims trailing spaces)",
		tags = "save write store format formatting formatter prettier on save trailing whitespace format code format file",
		note = "Formatting on save uses the tools set up in lua/servers/efm-langserver.lua.",
		src = "config",
		file = KEYMAPS,
	},
	{ ":w", "c", "Save the file", tags = "save write store" },
	{
		"<leader>q",
		"n",
		"Quit: close the current window",
		tags = "quit exit close leave window",
		src = "config",
		file = KEYMAPS,
	},
	{ ":q", "c", "Quit: close the current window", tags = "quit exit close leave" },
	{ ":wq", "c", "Save and quit", tags = "save write quit exit close" },
	{ ":q!", "c", "Quit without saving (throw away changes)", tags = "discard force quit exit abandon lose changes" },
	{ ":qa", "c", "Quit Neovim completely (all windows)", tags = "quit exit all close everything neovim" },
	{
		":e",
		"c",
		"Open a file by typing its path, e.g. :e src/main.go (a new name creates the file)",
		tags = "open edit file path create new file",
		cmd = "e ",
	},
	{
		":terminal",
		"c",
		"Open a terminal inside Neovim",
		tags = "terminal shell console command line bash zsh run commands",
		note = "Type exit in the terminal to close it.",
	},
	{
		"<C-\\><C-n>",
		"t",
		"Leave the terminal's typing mode so you can scroll / copy (i to type again)",
		tags = "terminal normal mode escape exit typing scroll",
		norun = true,
	},
	{
		"<leader>pa",
		"n",
		"Copy the full path of the current file to the clipboard",
		tags = "copy file path filepath location clipboard absolute full name",
		src = "config",
		file = KEYMAPS,
	},
})

-- =============================================================================
-- MOVING AROUND
-- =============================================================================
category("move", "Moving around", "Normal-mode motions. Most can take a count first, e.g. 5j moves 5 lines down.")
add("move", { src = "vim" }, {
	{ { "h", "l" }, "n", "Move left / right", tags = "cursor move left right arrow", norun = true },
	{
		{ "j", "k" },
		"n",
		"Move down / up (follows wrapped lines)",
		tags = "cursor move down up arrow wrap",
		src = "config",
		file = KEYMAPS,
		norun = true,
	},
	{ "w", "n", "Jump forward to the start of the next word", tags = "word next forward jump" },
	{ "b", "n", "Jump back to the start of the previous word", tags = "word previous back backward jump" },
	{ "e", "n", "Jump to the end of the word", tags = "word end jump" },
	{ "0", "n", "Go to the start of the line", tags = "line start beginning home" },
	{ "^", "n", "Go to the first non-blank character of the line", tags = "line start first character indent" },
	{ "$", "n", "Go to the end of the line", tags = "line end" },
	{ "gg", "n", "Go to the first line of the file", tags = "top beginning start file first line" },
	{ "G", "n", "Go to the last line of the file", tags = "bottom end file last line" },
	{
		":42",
		"c",
		"Jump / go to line N: type : and the number, e.g. :120",
		tags = "go to line number goto jump specific line jump to line",
		cmd = "",
	},
	{ "%", "n", "Jump between matching brackets ( ) [ ] { }", tags = "matching bracket parenthesis brace pair" },
	{ { "{", "}" }, "n", "Jump to the previous / next blank line (paragraph)", tags = "paragraph block blank line" },
	{
		"<C-d>",
		"n",
		"Scroll half a page down (keeps the cursor centered)",
		tags = "scroll page down half",
		src = "config",
		file = KEYMAPS,
	},
	{
		"<C-u>",
		"n",
		"Scroll half a page up (keeps the cursor centered)",
		tags = "scroll page up half",
		src = "config",
		file = KEYMAPS,
	},
	{ "zz", "n", "Center the screen on the cursor line", tags = "center middle screen scroll" },
	{
		"<C-o>",
		"n",
		"Jump back to where you were before (jump list)",
		tags = "back previous location history return go back",
	},
	{ "<C-i>", "n", "Jump forward again in the jump list", tags = "forward next location history" },
	{
		"f",
		"n",
		"Jump to a character on the line: f then the character (; repeats, , goes back)",
		tags = "find character letter jump line",
		norun = true,
	},
	{
		"gx",
		"n",
		"Open the link or path under the cursor in the browser / system app",
		tags = "url link browser open web website",
	},
	{ "gf", "n", "Open the file whose path is under the cursor", tags = "go to file path open" },
	{
		"ma",
		"n",
		"Set mark a at the cursor (any letter); jump back to it with 'a",
		tags = "bookmark mark remember position place",
	},
})

-- =============================================================================
-- SEARCH IN THE CURRENT FILE
-- =============================================================================
category("search", "Search & replace in this file", "Searching inside the file you're looking at.")
add("search", { src = "vim" }, {
	{
		"/",
		"n",
		"Search forward in this file: type the text, then Enter",
		tags = "find search text word in file current buffer",
	},
	{ "?", "n", "Search backward in this file", tags = "find search backward reverse text" },
	{
		"n",
		"n",
		"Go to the next search match (centered)",
		tags = "next match result search again",
		src = "config",
		file = KEYMAPS,
	},
	{
		"N",
		"n",
		"Go to the previous search match (centered)",
		tags = "previous match result search back",
		src = "config",
		file = KEYMAPS,
	},
	{ "*", "n", "Search for the word under the cursor (forward)", tags = "word under cursor occurrences next same" },
	{
		"#",
		"n",
		"Search for the word under the cursor (backward)",
		tags = "word under cursor occurrences previous same",
	},
	{
		"<leader>h",
		"n",
		"Clear search highlighting",
		tags = "clear highlight hlsearch nohlsearch remove highlight",
		src = "config",
		file = KEYMAPS,
	},
	{
		":%s/old/new/g",
		"c",
		"Find and replace in the whole file (add c at the end to confirm each one)",
		tags = "replace substitute find and replace all occurrences change text everywhere",
		cmd = "%s/",
	},
})

-- =============================================================================
-- EDITING
-- =============================================================================
category("edit", "Editing text", "Deleting, copying, pasting, indenting and moving lines (Normal / Visual mode).")
add("edit", { src = "vim" }, {
	{ "x", "n", "Delete the character under the cursor", tags = "delete character remove letter" },
	{ "dd", "n", "Delete (cut) the current line", tags = "delete line remove cut erase" },
	{ "dw", "n", "Delete a word (d works with any motion: d$, dj, dip ...)", tags = "delete word remove cut" },
	{ "D", "n", "Delete from the cursor to the end of the line", tags = "delete rest line end" },
	{ "yy", "n", "Copy (yank) the current line", tags = "copy line yank duplicate clipboard" },
	{ "p", "n", "Paste after the cursor", tags = "paste put clipboard insert" },
	{ "P", "n", "Paste before the cursor", tags = "paste put before" },
	{
		"ciw",
		"n",
		"Change the word under the cursor (delete it and start typing)",
		tags = "change word replace rewrite",
	},
	{ "cc", "n", "Change (rewrite) the whole line", tags = "change line replace rewrite" },
	{ "r", "n", "Replace one character: r then the new character", tags = "replace character letter", norun = true },
	{ "~", "n", "Switch upper / lower case of the character", tags = "case uppercase lowercase capital toggle" },
	{
		{ "<C-a>", "<C-x>" },
		"n",
		"Increase / decrease the number under the cursor",
		tags = "increment decrement number add subtract",
	},
	{ { ">>", "<<" }, "n", "Indent / unindent the current line", tags = "indent unindent tab shift" },
	{
		{ ">", "<" },
		"x",
		"Indent / unindent the selection (stays selected)",
		tags = "indent unindent selection shift tab",
		src = "config",
		file = KEYMAPS,
		norun = true,
	},
	{
		"J",
		"n",
		"Join the line below onto this one (cursor stays put)",
		tags = "join merge lines combine",
		src = "config",
		file = KEYMAPS,
	},
	{
		{ "<A-j>", "<A-k>" },
		"nx",
		"Move the line (or selection) down / up",
		tags = "move line swap reorder drag shift up down selection move line up move line down",
		src = "plugin",
		plugin = "mini.move",
		note = "keymaps.lua defines the same keys; mini.move's version is the one that runs.",
		norun = true,
	},
	{
		{ "<A-h>", "<A-l>" },
		"nx",
		"Move the line (or selection) left / right (changes indent)",
		tags = "move line indent left right shift",
		src = "plugin",
		plugin = "mini.move",
		norun = true,
	},
	{
		"<leader>p",
		"x",
		"Paste over the selection without losing what you copied",
		tags = "paste replace selection keep clipboard register",
		src = "config",
		file = KEYMAPS,
		norun = true,
	},
	{
		"<leader>x",
		"nx",
		"Delete without copying (your clipboard stays as it was)",
		tags = "delete remove black hole register keep clipboard",
		src = "config",
		file = KEYMAPS,
		note = "In Normal mode add a motion, e.g. Space x w. Space x x and Space x d are taken by diagnostics.",
		norun = true,
	},
	{
		"<leader>qq",
		"n",
		"Insert a Go 'if err != nil' block",
		tags = "go golang error check err nil snippet",
		src = "config",
		file = KEYMAPS,
	},
})

-- =============================================================================
-- COMMENTS, BRACKETS & QUOTES
-- =============================================================================
category(
	"surround",
	"Comments, brackets & quotes",
	"Commenting (mini.comment), wrapping text in brackets/quotes (mini.surround) and auto-closing pairs (mini.pairs)."
)
add("surround", { src = "plugin" }, {
	{
		"gcc",
		"n",
		"Comment / uncomment the current line",
		tags = "comment uncomment toggle line comment out",
		plugin = "mini.comment",
	},
	{
		"gc",
		"x",
		"Comment / uncomment the selected lines",
		tags = "comment uncomment selection lines",
		plugin = "mini.comment",
		norun = true,
	},
	{
		"gc",
		"n",
		"Comment with a motion, e.g. gcip = paragraph, gc3j = 4 lines",
		tags = "comment uncomment paragraph motion",
		plugin = "mini.comment",
		norun = true,
	},
	{
		"gc",
		"o",
		"Comment block text object, e.g. dgc deletes the whole comment",
		tags = "comment block delete text object",
		plugin = "mini.comment",
		norun = true,
	},
	{
		"sa",
		"nx",
		"Add brackets/quotes around text: sa + motion + character, e.g. saiw) wraps a word in ( )",
		tags = "surround wrap add quotes brackets parentheses braces tags around word",
		plugin = "mini.surround",
		norun = true,
	},
	{
		{ "sd", "sdn", "sdl" },
		"n",
		'Delete the brackets/quotes around the cursor: sd + character, e.g. sd"',
		tags = "surround delete remove unwrap quotes brackets parentheses",
		plugin = "mini.surround",
		note = "Add n / l (sdn, sdl) to act on the next / previous pair. Same for sr, sf, sF and sh.",
		norun = true,
	},
	{
		{ "sr", "srn", "srl" },
		"n",
		"Replace surrounding brackets/quotes: sr + old + new, e.g. sr)] turns ( ) into [ ]",
		tags = "surround replace change swap quotes brackets parentheses",
		plugin = "mini.surround",
		norun = true,
	},
	{
		{ "sf", "sF", "sfn", "sfl", "sFn", "sFl" },
		"n",
		"Jump to the next (sf) / previous (sF) surrounding character",
		tags = "surround find jump bracket quote",
		plugin = "mini.surround",
		norun = true,
	},
	{
		{ "sh", "shn", "shl" },
		"n",
		"Briefly highlight the surrounding brackets/quotes",
		tags = "surround highlight show brackets",
		plugin = "mini.surround",
		norun = true,
	},
	{
		{ "(", "[", "{", '"', "'", "`", ")", "]", "}" },
		"i",
		"Brackets and quotes close themselves automatically while typing",
		tags = "auto close pairs autopairs brackets quotes parentheses closing",
		plugin = "mini.pairs",
		norun = true,
	},
	{
		"<BS>",
		"i",
		"Backspace between an empty pair deletes both characters",
		tags = "backspace delete pair brackets",
		plugin = "mini.pairs",
		norun = true,
	},
})

-- =============================================================================
-- TEXT OBJECTS
-- =============================================================================
category(
	"textobj",
	"Text objects: act on 'inside' / 'around' things",
	'Use after d (delete), c (change), y (copy) or v (select). Example: ci" = change inside quotes, dap = delete paragraph.'
)
add("textobj", { src = "plugin", plugin = "mini.ai", norun = true }, {
	{ { "iw", "aw" }, "ox", "Inside / around a word", tags = "word", src = "vim", plugin = false },
	{ { "ip", "ap" }, "ox", "Inside / around a paragraph", tags = "paragraph block", src = "vim", plugin = false },
	{
		{ "i(", "a(", "ib", "ab" },
		"ox",
		"Inside / around parentheses (b = any bracket type)",
		tags = "parentheses brackets braces inside around",
	},
	{
		{ 'i"', 'a"', "iq", "aq" },
		"ox",
		"Inside / around quotes (q = any quote type)",
		tags = "quotes string inside around",
	},
	{ { "if", "af" }, "ox", "Inside / around a function call", tags = "function call arguments" },
	{ { "ia", "aa" }, "ox", "Inside / around a function argument", tags = "argument parameter param" },
	{ { "it", "at" }, "ox", "Inside / around an HTML/XML tag", tags = "tag html xml jsx element" },
	{
		{ "ii", "ai" },
		"ox",
		"Inside / around the current indentation block",
		tags = "indent block scope",
		plugin = "mini.indentscope",
	},
	{
		{ "in", "an", "il", "al" },
		"ox",
		"Next / last text object, e.g. cin) changes inside the next ( )",
		tags = "next last previous text object",
	},
	{ { "g[", "g]" }, "nxo", "Jump to the left / right edge of a text object", tags = "edge jump bracket" },
	{
		{ "[i", "]i" },
		"nxo",
		"Jump to the top / bottom of the current indentation block",
		tags = "indent scope top bottom jump block",
		plugin = "mini.indentscope",
	},
})

-- =============================================================================
-- FIND FILES & TEXT
-- =============================================================================
category(
	"find",
	"Find files & text",
	"Project-wide search. fff is the fast default; fzf-lua covers buffers, symbols & more."
)
add("find", { src = "config", file = "lua/plugins/fzf-lua.lua" }, {
	{
		"<leader>ff",
		"n",
		"Find a file by name (fff: very fast, ranks files you open often first)",
		tags = "find file open search filename fuzzy finder quick open goto file ctrl p project recent files recently opened",
		file = "lua/plugins/fff.lua",
	},
	{
		"<leader>fg",
		"n",
		"Search for text in every file of the project (fff live grep)",
		tags = "grep search text content inside files project wide everywhere find in files string ripgrep",
		file = "lua/plugins/fff.lua",
	},
	{
		"<leader>fz",
		"n",
		"Fuzzy text search across the project that tolerates typos (fff)",
		tags = "fuzzy grep typo approximate search text",
		file = "lua/plugins/fff.lua",
	},
	{
		"<leader>fc",
		"nx",
		"Search the project for the word under the cursor or the selected text (fff)",
		tags = "word under cursor selection grep usages occurrences search project",
		file = "lua/plugins/fff.lua",
	},
	{
		"<leader>fl",
		"n",
		"Reopen the last fff search, with the same query and results",
		tags = "resume last previous search again reopen",
		file = "lua/plugins/fff.lua",
	},
	{ "<leader>fF", "n", "Find a file by name (fzf-lua version)", tags = "find file fzf fallback", secondary = true },
	{
		"<leader>fG",
		"n",
		"Search text in the project (fzf-lua version)",
		tags = "grep search text fzf fallback",
		secondary = true,
	},
	{ "<leader>fb", "n", "List open buffers and jump to one (fzf-lua)", tags = "buffers open files switch list" },
	{
		"<leader>fs",
		"n",
		"List symbols (functions, classes ...) in this file (fzf-lua)",
		tags = "symbols outline functions methods classes",
	},
	{
		"<leader>fS",
		"n",
		"Search symbols across the whole project (fzf-lua)",
		tags = "symbols workspace project functions classes",
	},
	{
		"<leader>fx",
		"n",
		"List errors & warnings in this file (fzf-lua)",
		tags = "diagnostics errors warnings problems",
	},
	{
		"<leader>fX",
		"n",
		"List errors & warnings in the whole project (fzf-lua)",
		tags = "diagnostics errors warnings problems workspace",
	},
})

category(
	"fff",
	"Inside the fff finder",
	"Keys that work while the fff window (Space f f, Space f g ...) is open. You type in Insert mode."
)
add("fff", { src = "plugin", plugin = "fff", scope = "inside the fff finder", norun = true }, {
	{ "<CR>", "i", "Open the selected file", tags = "open select accept enter" },
	{ "<C-s>", "i", "Open in a horizontal split", tags = "split horizontal open" },
	{ "<C-v>", "i", "Open in a vertical split (side by side)", tags = "split vertical side open" },
	{ "<C-t>", "i", "Open in a new tab", tags = "tab open new" },
	{ "<Esc>", "i", "Close the finder", tags = "close quit exit cancel" },
	{ { "<Down>", "<C-n>" }, "i", "Move down the list", tags = "next down move" },
	{ { "<Up>", "<C-p>" }, "i", "Move up the list", tags = "previous up move" },
	{ { "<C-d>", "<C-u>" }, "i", "Scroll the preview down / up", tags = "preview scroll" },
	{ "<Tab>", "i", "Mark / unmark a file (pick several)", tags = "multi select mark several multiple" },
	{ "<C-q>", "i", "Send the marked files to the quickfix list", tags = "quickfix list send" },
	{
		"<S-Tab>",
		"i",
		"Live grep: switch between plain, regex and fuzzy matching",
		tags = "grep mode regex fuzzy plain switch",
	},
	{
		{ "<A-Down>", "<A-Up>" },
		"i",
		"Live grep: jump to the next / previous file's matches",
		tags = "grep next file group",
	},
	{
		{ "<C-Up>", "<C-Down>" },
		"i",
		"Bring back previous / next search queries (history)",
		tags = "history previous query recent",
	},
	{
		"git:modified",
		"i",
		"Type git:modified (or staged, untracked ...) to only show those files",
		tags = "git modified changed files filter status untracked staged",
	},
	{
		"*.lua",
		"i",
		"Type *.lua or src/ to filter by extension or folder; !test/ excludes",
		tags = "filter extension folder directory exclude glob pattern",
	},
	{ "<F2>", "i", "Show / hide the scoring debug info", tags = "debug scores" },
})

category("fzf", "Inside fzf-lua pickers", "Keys for fzf-lua windows (Space f b, Space f s, Space f h ...).")
add("fzf", { src = "plugin", plugin = "fzf-lua", scope = "inside an fzf-lua window", norun = true }, {
	{ "<CR>", "i", "Open / accept the selected item", tags = "open select accept enter" },
	{
		{ "<C-s>", "<C-v>", "<C-t>" },
		"i",
		"Open in a split / vertical split / new tab",
		tags = "split vertical tab open",
	},
	{ { "<C-j>", "<C-n>" }, "i", "Move down the list", tags = "next down move" },
	{ { "<C-k>", "<C-p>" }, "i", "Move up the list", tags = "previous up move" },
	{ "<Tab>", "i", "Select several items", tags = "multi select mark several multiple" },
	{ "<A-q>", "i", "Send the selected items to the quickfix list", tags = "quickfix list send" },
	{ { "<S-Down>", "<S-Up>" }, "i", "Scroll the preview down / up", tags = "preview scroll" },
	{ "<F4>", "i", "Show / hide the preview", tags = "preview toggle hide" },
	{
		{ "<A-h>", "<A-i>" },
		"i",
		"Files picker: include hidden / git-ignored files",
		tags = "hidden ignored dotfiles toggle",
	},
	{ "<F1>", "i", "Show every key available in the picker", tags = "help keys" },
	{ "<Esc>", "i", "Close the picker", tags = "close quit exit cancel" },
})

-- =============================================================================
-- BUFFERS, WINDOWS & TABS
-- =============================================================================
category(
	"buffers",
	"Buffers (open files)",
	"Every file you open stays loaded as a buffer, even when it's not on screen."
)
add("buffers", { src = "config", file = KEYMAPS }, {
	{ "<leader>bn", "n", "Go to the next buffer", tags = "next buffer switch file cycle" },
	{ "<leader>bp", "n", "Go to the previous buffer", tags = "previous buffer switch file cycle back" },
	{ "<leader>bq", "n", "Close the current file (buffer)", tags = "close buffer kill delete remove close file" },
	{
		{ "]b", "[b" },
		"n",
		"Next / previous buffer (built in)",
		tags = "next previous buffer switch",
		src = "vim",
		file = false,
		secondary = true,
		norun = true,
	},
	{
		"<C-^>",
		"n",
		"Switch back to the file you were in before (alternate file)",
		tags = "previous file last file alternate toggle back switch",
		src = "vim",
		file = false,
	},
	{ ":ls", "c", "List all open buffers", tags = "buffers list open files", src = "vim", file = false },
})

category(
	"windows",
	"Windows & splits",
	"A window is a view on a buffer. Split the screen to see several files at once."
)
add("windows", { src = "config", file = KEYMAPS }, {
	{
		{ "<C-h>", "<C-j>", "<C-k>", "<C-l>" },
		"n",
		"Move to the window on the left / below / above / right (also tmux panes)",
		tags = "window switch focus move navigate pane split tmux left right up down move between windows switch window",
		src = "plugin",
		plugin = "vim-tmux-navigator",
		file = false,
		note = "keymaps.lua maps these too; vim-tmux-navigator's version runs and also crosses into tmux panes.",
		norun = true,
	},
	{
		"<C-\\>",
		"n",
		"Go back to the previously used window / tmux pane",
		tags = "window previous last pane tmux",
		src = "plugin",
		plugin = "vim-tmux-navigator",
		file = false,
	},
	{
		"<leader>sv",
		"n",
		"Split the window vertically (side by side)",
		tags = "split vertical side by side pane new window divide screen",
	},
	{
		"<leader>sh",
		"n",
		"Split the window horizontally (top / bottom)",
		tags = "split horizontal pane new window divide screen",
	},
	{
		{ "<C-Up>", "<C-Down>" },
		"n",
		"Make the window taller / shorter",
		tags = "resize height taller shorter bigger smaller window",
		norun = true,
	},
	{
		{ "<C-Left>", "<C-Right>" },
		"n",
		"Make the window narrower / wider",
		tags = "resize width wider narrower bigger smaller window",
		norun = true,
	},
	{
		"<C-w>=",
		"n",
		"Make all windows the same size",
		tags = "equal balance resize windows",
		src = "vim",
		file = false,
	},
	{ "<C-w>q", "n", "Close the current window", tags = "close window split quit", src = "vim", file = false },
	{
		"<C-w>o",
		"n",
		"Close every other window (keep only this one)",
		tags = "only close other windows maximize",
		src = "vim",
		file = false,
	},
	{ "<C-w>w", "n", "Cycle to the next window", tags = "next window switch cycle", src = "vim", file = false },
})

category("tabs", "Tabs", "A tab holds a whole layout of windows.")
add("tabs", { src = "config", file = KEYMAPS }, {
	{ "L", "n", "Go to the next tab", tags = "next tab right switch" },
	{
		"H",
		"n",
		"Go to the previous tab",
		tags = "previous tab left switch",
		note = "Shift+h / Shift+l are the same keys as H / L, so the buffer mappings keymaps.lua gives them are replaced by these. Use Space b n / Space b p for buffers.",
	},
	{
		{
			"<leader>1",
			"<leader>2",
			"<leader>3",
			"<leader>4",
			"<leader>5",
			"<leader>6",
			"<leader>7",
			"<leader>8",
			"<leader>9",
		},
		"n",
		"Go to tab number 1-9",
		tags = "tab number go switch first second third",
		display = "Space 1 … Space 9",
		norun = true,
	},
	{
		{ "gt", "gT" },
		"n",
		"Next / previous tab (built in)",
		tags = "next previous tab",
		src = "vim",
		file = false,
		norun = true,
		secondary = true,
	},
	{ ":tabnew", "c", "Open a new tab", tags = "new tab create open", src = "vim", file = false },
	{ ":tabclose", "c", "Close the current tab", tags = "close tab", src = "vim", file = false },
})

-- =============================================================================
-- FILE EXPLORER
-- =============================================================================
category("explorer", "File explorer", "The project tree on the side (nvim-tree).")
add("explorer", { src = "config", file = KEYMAPS }, {
	{
		"<leader>e",
		"n",
		"Open / close the file explorer sidebar",
		tags = "explorer tree sidebar folder files project file tree nerdtree toggle open close browse directory",
	},
	{
		"<leader>HS",
		"n",
		"Open netrw (the old built-in explorer) in a horizontal split",
		tags = "netrw explorer",
		secondary = true,
		note = "netrw is disabled in lua/config/lazy.lua, so this does nothing unless you re-enable it.",
	},
	{
		"<leader>VS",
		"n",
		"Open netrw in a vertical split",
		tags = "netrw explorer",
		secondary = true,
		note = "netrw is disabled in lua/config/lazy.lua, so this does nothing unless you re-enable it.",
	},
	{
		"<leader>nt",
		"n",
		"Open netrw in a new tab",
		tags = "netrw explorer",
		secondary = true,
		note = "netrw is disabled in lua/config/lazy.lua, so this does nothing unless you re-enable it.",
	},
	{
		"<leader>wl",
		"n",
		"Toggle a netrw explorer on the left",
		tags = "netrw explorer",
		secondary = true,
		note = "netrw is disabled, so this does nothing; in files with a language server it lists workspace folders instead.",
	},
})

category(
	"tree",
	"Inside the file explorer (nvim-tree)",
	"Keys that work in the sidebar opened with Space e. Press g? there for the full list."
)
add("tree", { src = "plugin", plugin = "nvim-tree.lua", scope = "inside the file explorer", norun = true }, {
	{ { "<CR>", "o" }, "n", "Open the file / expand or collapse the folder", tags = "open file folder expand" },
	{
		"a",
		"n",
		"Create a new file (end the name with / to make a folder)",
		tags = "new create add file folder directory touch mkdir new file create file new folder",
	},
	{ "r", "n", "Rename the file or folder", tags = "rename move file folder" },
	{ "d", "n", "Delete the file or folder", tags = "delete remove file folder" },
	{ "D", "n", "Move the file or folder to the trash", tags = "trash delete remove" },
	{ "x", "n", "Cut the file (then p to move it)", tags = "cut move file" },
	{ "c", "n", "Copy the file (then p to paste it)", tags = "copy duplicate file" },
	{ "p", "n", "Paste the cut / copied file here", tags = "paste file" },
	{ "y", "n", "Copy the file name", tags = "copy name filename" },
	{ "Y", "n", "Copy the relative path", tags = "copy relative path" },
	{ "gy", "n", "Copy the absolute path", tags = "copy absolute full path" },
	{
		{ "<C-v>", "<C-x>", "<C-t>" },
		"n",
		"Open in a vertical split / horizontal split / new tab",
		tags = "open split vertical horizontal tab",
	},
	{ "<Tab>", "n", "Preview the file (focus stays in the tree)", tags = "preview peek" },
	{ "H", "n", "Show / hide dotfiles (hidden files)", tags = "hidden dotfiles toggle show" },
	{ "I", "n", "Show / hide git-ignored files", tags = "gitignore ignored files toggle show" },
	{ "R", "n", "Refresh the tree", tags = "refresh reload update" },
	{ "-", "n", "Go up one directory (make the parent the root)", tags = "parent directory up root" },
	{ "<C-]>", "n", "Make the folder under the cursor the root", tags = "cd change root directory" },
	{ "P", "n", "Jump to the parent folder", tags = "parent folder jump" },
	{ "<BS>", "n", "Close the parent folder", tags = "collapse close folder" },
	{ { "E", "W" }, "n", "Expand all / collapse all folders", tags = "expand collapse all folders" },
	{ { "f", "F" }, "n", "Filter files by name as you type / clear the filter", tags = "filter search live" },
	{ "S", "n", "Search for a path and jump to it", tags = "search find path" },
	{ "s", "n", "Open the file with the system's default app", tags = "system open external app" },
	{ "m", "n", "Mark the file (bd deletes marked, bmv moves marked)", tags = "bookmark mark multiple" },
	{ { "[c", "]c" }, "n", "Jump to the previous / next file with git changes", tags = "git changes modified jump" },
	{ { "[e", "]e" }, "n", "Jump to the previous / next file with errors", tags = "diagnostics errors jump" },
	{ "<C-k>", "n", "Show file info (size, dates)", tags = "info details size" },
	{ "q", "n", "Close the explorer", tags = "close quit exit" },
	{ "g?", "n", "Show every explorer key", tags = "help keys" },
})

-- =============================================================================
-- CODE INTELLIGENCE (LSP)
-- =============================================================================
category(
	"lsp",
	"Code intelligence (LSP)",
	"Need a language server running for the file (Python, Go, TypeScript, Lua, C, Rust ...). Check with :LspInfo."
)
add("lsp", { src = "config", file = LSP, scope = LSP_SCOPE }, {
	{
		"K",
		"n",
		"Show documentation for the thing under the cursor (hover)",
		tags = "hover docs documentation info type signature what is this explain describe",
	},
	{
		"<leader>gd",
		"n",
		"Peek at the definition in a popup (without leaving the file)",
		tags = "definition peek preview popup where defined source",
	},
	{
		"<leader>gD",
		"n",
		"Go to the definition",
		tags = "definition jump goto go to source declaration where defined implementation",
	},
	{ "<leader>gS", "n", "Open the definition in a vertical split", tags = "definition split vertical side" },
	{
		"<leader>rn",
		"n",
		"Rename the symbol under the cursor everywhere (variable, function ...)",
		tags = "rename refactor variable function symbol identifier name change name",
	},
	{
		"<leader>ca",
		"n",
		"Show code actions (quick fixes, refactors, add missing import ...)",
		tags = "code action quick fix suggestions lightbulb auto fix import refactor fix error fix errors",
	},
	{
		"<leader>fr",
		"n",
		"List every place the symbol is used (references, fzf-lua)",
		tags = "references usages callers where used find usages calls",
	},
	{
		"<leader>fd",
		"n",
		"LSP finder: definition + references together (fzf-lua)",
		tags = "usages references definition finder",
	},
	{ "<leader>ft", "n", "Go to the type definition (fzf-lua)", tags = "type definition typedef struct interface" },
	{ "<leader>fi", "n", "Go to the implementation (fzf-lua)", tags = "implementation interface implement" },
	{
		"<leader>fw",
		"n",
		"Search symbols across the workspace (fzf-lua)",
		tags = "symbols workspace project search functions",
	},
	{
		"<leader>oi",
		"n",
		"Organize imports (and then format)",
		tags = "imports organize sort clean unused remove",
		note = "Only does something if the language server supports it (TypeScript, Go ...).",
	},
	{
		{ "<leader>wa", "<leader>wr" },
		"n",
		"Add / remove a workspace folder",
		tags = "workspace folder add remove project",
		norun = true,
	},
	{
		"<leader>cs",
		"n",
		"Toggle the symbols outline panel (Trouble)",
		tags = "outline structure symbols functions panel sidebar",
		file = "lua/plugins/trouble-nvim.lua",
		scope = false,
	},
	{
		"<leader>cl",
		"n",
		"Toggle the LSP panel: definitions, references ... (Trouble)",
		tags = "references definitions panel lsp list",
		file = "lua/plugins/trouble-nvim.lua",
		scope = false,
	},
	{
		"grn",
		"n",
		"Rename (Neovim built-in version)",
		tags = "rename refactor",
		src = "vim",
		file = false,
		secondary = true,
	},
	{
		"gra",
		"nx",
		"Code actions (Neovim built-in version)",
		tags = "code action quick fix",
		src = "vim",
		file = false,
		secondary = true,
	},
	{
		"grr",
		"n",
		"List references (Neovim built-in version)",
		tags = "references usages",
		src = "vim",
		file = false,
		secondary = true,
	},
	{
		"gri",
		"n",
		"Go to implementation (Neovim built-in version)",
		tags = "implementation",
		src = "vim",
		file = false,
		secondary = true,
	},
	{
		"grt",
		"n",
		"Go to type definition (Neovim built-in, 0.12+)",
		tags = "type definition",
		src = "vim",
		file = false,
		secondary = true,
	},
	{
		"gO",
		"n",
		"List symbols in this file (Neovim built-in)",
		tags = "symbols outline",
		src = "vim",
		file = false,
		secondary = true,
	},
	{
		"<C-s>",
		"i",
		"Show the function's parameters while typing",
		tags = "signature help parameters arguments function",
		src = "vim",
		file = false,
		norun = true,
	},
})

-- =============================================================================
-- ERRORS & DIAGNOSTICS
-- =============================================================================
category("diag", "Errors & diagnostics", "Errors, warnings and hints from language servers and linters.")
add("diag", { src = "config", file = "lua/plugins/trouble-nvim.lua" }, {
	{
		"<leader>xx",
		"n",
		"Show / hide the list of all errors & warnings in the project (Trouble)",
		tags = "errors diagnostics problems list panel workspace all trouble warnings show errors list errors toggle",
		note = "keymaps.lua also maps Space x x (a location-list toggle); Trouble's mapping is the one that runs.",
	},
	{ "<leader>xX", "n", "Problems in this file only (Trouble)", tags = "errors diagnostics buffer current file" },
	{ "<leader>xL", "n", "Show the location list (Trouble)", tags = "location list loclist" },
	{ "<leader>xQ", "n", "Show the quickfix list (Trouble)", tags = "quickfix list results" },
	{
		"<leader>xd",
		"n",
		"Show the full error message under the cursor in a popup",
		tags = "error message float popup details explain diagnostic",
		file = KEYMAPS,
	},
	{
		{ "]d", "[d" },
		"n",
		"Jump to the next / previous error or warning",
		tags = "next previous error warning diagnostic jump",
		file = KEYMAPS,
		norun = true,
	},
	{
		{ "]D", "[D" },
		"n",
		"Jump to the last / first problem in the file",
		tags = "last first error diagnostic",
		src = "vim",
		file = false,
		norun = true,
	},
	{
		"<C-w>d",
		"n",
		"Show the problems under the cursor (built in)",
		tags = "error message popup",
		src = "vim",
		file = false,
	},
	{
		"<leader>d",
		"n",
		"Show the problems at the cursor (Lspsaga popup)",
		tags = "error message popup cursor diagnostic",
		file = LSP,
		scope = LSP_SCOPE,
	},
	{
		"<leader>D",
		"n",
		"Show the problems on the whole line (Lspsaga popup)",
		tags = "error message popup line diagnostic",
		file = LSP,
		scope = LSP_SCOPE,
	},
	{
		{ "<leader>nd", "<leader>pd" },
		"n",
		"Jump to the next / previous problem with a popup (Lspsaga)",
		tags = "next previous error diagnostic jump",
		file = LSP,
		scope = LSP_SCOPE,
		norun = true,
	},
})

category(
	"trouble",
	"Inside the Trouble list",
	"Keys for the problems / symbols / references panel. Press ? there for help."
)
add("trouble", { src = "plugin", plugin = "trouble.nvim", scope = "inside a Trouble panel", norun = true }, {
	{ "<CR>", "n", "Jump to the item", tags = "open jump go" },
	{ "o", "n", "Jump to the item and close the panel", tags = "open jump close" },
	{ "p", "n", "Preview the item", tags = "preview peek" },
	{ "P", "n", "Turn automatic preview on / off", tags = "preview auto toggle" },
	{ { "}", "]]" }, "n", "Next item", tags = "next down" },
	{ { "{", "[[" }, "n", "Previous item", tags = "previous up" },
	{ { "<C-s>", "<C-v>" }, "n", "Open the item in a split / vertical split", tags = "split vertical open" },
	{ "dd", "n", "Remove the item from the list", tags = "delete remove hide" },
	{ "za", "n", "Fold / unfold a group", tags = "fold collapse group" },
	{ { "zM", "zR" }, "n", "Fold / unfold all groups", tags = "fold collapse expand all" },
	{ "r", "n", "Refresh", tags = "refresh reload" },
	{ "q", "n", "Close the panel", tags = "close quit exit" },
	{ "?", "n", "Show every Trouble key", tags = "help keys" },
})

-- =============================================================================
-- GIT
-- =============================================================================
category("git", "Git", "Blame from gitsigns, everything else through vim-fugitive's :Git command.")
add("git", { src = "plugin", plugin = "vim-fugitive" }, {
	{
		"<leader>gg",
		"n",
		"Show who last changed this line, when, and the commit (git blame popup)",
		tags = "blame who wrote author changed when commit line history",
		src = "config",
		file = KEYMAPS,
	},
	{
		"<leader>gB",
		"n",
		"Turn inline git blame for the current line on / off",
		tags = "blame inline toggle author virtual text",
		src = "config",
		file = KEYMAPS,
	},
	{
		":Git",
		"c",
		"Open the Git status window (stage, commit, push ...); :G also works",
		tags = "git status changes stage commit fugitive",
	},
	{ ":Git diff", "c", "Show your unstaged changes", tags = "git diff changes compare" },
	{
		":Gvdiffsplit",
		"c",
		"Compare this file with the last commit, side by side",
		tags = "diff compare changes side by side split",
	},
	{ ":Git blame", "c", "Blame the whole file in a side panel", tags = "blame who wrote author history" },
	{ ":Git commit", "c", "Commit the staged changes", tags = "commit save snapshot" },
	{ ":Git push", "c", "Push your commits to the remote", tags = "push upload remote github" },
	{ ":Git pull", "c", "Pull changes from the remote", tags = "pull download fetch update sync" },
	{ ":Git log", "c", "Show the commit history", tags = "log history commits" },
	{ ":Gwrite", "c", "Stage the current file (git add)", tags = "stage add file" },
	{
		":Gread",
		"c",
		"Throw away your changes to this file (back to the last commit)",
		tags = "discard revert reset checkout undo changes",
	},
	{
		":Gitsigns preview_hunk",
		"c",
		"Preview the change (hunk) under the cursor",
		tags = "hunk change preview diff",
		plugin = "gitsigns.nvim",
	},
	{
		":Gitsigns stage_hunk",
		"c",
		"Stage just the change under the cursor",
		tags = "hunk stage add partial",
		plugin = "gitsigns.nvim",
	},
	{
		":Gitsigns reset_hunk",
		"c",
		"Undo just the change under the cursor",
		tags = "hunk reset discard revert undo",
		plugin = "gitsigns.nvim",
	},
	{
		":Gitsigns nav_hunk next",
		"c",
		"Jump to the next changed block (use prev for the previous one)",
		tags = "hunk next previous change jump",
		plugin = "gitsigns.nvim",
	},
})

category(
	"fugitive",
	"Inside the Git status window (:Git)",
	"Keys for the window opened by :Git. Press g? there for the full list."
)
add("fugitive", { src = "plugin", plugin = "vim-fugitive", scope = "inside the :Git status window", norun = true }, {
	{ "s", "n", "Stage the file / change under the cursor", tags = "stage add" },
	{ "u", "n", "Unstage the file / change under the cursor", tags = "unstage remove" },
	{ "-", "n", "Stage or unstage (toggle)", tags = "stage unstage toggle" },
	{ "=", "n", "Show / hide the diff inline", tags = "diff inline expand show changes" },
	{ "dv", "n", "Open a side-by-side diff of the file", tags = "diff vertical compare" },
	{ "X", "n", "Discard the change under the cursor", tags = "discard revert reset delete" },
	{ "cc", "n", "Commit the staged changes", tags = "commit" },
	{ "ca", "n", "Amend the last commit", tags = "amend commit edit last" },
	{ { ")", "(" }, "n", "Jump to the next / previous file or change", tags = "next previous" },
	{ "<CR>", "n", "Open the file", tags = "open file" },
	{ "gq", "n", "Close the status window", tags = "close quit exit" },
	{ "g?", "n", "Show every key", tags = "help keys" },
})

-- =============================================================================
-- AUTOCOMPLETE & TYPING
-- =============================================================================
category(
	"completion",
	"Autocomplete menu",
	"The popup while typing. Suggestions come from the language server, snippets, words in the file, paths and Codeium AI."
)
add(
	"completion",
	{ src = "config", file = "lua/plugins/nvim-cmp.lua", scope = "while the completion menu is open", norun = true },
	{
		{ { "<C-j>", "<C-n>", "<Down>" }, "i", "Next suggestion", tags = "next down autocomplete suggestion" },
		{ { "<C-k>", "<C-p>", "<Up>" }, "i", "Previous suggestion", tags = "previous up autocomplete suggestion" },
		{
			{ "<CR>", "<C-y>" },
			"i",
			"Accept the selected suggestion (Enter only accepts if you picked one)",
			tags = "accept confirm autocomplete select suggestion",
		},
		{
			"<C-Space>",
			"i",
			"Open the suggestion menu yourself",
			tags = "trigger open autocomplete suggestion manually",
			scope = false,
		},
		{ "<C-e>", "i", "Close the suggestion menu", tags = "close cancel abort dismiss" },
		{ { "<C-f>", "<C-b>" }, "i", "Scroll the documentation popup down / up", tags = "docs documentation scroll" },
	}
)

category("insert", "Typing helpers (Insert mode)", "Handy keys while you're typing text.")
add("insert", { src = "vim", norun = true }, {
	{ "<C-w>", "i", "Delete the word before the cursor", tags = "delete word backspace" },
	{ "<C-u>", "i", "Delete everything before the cursor on this line", tags = "delete line clear" },
	{ "<C-o>", "i", "Run one Normal-mode command, then keep typing", tags = "normal command once" },
	{
		"<C-r>",
		"i",
		"Paste a register while typing: Ctrl+r then + pastes the clipboard",
		tags = "paste clipboard register",
	},
	{
		"<Insert>",
		"i",
		"Move the cursor one character right",
		tags = "move right cursor",
		src = "config",
		file = KEYMAPS,
	},
	{ "<C-Insert>", "i", "Move the cursor one line down", tags = "move down cursor", src = "config", file = KEYMAPS },
})

-- =============================================================================
-- FOLDING
-- =============================================================================
category("fold", "Folding (collapse code)", "Folds come from treesitter and start fully open.")
add("fold", { src = "vim" }, {
	{ "za", "n", "Fold / unfold the block under the cursor", tags = "fold collapse expand toggle hide code block" },
	{
		{ "zc", "zo" },
		"n",
		"Close / open the fold under the cursor",
		tags = "fold close open collapse expand",
		norun = true,
	},
	{ "zM", "n", "Fold everything", tags = "fold collapse all close all" },
	{ "zR", "n", "Unfold everything", tags = "unfold expand all open all" },
})

-- =============================================================================
-- DEBUGGING
-- =============================================================================
category("debug", "Debugging (Rust)", "nvim-dap + dap-ui. The debugger UI opens and closes by itself.")
add("debug", { src = "config", file = LSP, scope = "Rust files, once rust-analyzer is running" }, {
	{ "<leader>dc", "n", "Start / continue debugging", tags = "debug start run continue debugger launch" },
	{ "<leader>db", "n", "Toggle a breakpoint on this line", tags = "breakpoint stop pause debug" },
	{ "<leader>do", "n", "Step over (run this line)", tags = "step over next line debug" },
	{ "<leader>di", "n", "Step into the function call", tags = "step into function debug" },
	{ "<leader>du", "n", "Step out of the current function", tags = "step out return debug" },
	{ "<leader>dr", "n", "Open the debug console (REPL)", tags = "repl console debug evaluate" },
	{
		":RustLsp debuggables",
		"c",
		"Pick a Rust target to debug",
		tags = "rust debug target run",
		src = "plugin",
		plugin = "rustaceanvim",
		file = false,
	},
	{
		":RustLsp runnables",
		"c",
		"Pick something to run (binaries, tests ...)",
		tags = "rust run test cargo",
		src = "plugin",
		plugin = "rustaceanvim",
		file = false,
	},
	{
		":RustLsp explainError",
		"c",
		"Explain the Rust error under the cursor",
		tags = "rust error explain",
		src = "plugin",
		plugin = "rustaceanvim",
		file = false,
	},
})

-- =============================================================================
-- FOCUS, COLORS & AI
-- =============================================================================
category("ui", "Focus, colors & AI", "Zen mode, the color picker and Codeium.")
add("ui", { src = "plugin" }, {
	{
		"<leader>z",
		"n",
		"Toggle Zen mode: centered, distraction free, dims other code",
		tags = "zen focus distraction free center minimal presentation twilight dim",
		src = "config",
		file = "lua/plugins/zen-mode.lua",
	},
	{
		":Twilight",
		"c",
		"Dim everything except the code you're working on",
		tags = "dim focus highlight",
		plugin = "twilight.nvim",
	},
	{
		":CccPick",
		"c",
		"Open the color picker (edits the color under the cursor)",
		tags = "color colour picker hex rgb css",
		plugin = "ccc.nvim",
	},
	{
		":CccConvert",
		"c",
		"Convert the color under the cursor (hex / rgb / hsl)",
		tags = "color colour convert hex rgb hsl",
		plugin = "ccc.nvim",
	},
	{
		":CccHighlighterToggle",
		"c",
		"Show / hide color previews next to color codes",
		tags = "color colour preview highlight",
		plugin = "ccc.nvim",
	},
	{
		":Codeium Auth",
		"c",
		"Log in to Codeium / Windsurf AI (needed once)",
		tags = "ai login auth token copilot codeium",
		plugin = "windsurf.nvim",
	},
	{
		":Codeium Toggle",
		"c",
		"Turn Codeium AI suggestions on / off",
		tags = "ai toggle enable disable copilot codeium",
		plugin = "windsurf.nvim",
	},
})

-- =============================================================================
-- CONFIG & PLUGINS
-- =============================================================================
category(
	"config",
	"Config, plugins & tools",
	"Reloading the config and managing plugins, language servers and the fff index."
)
add("config", { src = "config", file = KEYMAPS }, {
	{ "<leader>rk", "n", "Reload keymaps.lua", tags = "reload refresh keymaps source" },
	{
		"<leader>rc",
		"n",
		"Reload init.lua (the whole config)",
		tags = "reload refresh config source restart",
		note = "Plugins don't fully reload this way; restart Neovim after big changes.",
	},
	{
		"<leader>rl",
		"n",
		"Reload plugins (Lazy reload)",
		tags = "reload plugins lazy",
		note = "To reload one plugin, run :Lazy reload <plugin-name>.",
	},
	{
		"<leader>rs",
		"n",
		"Install / update / clean plugins (Lazy sync)",
		tags = "update upgrade install plugins sync lazy",
	},
	{
		":Lazy",
		"c",
		"Open the plugin manager",
		tags = "plugins lazy manager install update",
		src = "plugin",
		plugin = "lazy.nvim",
		file = false,
	},
	{
		":Mason",
		"c",
		"Install language servers, formatters and linters",
		tags = "lsp install server formatter linter tools",
		src = "plugin",
		plugin = "mason.nvim",
		file = false,
	},
	{
		":LspInfo",
		"c",
		"Show which language servers are running",
		tags = "lsp servers running status info",
		file = "lua/plugins/mason-lsp.lua",
	},
	{
		":checkhealth",
		"c",
		"Check your setup for problems",
		tags = "health doctor problem broken diagnose check",
		src = "vim",
		file = false,
	},
	{
		":FFFScan",
		"c",
		"Rescan files for the fff finder (when added files don't show up)",
		tags = "fff rescan refresh index files",
		src = "plugin",
		plugin = "fff",
		file = false,
	},
	{
		":FFFHealth",
		"c",
		"Check that the fff finder is installed correctly",
		tags = "fff health check",
		src = "plugin",
		plugin = "fff",
		file = false,
	},
	{
		":FFFClearCache",
		"c",
		"Clear fff caches (file ranking history and file index)",
		tags = "fff cache clear reset frecency",
		src = "plugin",
		plugin = "fff",
		file = false,
	},
	{
		":TSUpdate",
		"c",
		"Update treesitter parsers (syntax highlighting)",
		tags = "treesitter syntax highlighting parsers update",
		src = "plugin",
		plugin = "nvim-treesitter",
		file = false,
	},
})

-- =============================================================================
-- INSIDE THIS GUIDE
-- =============================================================================
category("inguide", "Inside the keymap guide", "Keys for the window opened with Space k.")
add("inguide", { src = "config", file = "lua/keyguide/ui.lua", scope = "inside the keymap guide", norun = true }, {
	{
		"abc",
		"i",
		"Type what you want to do in your own words, or a key like 'space f f' to see what it does",
		tags = "search type query words",
		display = "(just type)",
	},
	{
		"<CR>",
		"i",
		"Run the selected shortcut (commands are put on the : line for you to finish)",
		tags = "run execute try",
	},
	{ { "<Down>", "<C-n>", "<C-j>", "<Tab>" }, "i", "Next result", tags = "next down" },
	{ { "<Up>", "<C-p>", "<C-k>", "<S-Tab>" }, "i", "Previous result", tags = "previous up" },
	{ "<C-u>", "i", "Clear what you typed", tags = "clear reset" },
	{ { "<Esc>", "<C-c>" }, "i", "Close the guide", tags = "close quit exit" },
})

return M
