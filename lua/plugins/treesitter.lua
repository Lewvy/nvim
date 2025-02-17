return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"nvim-treesitter/nvim-treesitter-textobjects", -- Adds text objects like function and class selections
	},
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			-- List the languages you want to support.
			ensure_installed = { "lua", "javascript", "c", "cpp", "go", "python", "bash" },
			auto_install = true,

			-- Enable syntax highlighting.
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},

			-- Enable Treesitter-based indentation.
			indent = {
				enable = true,
			},

			-- Incremental selection configuration.
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn", -- Start selection with `gnn`
					node_incremental = "grn", -- Expand selection to next node with `grn`
					scope_incremental = "grc", -- Expand selection to the current scope with `grc`
					node_decremental = "grm", -- Shrink selection with `grm`
				},
			},

			-- Textobjects configuration.
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to text object
					keymaps = {
						["af"] = "@function.outer", -- Select around a function (includes signature and body)
						["if"] = "@function.inner", -- Select inside a function (body only)
						["ac"] = "@class.outer", -- Select around a class
						["ic"] = "@class.inner", -- Select inside a class
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = "@function.outer", -- Jump to next function start
						["]c"] = "@class.outer", -- Jump to next class start
					},
					goto_next_end = {
						["]F"] = "@function.outer", -- Jump to next function end
						["]C"] = "@class.outer", -- Jump to next class end
					},
					goto_previous_start = {
						["[f"] = "@function.outer", -- Jump to previous function start
						["[c"] = "@class.outer", -- Jump to previous class start
					},
					goto_previous_end = {
						["[F"] = "@function.outer", -- Jump to previous function end
						["[C"] = "@class.outer", -- Jump to previous class end
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>a"] = "@parameter.inner", -- Swap parameter with next one
					},
					swap_previous = {
						["<leader>A"] = "@parameter.inner", -- Swap parameter with previous one
					},
				},
			},
		})
	end,
}
