return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (branch)" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
  },
  opts = {},
}
