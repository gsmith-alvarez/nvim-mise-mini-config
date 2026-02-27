--- [[ Mini.nvim: Files ]]
--- File explorer, replaces oil.nvim.
require('mini.files').setup()

-- Keymaps for mini.files
-- Keymaps for mini.files
vim.keymap.set('n', '<leader>fe', function() require('mini.files').open(vim.fn.getcwd()) end, { desc = 'Open [F]ile [E]xplorer (Mini.files)' })
vim.keymap.set('n', '-', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, { desc = 'Open Mini.files in current dir' })