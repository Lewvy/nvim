vim.g.mapleader = " "
vim.keymap.set("n", "<leader>er", vim.diagnostic.open_float)
vim.keymap.set("n", "<C-Y>", [[mavG$y`a]])
vim.keymap.set("n", "<leader>ay", [[mavgg0y`a]])
vim.keymap.set("n", "<leader>cl", vim.cmd.noh)
vim.keymap.set("n", "<leader>ww", vim.cmd.w)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>q", vim.cmd.q)
vim.keymap.set("n", "<C-L>", "<cmd> TmuxNavigateRight<CR>")
vim.keymap.set("n", "<C-H>", "<cmd> TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<C-J>", "<cmd> TmuxNavigateDown<CR>")
vim.keymap.set("n", "<C-K>", "<cmd> TmuxNavigateUp<CR>")
vim.keymap.set("n", "<leader>wq", vim.cmd.wq)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("x", "<leader>dp", [["_dP]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "<leader>pp", [["+p]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Goto References" })
vim.api.nvim_set_keymap("i", "<C-e>", "if err != nil {\n\treturn err\n}", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>return err<CR>}<Esc>", { noremap = true, silent = true })
