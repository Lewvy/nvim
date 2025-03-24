return {

	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = true,
	keys = {
		{
			"<leader>re",
			mode = "x",
			function()
				vim.cmd(":Refactor extract ")
			end,
			desc = "Extract selection",
		},
		{
			"<leader>rf",
			mode = "x",
			function()
				vim.cmd(":Refactor extract_to_file ")
			end,
			desc = "Extract to file",
		},
		{
			"<leader>rv",
			mode = "x",
			function()
				vim.cmd(":Refactor extract_var ")
			end,
			desc = "Extract variable",
		},
		{
			"<leader>ri",
			mode = { "n", "x" },
			function()
				vim.cmd(":Refactor inline_var")
			end,
			desc = "Inline variable",
		},
		{
			"<leader>rI",
			mode = "n",
			function()
				vim.cmd(":Refactor inline_func")
			end,
			desc = "Inline function",
		},
		{
			"<leader>rb",
			mode = "n",
			function()
				vim.cmd(":Refactor extract_block")
			end,
			desc = "Extract block",
		},
		{
			"<leader>rbf",
			mode = "n",
			function()
				vim.cmd(":Refactor extract_block_to_file")
			end,
			desc = "Extract block to file",
		},
	},
	config = function()
		require("refactoring").setup({
			prompt_func_return_type = {
				go = true,
				java = true,

				cpp = true,
				c = true,
				h = true,
				hpp = true,
				cxx = true,
			},
			prompt_func_param_type = {
				go = true,
				java = true,

				cpp = true,
				c = true,
				h = true,
				hpp = true,
				cxx = true,
			},
			printf_statements = {},
			print_var_statements = {},
			show_success_message = true, -- shows a message with information about the refactor on success
			-- i.e. [Refactor] Inlined 3 variable occurrences
		})
	end,
}
