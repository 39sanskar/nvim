return {
	"glepnir/lspsaga.nvim",
	lazy = false,
	config = function()
		require("lspsaga").setup({
			move_in_saga = { prev = "<C-k>", next = "<C-j>" },

			finder_action_keys = {
				open = "<CR>",
			},

			definition_action_keys = {
				edit = "<CR>",
			},

			-- 🔴 ADD THIS PART
			ui = {
				title = false,
				border = "rounded",
			},

			lightbulb = {
				enable = false,
			},

			-- disable progress UI (important)
			request_timeout = 2000,
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
}

