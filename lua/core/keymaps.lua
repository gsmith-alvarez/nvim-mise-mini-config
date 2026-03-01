-- [[ CORE KEYMAPS DOMAIN ]]
-- Domain: Global Navigation & Window Management
--
-- PHILOSOPHY: Home-Row Efficiency & Layout Control
-- These mappings are the "nervous system" of the editor. They prioritize
-- keeping the hands on the home row and provide surgical control over
-- Neovim's windowing system.

local M = {}

-- [[ 1. SEARCH & DISCOVERY ]]

-- Clear highlights on search: <leader><space>
-- When searching with '/', matches stay highlighted. This clears the glare
-- once you've found your target.
vim.keymap.set('n', '<leader><space>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- [[ 2. TERMINAL INTEROP ]]

-- Escape Terminal Mode: <Esc><Esc>
-- The native <C-\><C-n> is non-intuitive. This double-escape allows for
-- a faster pivot back to Normal mode within the built-in terminal.
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

-- [[ 3. WINDOW & SPLIT MANAGEMENT ]]
-- Using <leader>w as the prefix for all layout-destructive actions.

vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Window: [V]ertical Split' })
vim.keymap.set('n', '<leader>ws', '<cmd>split<CR>', { desc = 'Window: [S]plit Horizontal' })
vim.keymap.set('n', '<leader>wq', '<cmd>quit<CR>', { desc = 'Window: [Q]uit Current' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Window: [O]nly (Close others)' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Window: [=] Equalize Sizes' })
vim.keymap.set('n', '<leader>wx', '<C-w>x', { desc = 'Window: [X] Swap Next' })

-- [[ 4. NAVIGATION: Smart Multi-Pane Movement ]]
-- Maps CTRL+hjkl to direct window movement.
-- NOTE: If using the 'smart-splits' plugin, these will be overridden to
-- allow seamless jumping between Neovim and Zellij/Tmux panes.

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus Left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus Right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus Down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus Up' })

-- [[ 5. TEXT EDITING: Word Wrap Logic ]]
-- Remap for dealing with word wrap (move visually by default).
-- If a line wraps, 'j' and 'k' will move to the next visible line
-- rather than the next actual line number, unless a count is provided (e.g. 5j).
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ 6. SYMBOL REFACTORING ]]
-- Leverages IncRename (if installed) for real-time symbol renaming.

-- [[ 7. WORKFLOW: Keymap Cheatsheet ]]
-- Displays available keybindings using which-key.nvim.
vim.keymap.set('n', '<leader>?', function()
  require('which-key').show({ mode = 'n', prefix = '<leader>' })
end, { desc = 'Show Workflow Cheatsheet' })

-- [[ 8. OBSIDIAN NOTES (JIT) ]]
-- Proxies for Obsidian.nvim commands, leveraging JIT loading.
local utils = require('core.utils') -- Ensure utils is available

vim.keymap.set('n', '<leader>oq', function()
  local success, _ = pcall(vim.cmd, 'ObsidianQuickSwitch')
  if not success then
    utils.soft_notify('Not in an Obsidian workspace or plugin not loaded.', vim.log.levels.WARN)
  end
end, { desc = 'Obsidian: [Q]uick Switch (JIT)' })

vim.keymap.set('n', '<leader>os', function()
  local success, _ = pcall(vim.cmd, 'ObsidianSearch')
  if not success then
    utils.soft_notify('Not in an Obsidian workspace or plugin not loaded.', vim.log.levels.WARN)
  end
end, { desc = 'Obsidian: [S]earch Notes (JIT)' })

vim.keymap.set('n', '<leader>on', function()
  local success, _ = pcall(vim.cmd, 'ObsidianNew')
  if not success then
    utils.soft_notify('Not in an Obsidian workspace or plugin not loaded.', vim.log.levels.WARN)
  end
end, { desc = 'Obsidian: [N]ew Note (JIT)' })

-- [[ 9. AUDITING & BUILDING ]]
vim.keymap.set('n', '<leader>ut', '<cmd>ToolCheck<CR>', { desc = 'Tools: Check Toolchain (Mise)' })
vim.keymap.set('n', '<leader>xt', '<cmd>TyposCheck<CR>', { desc = 'Audit: Run Project [T]ypos' })
vim.keymap.set('n', '<leader>vw', '<cmd>Watchexec<CR>', { desc = 'View: [W]atchexec (Manual)' })

-- [[ 10. DIAGNOSTICS & LSP ]]
vim.keymap.set('n', '<leader>dL', '<cmd>ToggleVirtualText<CR>', { desc = 'Diagnostics: Toggle Virtual [L]ines' })
vim.keymap.set('n', '<leader>dU', '<cmd>ToggleUnderlines<CR>', { desc = 'Diagnostics: Toggle [U]nderlines' })
vim.keymap.set('n', '<leader>Dq', '<cmd>lua vim.diagnostic.setqflist()<CR>', { desc = 'Diagnostics: Open [q]uickfix' })
vim.keymap.set('n', '<leader>th', function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
end, { desc = 'LSP: Toggle Inlay [H]ints' })


-- [[ 11. BUFFER NAVIGATION ]]
vim.keymap.set('n', 'H', '<cmd>bprevious<CR>', { desc = 'Go to Previous Buffer' })
vim.keymap.set('n', 'L', '<cmd>bnext<CR>', { desc = 'Go to Next Buffer' })

-- [[ 12. PAIN-DRIVEN LEARNING (Disabled by Default) ]]
