local uv = vim.uv or vim.loop
local path_sep = package.config:sub(1, 1)
local python_cache = {}
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local trim = vim.trim or function(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function join_paths(...)
  local result = {}
  local count = select("#", ...)
  for index = 1, count do
    local part = select(index, ...)
    if part and part ~= "" then
      table.insert(result, part)
    end
  end
  return table.concat(result, path_sep)
end

local function python_from_venv(venv)
  if not venv or venv == "" then
    return nil
  end
  if uv and uv.fs_stat and not uv.fs_stat(venv) then
    return nil
  end
  local scripts_dir = is_windows and "Scripts" or "bin"
  local binaries = is_windows and { "python.exe", "python" } or { "python", "python3" }
  for _, binary in ipairs(binaries) do
    local candidate = join_paths(venv, scripts_dir, binary)
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
end

local function detect_python(workspace)
  workspace = workspace or (uv and uv.cwd and uv.cwd()) or vim.fn.getcwd()
  if python_cache[workspace] then
    return python_cache[workspace]
  end

  local function cache_and_return(path)
    if path and path ~= "" then
      python_cache[workspace] = path
      return path
    end
  end

  if cache_and_return(python_from_venv(vim.env.VIRTUAL_ENV)) then
    return python_cache[workspace]
  end

  if vim.fn.executable("uv") == 1 then
    local uv_output = vim.fn.system({ "uv", "python", "find", "--project", workspace })
    if vim.v.shell_error == 0 then
      local python_path = trim(uv_output)
      if vim.fn.executable(python_path) == 1 then
        return cache_and_return(python_path)
      end
    end
  end

  for _, folder in ipairs({ ".venv", "venv" }) do
    if cache_and_return(python_from_venv(join_paths(workspace, folder))) then
      return python_cache[workspace]
    end
  end

  local python = vim.fn.exepath("python3")
  if python == "" then
    python = vim.fn.exepath("python")
  end
  if python == "" then
    if vim.fn.executable("python3") == 1 then
      python = "python3"
    elseif vim.fn.executable("python") == 1 then
      python = "python"
    end
  end
  return cache_and_return(python) or "python3"
end

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason.nvim",
  },
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<leader>cR", "<cmd>LspRestart<CR>", desc = "Restart LSP" }
  end,
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
    },
    autostart = true,
    servers = {
      -- TypeScript configuration
      vtsls = {
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git")(fname)
            or vim.loop.cwd()
        end,
        settings = {
          typescript = {
            tsserver = {
              experimental = {
                enableProjectDiagnostics = true, -- Required for workplace diagnostics
              },
            },
            diagnostics = {
              enable = true,
              enableProject = true,
            },
          },
        },
      },

      -- Go configuration
      gopls = {
        keys = {
          { "<leader>td", "<cmd>lua require('dap-go').debug_test()<CR>", desc = "Debug Nearest (Go)" },
        },
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = false,
              compositeLiteralFields = false,
              compositeLiteralTypes = false,
              constantValues = true,
              functionTypeParameters = false,
              parameterNames = false,
              rangeVariableTypes = false,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
      },

      -- Python configuration
      pyright = {
        before_init = function(_, config)
          local python = detect_python(config.root_dir)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = python
        end,
      },
      ruff_lsp = {}, -- Using default configuration

      -- JSON configuration
      jsonls = {
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
        end,
        settings = {
          json = {
            format = { enable = true },
            validate = { enable = true },
          },
        },
      },

      -- YAML configuration
      yamlls = {
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
        on_new_config = function(new_config)
          new_config.settings.yaml.schemas = new_config.settings.yaml.schemas or {}
          vim.list_extend(new_config.settings.yaml.schemas, require("schemastore").yaml.schemas())
        end,
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = { enable = true },
            validate = true,
            schemaStore = {
              enable = false,
              url = "",
            },
          },
        },
      },
    },
  },
}
