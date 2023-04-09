require("chatgpt").setup({
    keymaps = {
        submit = "<C-s>"
    }
})

vim.keymap.set("n", "<leader>c", vim.cmd.ChatGPT)
