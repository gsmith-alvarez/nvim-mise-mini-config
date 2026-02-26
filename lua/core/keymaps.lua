-- [[ Core Keymaps ]]
--  See `:help vim.keymap.set()`
--
-- This file defines global keybindings that are not specific to any plugin.
--
-- Unlike standard Kickstart which places everything in `init.lua`,
-- this modular configuration isolates core Neovim keymaps into this
-- dedicated file (`lua/core/keymaps.lua`), keeping things organized.

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
-- When you search with `/something`, Neovim highlights all matches.
-- Pressing Escape clears those highlights so your screen isn't so noisy.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- Opens a small window at the bottom of the screen with a list of all errors,
-- warnings, and info messages in your current file.
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- If you want to force yourself to use h,j,k,l to move instead of arrow keys,
-- uncomment the following lines. It's painful at first but you'll get used to it!
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- [[ Split Navigation Keymaps ]]
-- Keybinds to make split navigation easier.
-- Use CTRL+<hjkl> to switch between windows (splits) without needing to
-- press <C-w> before every movement.
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Key mapping to stop softwrapping issues ]]
-- Remap for dealing with word wrap (move visually by default)
-- Normally, pressing 'j' or 'k' moves to the next actual line in the file.
-- If a line is so long that it wraps across multiple lines on your screen,
-- pressing 'j' skips the wrapped lines!
-- This mapping changes 'j' and 'k' so they treat wrapped lines as normal lines
-- unless you're jumping a specific number of lines (e.g., 5j).
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Pain-Driven Learning ]]
-- These mappings disable the arrow keys to force you to stay on the home row 
-- and use `h`, `j`, `k`, and `l`. This is the most efficient way to navigate
-- and is the cornerstone of advanced Neovim usage.

local arrow_warning = function()
  vim.notify("Use h, j, k, l! Arrow keys are disabled.", vim.log.levels.WARN)
end

-- Disable arrow keys in Normal mode
vim.keymap.set('n', '<Up>', arrow_warning)
vim.keymap.set('n', '<Down>', arrow_warning)
vim.keymap.set('n', '<Left>', arrow_warning)
vim.keymap.set('n', '<Right>', arrow_warning)

-- Disable arrow keys in Visual mode
vim.keymap.set('v', '<Up>', arrow_warning)
vim.keymap.set('v', '<Down>', arrow_warning)
vim.keymap.set('v', '<Left>', arrow_warning)
vim.keymap.set('v', '<Right>', arrow_warning)

-- [[ Workflow Cheatsheet Float ]]
vim.keymap.set('n', '<leader>?', function()
  local path = vim.fn.stdpath('config') .. '/nvim_cheatsheet.md'
  if vim.fn.filereadable(path) == 0 then
    vim.notify('Cheatsheet not found at ' .. path, vim.log.levels.ERROR)
    return
  end

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded'
  })

  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].modifiable = false

  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, desc = 'Close Cheatsheet' })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, desc = 'Close Cheatsheet' })
end, { desc = 'Show Workflow Cheatsheet' })
