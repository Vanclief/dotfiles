require("neo-tree").setup({
    close_if_last_window = true
})

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

vim.keymap.set("n", "<C-w>", vim.cmd.NeoTreeRevealToggle)
