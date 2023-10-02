vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- general keymaps
keymap.set("n", "<leader>nh", ":nohl<CR>") -- removing highlighting
keymap.set("n", "x", '"_x') -- x does not move character into clipboard 

-- window navigation
keymap.set("n", "<leader>wv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>wh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>h",       "<C-w>h") -- move left
keymap.set("n", "<leader>l",       "<C-w>l") -- move right
keymap.set("n", "<leader>k",       "<C-w>k") -- move up
keymap.set("n", "<leader>j",       "<C-w>j") -- move down
keymap.set("n", "<leader>xw", ":close<CR>") -- close current split window

-- tab navigation
keymap.set("n", "<leader>t", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>i", ":tabp<CR>") -- left tab
keymap.set("n", "<leader>o", ":tabn<CR>") -- right tab
keymap.set("n", "<leader>xt", ":tabclose<CR>") -- close current tab

-- plugin keymaps
-- keymap.set("n", "<leader>m", ":MaximizerToggle<CR>")

-- nvim_tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<Cr>")

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fs", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>ft", "<cmd>Telescope help_tags<cr>") -- list available help tags
