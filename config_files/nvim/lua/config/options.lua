-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

vim.g.maplocalleader = ","

opt.swapfile = false

-- enables spelling for german and english (asks me to install de on its own)
opt.spelllang = { "de", "en" }
opt.spell = false

opt.tabstop = 4

-- enable clipboard
vim.o.clipboard = "unnamedplus"
