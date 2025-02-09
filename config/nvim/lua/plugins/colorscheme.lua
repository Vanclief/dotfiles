return {
  -- add onedark
  {
    "navarasu/onedark.nvim",
    event = "User ColorSchemeLoad",
    opts = {
      style = "deep",
    },
  },
  -- Configure LazyVim to load onedark
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
