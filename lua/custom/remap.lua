vim.g.mapleader = " "
vim.keymap.set("n",'<leader>cl',vim.cmd.noh)
vim.keymap.set("n","<leader>ww",vim.cmd.w)
vim.keymap.set("n","<leader>pv",vim.cmd.Ex)
vim.keymap.set("n","<leader>q",vim.cmd.q)
vim.keymap.set("n", "<leader>wq",vim.cmd.wq)
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("x", "<leader>dp", [["_dP]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", '<leader>pp', [["+p]])
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])
vim.keymap.set("n", "<leader>ps", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
