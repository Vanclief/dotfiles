return {
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}

      if type(opts.adapters) == "table" then
        local adapter_opts = opts.adapters["neotest-golang"]
        if adapter_opts == nil or adapter_opts == false then
          adapter_opts = {}
        end

        if type(adapter_opts) == "table" then
          adapter_opts = vim.tbl_deep_extend("force", adapter_opts, {
            testify_enabled = true,
          })
        end

        opts.adapters["neotest-golang"] = adapter_opts
      end
    end,
  },
}
