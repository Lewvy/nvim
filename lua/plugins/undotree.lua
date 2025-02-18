return {
	"jiaoshijie/undotree",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- For file icons
	},
	keys = {
		{ "<leader>u", "<cmd>lua require('undotree').toggle()<cr>", desc = "Toggle Undotree" },
	},
	config = function()
		require("undotree").setup({
			window = {
				positions = { "right", "bottom" }, -- Main window position and diff panel position
				split_above = false, -- Open undotree below current buffer
				width = 40, -- Width of undotree panel
				diff_panel_size = 15, -- Height of diff panel
				auto_open_diff = false, -- Don't auto-open diff panel
			},
			keymaps = {
				["j"] = "move_next",
				["k"] = "move_prev",
				["J"] = "move_change_next",
				["K"] = "move_change_prev",
				["<cr>"] = "action_enter",
				["q"] = "quit",
				["<esc>"] = "quit",
			},
			show_diff_line = true, -- Show diff in statusline
			highlight_diff_ln = true, -- Highlight changed lines
			highlight_diff_text = true, -- Highlight changed text
			float_diff = false, -- Don't use floating window for diff
		})

		-- Auto-open undotree when opening undo files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "undotree",
			callback = function()
				vim.wo.signcolumn = "no" -- Disable sign column
				vim.wo.number = false -- Disable line numbers
				vim.wo.relativenumber = false
			end,
		})

		-- Integration with which-key
		local wk = require("which-key")
		wk.register({
			u = {
				name = "+undo",
				u = "Toggle Undotree",
				t = { "<cmd>UndotreeToggle<cr>", "Toggle Tree" },
				f = { "<cmd>UndotreeFocus<cr>", "Focus Tree" },
				h = { "<cmd>UndotreeHide<cr>", "Hide Tree" },
			},
		}, { prefix = "<leader>" })
	end,
}
