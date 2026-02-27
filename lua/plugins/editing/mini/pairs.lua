--- [[ Mini.nvim: Pairs ]]
--- Autocompletion for pairs of characters like brackets and quotes.
require('mini.pairs').setup({
	mappings = {
		-- Disables the plugin's control over the Enter key
		['<CR>'] = false,
	},
})
