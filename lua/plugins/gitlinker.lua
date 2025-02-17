return {
	"ruifm/gitlinker.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"tpope/vim-fugitive",
		"nvim-telescope/telescope.nvim",
		"nvim-telescope/telescope-fzf-native.nvim",
	},
	config = function()
		local gitlinker = require("gitlinker")
		local actions = require("gitlinker.actions")
		local telescope = require("telescope")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values

		-- Helper function to create Telescope pickers
		local create_git_picker = function(items, title, callback)
			local entries = {}
			for _, item in ipairs(items) do
				if item ~= "" then
					table.insert(entries, {
						value = item,
						display = item,
						ordinal = item,
					})
				end
			end

			if #entries == 0 then
				return
			end

			pickers
				.new({
					prompt_title = title,
					finder = finders.new_table({
						results = entries,
						entry_maker = function(entry)
							return {
								value = entry.value,
								display = entry.display,
								ordinal = entry.ordinal,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					previewer = false,
					layout_strategy = "vertical",
					layout_config = {
						width = 0.8,
						height = 0.6,
						preview_cutoff = 1,
					},
				})
				:find()

			vim.schedule(function()
				local selection = require("telescope.actions.state").get_selected_entry()
				if selection then
					callback(selection.value)
				end
			end)
		end

		-- Setup GitLinker with enhanced defaults
		gitlinker.setup({
			mappings = nil, -- Disable default mappings
			opts = {
				callbacks = {
					["github.com"] = function(url_data)
						local url = string.format(
							"https://github.com/%s/%s/blob/%s/%s",
							url_data.repo,
							url_data.rev,
							url_data.file
						)
						if url_data.lstart then
							url = url .. "#L" .. url_data.lstart
							if url_data.lend then
								url = url .. "-L" .. url_data.lend
							end
						end
						return url
					end,
				},
				ssh_to_https = true,
				print_url = false,
			},
		})

		-- Enhanced keybinds with Telescope integration
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { desc = desc })
		end

		-- Current line/buffer URL
		map("n", "<leader>gy", function()
			gitlinker.get_buf_range_url("n", {
				action_callback = actions.copy_to_clipboard,
			})
		end, "Copy line URL")

		-- Visual selection URL
		map("v", "<leader>gy", function()
			gitlinker.get_buf_range_url("v", {
				action_callback = actions.copy_to_clipboard,
			})
		end, "Copy selection URL")

		-- Commit history browser
		map("n", "<leader>gC", function()
			local commits = vim.fn.systemlist("git log --oneline --no-decorate -n 50 --format='%h %s'")
			create_git_picker(commits, "Select Commit", function(commit)
				local hash = vim.split(commit, " ")[1]
				gitlinker.get_repo_url({
					action_callback = actions.copy_to_clipboard,
					rev = hash,
				})
			end)
		end, "Copy commit URL")

		-- Branch/tag browser
		map("n", "<leader>gT", function()
			local branches =
				vim.fn.systemlist("git branch --format='%(refname:short)' --sort=-committerdate | head -n 20")
			local tags = vim.fn.systemlist("git tag --list --sort=-creatordate | head -n 20")
			create_git_picker(vim.list_extend(branches, tags), "Branch/Tag", function(rev)
				gitlinker.get_repo_url({
					action_callback = actions.copy_to_clipboard,
					rev = rev,
				})
			end)
		end, "Copy branch/tag URL")

		-- File history browser
		map("n", "<leader>gH", function()
			local commits = vim.fn.systemlist(
				"git log --oneline --no-decorate --follow -n 50 --format='%h %s' -- " .. vim.fn.expand("%")
			)
			create_git_picker(commits, "File History", function(commit)
				local hash = vim.split(commit, " ")[1]
				gitlinker.get_repo_url({
					action_callback = actions.copy_to_clipboard,
					rev = hash,
					file = vim.fn.expand("%"),
				})
			end)
		end, "File history URL")

		-- Open in browser with selection
		map("n", "<leader>gO", function()
			gitlinker.get_repo_url({
				action_callback = actions.open_in_browser,
			})
		end, "Open repo in browser")

		-- Current PR/MR context
		map("n", "<leader>gP", function()
			local branch = vim.fn.system("git branch --show-current | tr -d '\n'")
			gitlinker.get_repo_url({
				action_callback = actions.copy_to_clipboard,
				rev = branch,
				pull_request = true,
			})
		end, "Copy PR/MR URL")
	end,
}
