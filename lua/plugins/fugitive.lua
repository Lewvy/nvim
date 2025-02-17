return {
	{
		"tpope/vim-fugitive",
		dependencies = {
			"tpope/vim-rhubarb", -- Adds GitHub :GBrowse support
			"lewis6991/gitsigns.nvim", -- Optional but recommended for inline diffs
			"sindrets/diffview.nvim", -- Better diff viewing
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			-- Basic Git operations
			{
				"<leader>gf",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "Search tracked files",
			},
			{ "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
			{ "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Git Diff" },
			{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },

			-- Staging
			{ "<leader>ga", ":Git add %<cr>", desc = "Stage Current File" },
			{ "<leader>gu", ":Git reset %<cr>", desc = "Unstage Current File" },

			-- Committing
			{ "<leader>gc", "<cmd>Git commit<cr>", desc = "Git Commit" },
			{ "<leader>gC", "<cmd>Git commit --amend<cr>", desc = "Amend Commit" },

			-- Branching
			{ "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
			{ "<leader>gP", "<cmd>Git pull<cr>", desc = "Git Pull" },
			{ "<leader>gB", "<cmd>Git branch<cr>", desc = "List Branches" },

			-- Advanced
			{ "<leader>gl", "<cmd>Git log<cr>", desc = "Git Log" },
			{ "<leader>gr", "<cmd>Git rebase -i<cr>", desc = "Interactive Rebase" },
		},
		config = function()
			-- Custom Fugitive commands
			vim.cmd([[
        command! -bang -nargs=? -complete=dir GFetch execute 'Git fetch' <args>
        command! -bang -nargs=? -complete=dir GMerge execute 'Git merge' <args>
        command! -bang -nargs=? -complete=dir GCheckout execute 'Git checkout' <args>
      ]])

			-- Enhanced diff integration with diffview.nvim
			vim.keymap.set("n", "<leader>gD", function()
				if package.loaded.diffview then
					vim.cmd("DiffviewOpen")
				else
					vim.cmd("Gvdiffsplit")
				end
			end, { desc = "Enhanced Diff View" })

			-- Toggle inline blame
			vim.keymap.set("n", "<leader>gt", function()
				if vim.b.gitsigns_blame_line then
					require("gitsigns").toggle_current_line_blame()
				else
					vim.cmd("Git blame")
				end
			end, { desc = "Toggle Blame" })

			-- GitHub integration
			vim.keymap.set("n", "<leader>gO", "<cmd>.GBrowse<cr>", { desc = "Open in GitHub" })
			vim.keymap.set("v", "<leader>gO", ":GBrowse<cr>", { desc = "Open Selection in GitHub" })

			-- Auto-reload files after Git operations
			vim.api.nvim_create_autocmd("User", {
				pattern = "Fugitive*",
				callback = function()
					if package.loaded.gitsigns then
						require("gitsigns").refresh()
					end
				end,
			})
		end,
	},
	-- Optional: Add these if you want the full Git experience
	{
		"lewis6991/gitsigns.nvim",
		config = true,
	},
	{
		"sindrets/diffview.nvim",
		config = true,
	},
}
