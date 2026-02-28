-- [[ MINI.BRACKETED: Sequential Movement ]]
-- Domain: Intra-Workspace Navigation
--
-- PHILOSOPHY: Implicit Structural Jumps
-- Provides native-feeling [ ] motions for buffers, quickfix, and diagnostics.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
	require('mini.deps').add('echasnovski/mini.nvim')
	require('mini.bracketed').setup()
end)

if not ok then
	utils.soft_notify('Mini.bracketed failed to load: ' .. err, vim.log.levels.ERROR)
end

return M
