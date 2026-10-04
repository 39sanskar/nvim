-- ================================================================================================
-- TITLE : fff
-- LINKS :
--   > github : https://github.com/dmtrKovalenko/fff
-- ABOUT : very fast fuzzy file finder & live grep with frecency ranking (rust core).
-- NOTES : the native binary is downloaded on install, or built with cargo if no prebuilt exists.
--         fzf-lua keeps its pickers on <leader>fF / <leader>fG as a fallback.
-- ================================================================================================

return {
	"dmtrKovalenko/fff",
	build = function()
		-- downloads a prebuilt binary or falls back to cargo build
		require("fff.download").download_or_build_binary()
	end,
	lazy = false, -- the plugin lazy-initialises itself
	opts = {
		layout = {
			prompt_position = "top",
		},
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("fff").find_files()
			end,
			desc = "Find files (fff)",
		},
		{
			"<leader>fg",
			function()
				require("fff").live_grep()
			end,
			desc = "Search text in project (fff)",
		},
		{
			"<leader>fz",
			function()
				require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
			end,
			desc = "Fuzzy text search, typo tolerant (fff)",
		},
		{
			"<leader>fc",
			function()
				require("fff").live_grep_under_cursor()
			end,
			mode = { "n", "x" },
			desc = "Search word under cursor / selection (fff)",
		},
		{
			"<leader>fl",
			function()
				require("fff").resume()
			end,
			desc = "Reopen last search (fff)",
		},
	},
}
