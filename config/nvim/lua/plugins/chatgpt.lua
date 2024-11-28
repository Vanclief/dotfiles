return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      chat = {
        keymaps = {
          close = { "jj", "<Esc>" },
          yank_last = "<C-y>",
          scroll_up = "<C-u>",
          scroll_down = "<C-d>",
          toggle_settings = "<C-o>",
          new_session = "<C-n>",
          cycle_windows = "<Tab>",
        },
      },
      popup_input = {
        submit = "<C-s>",
      },
      openai_params = {
        model = "gpt-4",
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>cc", "<cmd>ChatGPT<CR>", desc = "Open ChatGPT" },
  },
}
