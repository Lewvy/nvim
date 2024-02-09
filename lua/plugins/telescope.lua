return {
	{

		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		dependencies = { 'nvim-lua/plenary.nvim' },

		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set('n', '<leader>sf', builtin.find_files, {})
			vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})
			vim.keymap.set('n', '<leader>tb', builtin.buffers, {})
			vim.keymap.set('n', '<leader>th', builtin.help_tags, {})
		end

	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown {}

				}
			}
		})
		require("telescope").load_extension("ui-select")
	end
},
{
	"debugloop/telescope-undo.nvim",
	dependencies = { -- note how they're inverted to above example
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
},
keys = {
	{ -- lazy style key map
	"<leader>u",
	"<cmd>Telescope undo<cr>",
	desc = "undo history",
},
  },
  opts = {
	  -- don't use `defaults = { }` here, do this in the main telescope spec
	  extensions = {
		  undo = {
			  -- telescope-undo.nvim config, see below
		  },
		  -- no other extensions here, they can have their own spec too
	  },
  },
  config = function(_, opts)
	  -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
	  -- configs for us. We won't use data, as everything is in it's own namespace (telescope
	  -- defaults, as well as each extension).
	  require("telescope").setup(opts)
	  require("telescope").load_extension("undo")
  end,
},
}
