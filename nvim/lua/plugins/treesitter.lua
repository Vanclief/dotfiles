return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      "go",
      "gomod",
      "gowork",
      "gosum",
      "typescript",
      "ron",
      "rust",
      "toml",
      "tsx",
      "ninja",
      "python",
      "rst",
      "json",
      "json5",
      "jsonc",
      "yaml",
      "c",
      "cpp",
    })
  end,
}
