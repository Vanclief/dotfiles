return {
  "nvim-telescope/telescope.nvim",
  keys = {
        -- add a keymap to browse plugin files
        -- stylua: ignore
        {
            "<leader><leader>",
            function() end,

        },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Find Files (Grep)",
    },
  },
}
