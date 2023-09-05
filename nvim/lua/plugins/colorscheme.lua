return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  -- add onedark
  { "navarasu/onedark.nvim", event = "User ColorSchemeLoad" },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
