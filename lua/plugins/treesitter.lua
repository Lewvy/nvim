return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
	},
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			auto_install = true,
			ensure_installed = { "lua", "javascript", "c", "cpp" },
			highlight = { enable = true },
			indent = { enable = true },
			modules = {
				"textobjects",
				"incremental_selection",
			},
			sync_install = false,
			ignore_install = {},
		})
	end,
}
