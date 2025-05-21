vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core Neovim settings
vim.opt.clipboard = "unnamedplus"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_view_method = "mupdf"

-- Load custom configurations
require("custom.remap")
require("custom.yank")
require("custom.vim_config")

-- Initialize Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/
require("lazy").setup("plugins")

-- Post-plugin configuration
vim.opt.timeoutlen = 500 -- Critical for which-key
require("catppuccin").setup({ transparent_background = true })
vim.cmd.colorscheme("catppuccin")
