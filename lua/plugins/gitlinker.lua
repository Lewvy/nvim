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

		gitlinker.setup({
			-- Primary mapping to generate and copy links
			mappings = "<leader>gy",

			-- Enhanced URL generation options
			opts = {
				remote = "origin", -- prefer 'origin' remote when available
				add_current_line_on_normal_mode = true,
				print_url = false, -- set to true for debugging
				action_callback = actions.copy_to_clipboard, -- or actions.open_in_browser

				-- Custom URL patterns for various git hosts
				callbacks = {
					-- GitHub
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

					-- GitLab
					["gitlab.com"] = function(url_data)
						return string.format(
							"https://gitlab.com/%s/%s/-/blob/%s/%s#L%s",
							url_data.repo,
							url_data.rev,
							url_data.file,
							url_data.lstart or 1
						)
					end,

					-- Bitbucket
					["bitbucket.org"] = function(url_data)
						return string.format(
							"https://bitbucket.org/%s/%s/src/%s/%s#lines-%s",
							url_data.repo,
							url_data.rev,
							url_data.file,
							url_data.lstart or 1
						)
					end,

					-- Fallback for unknown hosts
					["default"] = function(url_data)
						return string.format(
							"%s/%s/blob/%s/%s#L%s",
							url_data.host,
							url_data.repo,
							url_data.rev,
							url_data.file,
							url_data.lstart or 1
						)
					end,
				},

				-- SSH to HTTPS conversion patterns
				ssh_to_https = true,
				url_patterns = {
					["^git@(.+):(.+)/(.+).git$"] = "https://%1/%2/%3",
					["^ssh://git@(.+)/(.+)/(.+).git$"] = "https://%1/%2/%3",
				},

				-- Error handling
				error_notifier = function(msg)
					vim.notify("GitLinker: " .. msg, vim.log.levels.ERROR)
				end,
			},
		})

		-- Additional keymaps for different workflows
		vim.keymap.set({ "n", "v" }, "<leader>gY", function()
			gitlinker.get_buf_range_url("n", { action_callback = actions.open_in_browser })
		end, { desc = "Open git link in browser" })

		-- Git blame line linking
		vim.keymap.set("n", "<leader>gB", function()
			gitlinker.get_repo_url({
				action_callback = actions.copy_to_clipboard,
				rev = vim.fn.input("Commit hash (blank for current): "),
			})
		end, { desc = "Copy commit URL" })

		-- Enhanced branch/tag selector with Telescope
		vim.keymap.set("n", "<leader>gT", function()
			-- Get git branches and tags
			local get_git_list = function(cmd)
				local handle = io.popen(cmd .. " 2>/dev/null")
				if handle then
					local result = handle:read("*a")
					handle:close()
					return vim.split(result, "\n")
				end
				return {}
			end

			local branches = get_git_list("git branch --format='%(refname:short)' --sort=-committerdate")
			local tags = get_git_list("git tag --list --sort=-creatordate")

			-- Create Telescope entries with icons
			local entries = {}
			for _, branch in ipairs(branches) do
				if branch ~= "" then
					table.insert(entries, {
						value = branch,
						display = "󰘬 " .. branch,
						ordinal = "branch:" .. branch,
					})
				end
			end
			for _, tag in ipairs(tags) do
				if tag ~= "" then
					table.insert(entries, {
						value = tag,
						display = "󰓅 " .. tag,
						ordinal = "tag:" .. tag,
					})
				end
			end

			if #entries == 0 then
				vim.notify("No branches or tags found", vim.log.levels.WARN)
				return
			end

			-- Create and run Telescope picker
			local picker = require("telescope.pickers").new({
				prompt_title = "Select Branch/Tag",
				finder = require("telescope.finders").new_table({
					results = entries,
					entry_maker = function(entry)
						return {
							value = entry.value,
							display = entry.display,
							ordinal = entry.ordinal,
						}
					end,
				}),
				sorter = require("telescope.config").values.generic_sorter({}),
				previewer = false,
				layout_config = {
					width = 0.6,
					height = 0.4,
				},
			})

			picker:find()

			-- Handle selection
			local ok = pcall(require, "telescope.actions.state")
			if not ok then
				return
			end

			vim.schedule(function()
				local selection = require("telescope.actions.state").get_selected_entry()
				if selection then
					gitlinker.get_repo_url({
						action_callback = actions.copy_to_clipboard,
						rev = selection.value,
					})
				end
			end)
		end, { desc = "Copy branch/tag URL (Telescope)" })

		-- ... (keep other existing keymaps)
	end,
}
