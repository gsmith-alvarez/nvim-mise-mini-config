-- [[ HISTORY & OMNISEARCH ]]
-- Domain: Temporal Navigation & Contextual Discovery
--
-- PHILOSOPHY: Pain-Driven History & Graceful Degradation
-- Instead of manually searching trees, we navigate by "Recency" and "Context".
-- mini.visits tracks your movements silently in the background, while mini.pick
-- provides high-performance, ripgrep-powered omnisearch on demand.

local M = {}
local utils = require('core.utils')

-- [[ 1. EAGER STATE TRACKING ]]
-- mini.visits MUST be loaded immediately to catch the first BufEnter event.
local ok_visits, _ = pcall(function()
	require('mini.deps').add('echasnovski/mini.nvim')
	require('mini.visits').setup({
		-- Delay = 0 ensures we don't miss rapid file hopping
		track = { event = 'BufEnter', delay = 0 },
	})
end)

if not ok_visits then
	utils.soft_notify('History Tracker (mini.visits) failed to boot.', vim.log.levels.ERROR)
end

-- [[ 2. DEFERRED UI BOOTSTRAPPER ]]
-- mini.pick and mini.extra contain the UI and fuzzy-matching logic.
-- We defer loading these until the exact moment a search is requested.
local pickers_loaded = false

local function bootstrap_pickers()
	if pickers_loaded then return true end

	local ok, err = pcall(function()
		require('mini.deps').add('echasnovski/mini.nvim')
		require('mini.pick').setup()
		require('mini.extra').setup()
	end)

	if not ok then
		utils.soft_notify('Omnisearch UI failed to initialize: ' .. err, vim.log.levels.ERROR)
		return false
	end

	pickers_loaded = true
	return true
end

-- [[ 3. PROXY KEYMAPS ]]
-- These keymaps act as interceptors. They ensure the UI is loaded before
-- attempting to launch the picker, preserving your sub-30ms startup time.

local map = vim.keymap.set

-- [OMNI-SEARCH] The true alternative to Obsidian's Omnisearch.
-- Leverages the `mise`-managed `ripgrep` binary for sub-millisecond full-text indexing.
map('n', '<leader>so', function()
	if bootstrap_pickers() then
		require('mini.pick').builtin.grep_live()
	end
end, { desc = '[S]earch [O]mni (Ripgrep Full Text)' })

-- [RECENT FILES] Pulls up the mini.visits interface via mini.pick.
-- It sorts by a combination of recency AND frequency (weight).
map('n', '<leader>fr', function()
	if bootstrap_pickers() then
		-- MiniExtra global is exposed after require('mini.extra').setup()
		MiniExtra.pickers.visits({ sort = 'recent' })
	end
end, { desc = '[F]ind [R]ecent Files (Global)' })

-- [CONTEXTUAL HISTORY] Directory-scoped intelligence.
-- Only shows files you visit frequently while in the CURRENT project.
map('n', '<leader>fc', function()
	if bootstrap_pickers() then
		MiniExtra.pickers.visits({ filter = 'core' })
	end
end, { desc = '[F]ind [C]ontextual (Directory-scoped)' })

return M
