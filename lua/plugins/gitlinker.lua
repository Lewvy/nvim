return {
	"ruifm/gitlinker.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"tpope/vim-fugitive",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local gitlinker = require("gitlinker")
		local actions = require("gitlinker.actions")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values

		-- Helper function to create consistent Telescope pickers
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
						mirror = true,
						preview_cutoff = 0,
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

		-- Configure GitLinker
		gitlinker.setup({
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

		-- Keybind: Copy line URL
		vim.keymap.set("n", "<leader>ggc", function()
			local commits = get_git_list("git log --oneline -n 50")
			create_git_picker(commits, "Commits", function(commit)
				local hash = commit:match("^(%x+)")
				if hash then
					gitlinker.get_repo_url({
						action_callback = actions.copy_to_clipboard,
						rev = hash,
					})
				end
			end)
		end, { desc = "Git Commit history" })
		vim.keymap.set({ "n", "v" }, "<leader>ggy", function()
			gitlinker.get_buf_range_url(vim.fn.mode(), {
				action_callback = actions.copy_to_clipboard,
			})
		end, { desc = "Git Copy link to clipboard" })

		-- Keybind: Browse commits
		vim.keymap.set("n", "<leader>ggp", function()
			local commits = vim.fn.systemlist("git log --oneline --no-decorate -n 50 --format='%h %s'")
			create_git_picker(commits, "Select Commit", function(commit)
				local hash = vim.split(commit, " ")[1]
				gitlinker.get_repo_url({
					action_callback = actions.copy_to_clipboard,
					rev = hash,
				})
			end)
		end, { desc = "Git Copy commit URL" })

		-- Keybind: Browse branches/tags
		vim.keymap.set("n", "<leader>ggt", function()
			local branches =
				vim.fn.systemlist("git branch --format='%(refname:short)' --sort=-committerdate | head -n 20")
			local tags = vim.fn.systemlist("git tag --list --sort=-creatordate | head -n 20")
			create_git_picker(vim.list_extend(branches, tags), "Select Branch/Tag", function(rev)
				gitlinker.get_repo_url({
					action_callback = actions.copy_to_clipboard,
					rev = rev,
				})
			end)
		end, { desc = "Git Copy branch/tag URL" })

		-- Keybind: File history
		vim.keymap.set("n", "<leader>ggh", function()
			local commits = vim.fn.systemlist(
				string.format(
					"git log --oneline --no-decorate --follow -n 50 --format='%%h %%s' -- %s",
					vim.fn.expand("%")
				)
			)
			create_git_picker(commits, "File History", function(commit)
				local hash = vim.split(commit, " ")[1]
				gitlinker.get_repo_url({
					action_callback = actions.copy_to_clipboard,
					rev = hash,
					file = vim.fn.expand("%"),
				})
			end)
		end, { desc = "Git Copy file history URL" })
	end,
	vim.keymap.set("n", "<leader>ggP", function()
		gitlinker.get_repo_url({
			action_callback = function(url)
				vim.fn.system("echo " .. vim.fn.shellescape(url) .. " | pbcopy")
				vim.notify("Copied PR URL: " .. url)
			end,
			pull_request = true,
		})
	end, { desc = "Copy PR URL" }),
}
