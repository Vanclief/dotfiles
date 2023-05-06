-- Plugin to show function signatures when typing
local cfg = {
    hint_prefix = "P "
}

require "lsp_signature".setup(cfg)
