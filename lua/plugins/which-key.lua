-- ================================================================================================
-- TITLE : which-key
-- ABOUT : WhichKey helps you remember your Neovim keymaps, by showing keybindings as you type.
-- LINKS :
--   > github : https://github.com/folke/which-key.nvim
-- ================================================================================================

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- names for the <leader> prefixes shown in the popup
		spec = {
			{ "<leader>b", group = "buffers" },
			{ "<leader>c", group = "code" },
			{ "<leader>f", group = "find / search" },
			{ "<leader>g", group = "git / go to definition" },
			{ "<leader>r", group = "reload / rename" },
			{ "<leader>s", group = "split window" },
			{ "<leader>x", group = "diagnostics" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
