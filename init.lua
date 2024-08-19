require("custom.remap")
require("custom.yank")
require("custom.vim_config")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_view_method = "mupdf"
local plugins = {}
local opts = {}
require("lazy").setup("plugins")

vim.cmd("set clipboard+=unnamedplus")

require("catppuccin").setup({
	transparent_background = true,
})

vim.cmd.colorscheme("catppuccin")
