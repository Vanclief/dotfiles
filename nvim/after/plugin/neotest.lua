-- Test framework
local neotest = require("neotest")

neotest.setup({
    -- your neotest config here
    adapters = {
        require("neotest-go"),
    },
})

-- Output pannel
vim.keymap.set("n", "<leader>to", neotest.output_panel.toggle)

vim.keymap.set("n", "<leader>ts", neotest.summary.toggle)
-- Run nearest test
vim.keymap.set("n", "<leader>tt", neotest.run.run)
-- Run current file
vim.keymap.set('n', '<leader>tf', function()
    neotest.run.run(vim.fn.expand("%"));
end)

local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
    virtual_text = {
        format = function(diagnostic)
            local message =
                diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
        end,
    },
}, neotest_ns)
