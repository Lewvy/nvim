return {
	"nvimtools/none-ls.nvim",
	dependencies = { "mason.nvim" },
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {},
		})

		vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
		-- You may also want to set up an autocmd for formatting on save:
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true }),
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end,
}
