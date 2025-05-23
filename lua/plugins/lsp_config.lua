return {
	-- Ensure Mason is loaded early
	{
		"williamboman/mason.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("mason").setup()
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"simrat39/rust-tools.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			local function safe_require(module)
				local ok, lib = pcall(require, module)
				if not ok then
					vim.notify("Error loading " .. module, vim.log.levels.ERROR)
					return nil
				end
				return lib
			end

			local lspconfig = safe_require("lspconfig")
			local mason = safe_require("mason")
			local mason_lspconfig = safe_require("mason-lspconfig")
			local mason_tool_installer = safe_require("mason-tool-installer")
			local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")

			if not (lspconfig and mason and mason_lspconfig and mason_tool_installer and cmp_nvim_lsp) then
				vim.notify(
					"Failed to load essential modules for LSP.  Check your plugin installation.",
					vim.log.levels.ERROR
				)
				return
			end

			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Monkey patch vim.lsp.util.make_position_params
			local make_position_params = vim.lsp.util.make_position_params
			vim.lsp.util.make_position_params = function(bufnr, pos, params)
				params = params or {}
				params.position_encoding = "utf-8" -- Add position_encoding here
				return make_position_params(bufnr, pos, params)
			end

			local function on_attach(client, bufnr)
				-- Keymaps for LSP
				local keymap = {
					gd = { require("telescope.builtin").lsp_definitions, "Goto Definition" },
					gr = { require("telescope.builtin").lsp_references, "Goto References" },
					gI = { require("telescope.builtin").lsp_implementations, "Goto Implementation" },
					["<leader>rn"] = { vim.lsp.buf.rename, "Rename" },
					["<leader>ca"] = { vim.lsp.buf.code_action, "Code Action" },
					K = { vim.lsp.buf.hover, "Hover Documentation" },
				}

				for keys, mapping in pairs(keymap) do
					vim.keymap.set("n", keys, mapping[1], { buffer = bufnr, desc = "LSP: " .. mapping[2] })
				end

				if client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = bufnr,
						callback = function()
							vim.defer_fn(vim.lsp.buf.document_highlight, 100)
						end,
					})
					vim.api.nvim_create_autocmd("CursorMoved", {
						buffer = bufnr,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end

			-- Explicitly setup gopls with basic configuration
			lspconfig.gopls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					gopls = {
						usePlaceholders = true,
					},
				},
			})

			local servers = {
				clangd = { cmd = { "clangd", "--offset-encoding=utf-16" } },
				lua_ls = { settings = { Lua = { completion = { callSnippet = "Replace" } } } },
				pyright = {},
			}

			-- Ensure tools are installed with mason-tool-installer
			local tools_to_ensure = vim.tbl_keys(servers)

			mason_tool_installer.setup({ ensure_installed = tools_to_ensure })

			-- Use mason-lspconfig to configure all servers
			mason_lspconfig.setup({
				ensure_installed = tools_to_ensure,
				automatic_installation = true,
				handlers = {
					function(server_name)
						if server_name ~= "gopls" then
							lspconfig[server_name].setup({
								capabilities = capabilities,
								on_attach = on_attach,
								settings = servers[server_name] and servers[server_name].settings or {},
							})
						end
					end,
				},
			})
		end,
	},

	-- Formatting with conform.nvim
	{
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			vim.keymap.set("", "<leader>Fm", function()
				require("conform").format({ async = true })
			end, { desc = "Format code" }),
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				return {
					timeout_ms = 500,
					lsp_fallback = vim.bo[bufnr].filetype ~= "java",
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofumpt" },
				javascript = { "prettierd" },
				-- Add formatters for other file types
			},
		},
	},

	-- Debugging with nvim-dap
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-dap-lldb",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
		},
		lazy = true,
		event = { "BufReadPost" }, -- Load after opening a file
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			require("dap-go").setup()
			-- Setup DAP UI
			dapui.setup()

			-- Auto open/close UI on debug start/stop
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Keymaps for Debugging
			local keymap = vim.keymap.set
			keymap("n", "<F5>", require("dap").continue, { desc = "Start/Continue Debugging" })
			keymap("n", "<F10>", require("dap").step_over, { desc = "Step Over" })
			keymap("n", "<F11>", require("dap").step_into, { desc = "Step Into" })
			keymap("n", "<F12>", require("dap").step_out, { desc = "Step Out" })
			keymap("n", "<Leader>db", require("dap").toggle_breakpoint, { desc = "Toggle Breakpoint" })
			keymap("n", "<Leader>dB", function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Conditional Breakpoint" })
			keymap("n", "<Leader>dr", require("dap").repl.open, { desc = "Open Debug Console" })
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					console = "integratedTerminal",
					justMyCode = false,
					stopOnEntry = false,
					-- Add this line to specify the debug adapter:
					-- More information about the adapter:
					-- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
					pythonPath = "/usr/bin/python3", --REPLACE WITH YOUR PATH
				},
			}
		end,
	},

	-- nvim-dap-lldb Configuration
	{
		"julianolf/nvim-dap-lldb",
		dependencies = { "mfussenegger/nvim-dap" },
		lazy = true,
		event = { "BufReadPost" }, -- Load after opening a file
		config = function()
			require("dap-lldb").setup({
				configurations = {
					c = {
						{
							name = "Launch Debugger",
							type = "lldb",
							request = "launch",
							cwd = "${workspaceFolder}",
							program = function()
								local out = vim.fn.system({ "make", "debug" })
								if vim.v.shell_error ~= 0 then
									vim.notify(out, vim.log.levels.ERROR)
									return nil
								end
								return "./a.out"
							end,
						},
					},
					cpp = {
						{
							name = "Launch Debugger",
							type = "lldb",
							request = "launch",
							cwd = "${workspaceFolder}",
							program = function()
								local out = vim.fn.system({ "make", "debug" })
								if vim.v.shell_error ~= 0 then
									vim.notify(out, vim.log.levels.ERROR)
									return nil
								end
								return "./a.out"
							end,
						},
					},
					rust = {
						{
							name = "Launch Debugger",
							type = "lldb",
							request = "launch",
							cwd = "${workspaceFolder}",
							program = function()
								return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
							end,
						},
					},
				},
			})
		end,
	},

	-- DAP UI
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		lazy = true,
		event = { "BufReadPost" }, -- Load after opening a file
		config = function()
			local dapui = require("dapui")
			dapui.setup()
		end,
	},

	-- Neotest NIO (if you use Neotest)
	{
		"nvim-neotest/nvim-nio",
		lazy = true,
		event = { "BufReadPost" }, -- Load after opening a file
	},
	-- Add nvim-dap-go
	{
		"leoluz/nvim-dap-go",
		dependencies = "mfussenegger/nvim-dap",
		lazy = true,
		event = { "BufReadPost" },
		config = function()
			require("dap-go").setup()
		end,
	},
	-- Python Debug Adapter
	{
		"mfussenegger/nvim-dap-python",
		lazy = true,
		config = function()
			-- Make sure you have python installed: https://www.python.org/downloads/
			require("dap-python").setup("/usr/bin/python3") --REPLACE WITH YOUR PATH
		end,
	},
}
