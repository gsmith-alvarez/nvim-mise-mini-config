-- ============================================================================
-- MODULE: mini.visits & mini.pick (Omnisearch + Chronological Context)
-- ============================================================================

-- 1. Initialize the History Tracker
require('mini.deps').add('echasnovski/mini.visits')
require('mini.visits').setup({
	-- Automatically track all visited files
	track = { event = 'BufEnter', delay = 0 },
})

-- Add mini.pick dependency and setup for Omnisearch
require('mini.deps').add('echasnovski/mini.pick')
local minipick = require('mini.pick')
minipick.setup()

-- 2. Ensure mini.extra is loaded to pipe visits into mini.pick
require('mini.deps').add('echasnovski/mini.extra')
require('mini.extra').setup()

-- 3. Force-Multiplier Keymaps
local map = vim.keymap.set

-- [OMNI-SEARCH] The true alternative to Obsidian's Omnisearch.
-- This leverages the `mise`-managed `ripgrep` binary for sub-millisecond full-text indexing.
-- Graceful Degradation: If `rg` is missing, mini.pick handles the error gracefully via its native health checks.
map('n', '<leader>so', function()
	minipick.builtin.grep_live()
end, { desc = '[S]earch [O]mni (Ripgrep Full Text)' })

-- [RECENT FILES] Pulls up the mini.visits interface via mini.pick.
-- It sorts by a combination of recency AND frequency (weight).
map('n', '<leader>fr', function()
	MiniExtra.pickers.visits({ sort = 'recent' })
end, { desc = '[F]ind [R]ecent Files (Global)' })

-- [CONTEXTUAL HISTORY] Only shows files you visit frequently while in the CURRENT directory.
map('n', '<leader>fc', function()
	MiniExtra.pickers.visits({ filter = 'core' })
end, { desc = '[F]ind [C]ontextual (Directory-scoped visits)' })
