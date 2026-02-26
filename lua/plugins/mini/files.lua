--- [[ Mini.nvim: Files ]]
--- File explorer, replaces oil.nvim.
require('mini.files').setup()

-- Keymaps for mini.files
vim.keymap.set('n', '<leader>e', function() require('mini.files').open(vim.fn.getcwd()) end, { desc = 'Open Mini.files in cwd' })
vim.keymap.set('n', '-', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, { desc = 'Open Mini.files in current dir' })