
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pp", vim.cmd.Ex)

---------------
-- Vanclief --
---------------

-- Escape with jj 
vim.keymap.set("i", "jj", "<Esc>")

-- Easier navigation tmux style
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

---------------
-- Primeagen --
---------------

-- Be able to move a visual block with J/K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- J doesn't move after usin J
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle while jumping with C-d and C-u
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle wihile jumping
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Awesome remap for pasting without losing buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Awesome remaps for copy pasting into system
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Awesome remap for deleting without keeping lines
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Never use Q
vim.keymap.set("n", "Q", "<nop>")

-- Tmux stuff need to dig deeper later
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Stuff that I need to figure out later
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Space S allows me to replace the word I was using
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Change chmod to executable for the file   
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
