-- spectre is a search & replace tool
local spectre = require('spectre')

vim.keymap.set("n", "<leader>so", spectre.open)
vim.keymap.set('n', '<leader>sw', function()
	spectre.open_visual({ select_word=true});
end)
vim.keymap.set("v", "<leader>sw", spectre.open_visual)
vim.keymap.set('n', '<leader>sf', function()
	spectre.open_file_search({ select_word=true});
end)

spectre.setup()
