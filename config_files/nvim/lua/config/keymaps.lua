-- maps are automatically loaded on the VeryLazy event
-- Default maps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/maps.lua
-- Add any additional maps here

-- Import the Util module
local Util = require("lazyvim.util")

-- Use safe_map_set for safe key mappings
local map = Util.safe_keymap_set

-- general
map("n", "<leader>nh", ":nohl<CR>", { desc = "Remove Highlights" })
-- window navigation
map("n", "<leader>wv", "<C-w>v", { desc = "split window vertically" })
map("n", "<leader>wh", "<C-w>s", { desc = "split window horizontally" })
map("n", "<leader>wx", ":close<CR>", { desc = "close window" })
map("n", "<leader>H", "<C-w>h", { desc = "move left" })
map("n", "<leader>L", "<C-w>l", { desc = "move right" })
map("n", "<leader>K", "<C-w>k", { desc = "move up" })
map("n", "<leader>J", "<C-w>j", { desc = "move down" })
map("n", "<C-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-l>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-h>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
-- tab navigation
map("n", "<leader>tn", ":tabnew<CR>", { desc = "new tab" })
map("n", "<leader>tx", ":tabclose<CR>", { desc = "close tab" })
map("n", "<leader>I", ":tabp<CR>", { desc = "left tab" })
map("n", "<leader>O", ":tabn<CR>", { desc = "right tab" })
-- pdf
map("n", "<leader>pdf", "<cmd>:!quick_pdf.sh % &<cr>", { desc = "Open current file as pdf in zathura" })
map("n", "<leader>pdc", ":w <cmd>:!quick_pdf.sh 0 &<cr>", { desc = "Close all zathura windows" })

-- deleting buffer keymaps
vim.keymap.del({ "n" }, "<leader>,")
vim.keymap.del({ "n" }, "<leader>`")

-- deleting tab keymaps
vim.keymap.del({ "n" }, "<leader><tab>l")
vim.keymap.del({ "n" }, "<leader><tab>f")
vim.keymap.del({ "n" }, "<leader><tab><tab>")
vim.keymap.del({ "n" }, "<leader><tab>[")
vim.keymap.del({ "n" }, "<leader><tab>]")
vim.keymap.del({ "n" }, "<leader><tab>d")

-- deleting window keymaps
vim.keymap.del({ "n" }, "<leader>ww")
vim.keymap.del({ "n" }, "<leader>wd")
vim.keymap.del({ "n" }, "<leader>w-")
vim.keymap.del({ "n" }, "<leader>w|")
vim.keymap.del({ "n" }, "<leader>-")
vim.keymap.del({ "n" }, "<leader>|")
vim.keymap.del({ "n" }, "<C-Up>")
vim.keymap.del({ "n" }, "<C-Down>")
vim.keymap.del({ "n" }, "<C-Right>")
vim.keymap.del({ "n" }, "<C-Left>")
