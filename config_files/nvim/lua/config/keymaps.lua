-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Import the Util module
local Util = require("lazyvim.util")

-- Use safe_keymap_set for safe key mappings
local map = Util.safe_keymap_set

map("n", "<leader>pdf", "<cmd>:!quick_pdf.sh % &<cr>", { desc = "Open current file as pdf in zathura" })
map("n", "<leader>pdc", ":w <cmd>:!quick_pdf.sh 0 &<cr>", { desc = "Close all zathura windows" })
