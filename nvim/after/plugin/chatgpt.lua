local chatgpt = require("chatgpt")

chatgpt.setup({
    chat = {
        keymaps = {
            close = { "<C-c>" },
            yank_last = "<C-y>",
            yank_last_code = "<C-k>",
            scroll_up = "<C-k>",
            scroll_down = "<C-j>",
            toggle_settings = "<C-o>",
            new_session = "<C-n>",
            cycle_windows = "<Tab>",
            select_session = "<Space>",
            rename_session = "r",
            delete_session = "d",
        },
        popup_input = {
            submit = "<CR>"
        }
    },
    openai_params = {
        model = "gpt-4",
    },
})

vim.keymap.set("n", "<C-g>", vim.cmd.ChatGPT)

-- Interesting keybindings
-- local wk = require("which-key")
-- Allow to pass text
-- wk.register({
-- p = {
-- name = "ChatGPT",
-- e = {
-- function()
-- chatgpt.edit_with_instructions()
-- end,
-- "Edit with instructions",
-- },
-- },
-- }, {
-- prefix = "<leader>",
-- mode = "v",
-- })
