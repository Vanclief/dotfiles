-- lua/plugins/gotmpl.lua
return {
  {
    -- Extend nvim-treesitter to include Go templates
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "go", "html", "gotmpl" })
    end,
  },
  {
    -- Set filetype for *.gohtml to 'gotmpl' so highlighting kicks in
    "folke/which-key.nvim",
    opts = {},
    config = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.gohtml",
        callback = function()
          vim.bo.filetype = "gotmpl"
        end,
      })
    end,
  },
}
