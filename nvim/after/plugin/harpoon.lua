local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<C-f>m", mark.add_file)
vim.keymap.set("n", "<C-f>n", ui.nav_next)
vim.keymap.set("n", "<C-f>p", ui.nav_prev)
vim.keymap.set("n", "<C-f>o", ui.toggle_quick_menu)
