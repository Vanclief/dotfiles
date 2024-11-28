return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      name = {
        trailing_slash = false,
        use_git_status_colors = false,
        highlight = "NeoTreeFileName",
      },
      git_status = {
        symbols = {
          -- Change type
          added = "+", -- or "✚", but this is redundant info if you use git_status_colors on the name
          modified = "±", -- or "", but this is redundant info if you use git_status_colors on the name
          deleted = "x", -- this can only be used in the git_status source
          renamed = "r", -- this can only be used in the git_status source
          -- Status type
          untracked = "", -- or 
          ignored = "", -- or 
          unstaged = "", -- or 
          staged = "", -- or 
          conflict = "",
        },
      },
    },
  },
}
