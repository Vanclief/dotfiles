local function set_onedark_deep()
  local onedark = require("onedark")

  vim.o.background = "dark"
  onedark.set_options("style", "deep")
  onedark.load()
end

local function set_github_light()
  vim.o.background = "light"
  vim.cmd.colorscheme("github_light_default")
end

local function toggle_theme()
  if vim.g.colors_name == "github_light_default" then
    set_onedark_deep()
  else
    set_github_light()
  end
end

return {
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "deep",
    },
    config = function(_, opts)
      local onedark = require("onedark")

      onedark.setup(opts)
      onedark.toggle = toggle_theme

      vim.api.nvim_create_user_command("ThemeDark", set_onedark_deep, { desc = "Use onedark deep" })
      vim.api.nvim_create_user_command("ThemeLight", set_github_light, { desc = "Use GitHub light default" })
      vim.api.nvim_create_user_command("ThemeToggle", toggle_theme, { desc = "Toggle dark/light theme" })
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = true,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        set_onedark_deep()
      end,
    },
  },
}
