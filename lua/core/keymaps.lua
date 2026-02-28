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
vim.keymap.set('n', '<leader>rn', ':IncRename ', { desc = '[R]e[n]ame Symbol' })

-- [[ 7. WORKFLOW: Floating Cheatsheet ]]
-- Renders a local markdown file in a floating window for quick reference.
-- STRATEGY: Defensive Floating UI
vim.keymap.set('n', '<leader>?', function()
  local path = vim.fn.stdpath('config') .. '/nvim_cheatsheet.md'
  if vim.fn.filereadable(path) == 0 then
    vim.notify('Cheatsheet missing at: ' .. path, vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true) -- Scratch buffer
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  -- Prevent window from being too small on narrow terminals
  if width < 20 or height < 5 then return end

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded'
  })

  -- Inject content and set buffer-local behavior
  vim.fn.setline(1, vim.fn.readfile(path))
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].modifiable = false

  -- Local exit maps for the float
  local opts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set('n', 'q', '<cmd>close<CR>', opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', opts)
end, { desc = 'Show Workflow Cheatsheet' })

-- [[ 8. PAIN-DRIVEN LEARNING (Disabled by Default) ]]
-- Uncomment to force home-row discipline.
local arrow_warning = function()
  vim.notify("DISCIPLINE: Use h, j, k, l. Arrows are for the weak.", vim.log.levels.WARN)
end
-- vim.keymap.set({'n', 'v'}, '<Up>', arrow_warning)
-- vim.keymap.set({'n', 'v'}, '<Down>', arrow_warning)

return M
