--- [[ Mini.nvim: Diff ]]
--- Displays git diffs in the sign column.
require('mini.diff').setup({ view = { style = 'sign', signs = { add = '+', change = '~', delete = '_' } } })
vim.keymap.set('n', '<leader>gD', function() require('mini.diff').toggle_overlay(0) end, { desc = 'Toggle [G]it [D]iff overlay' })