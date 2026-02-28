-- [[ MINI.FILES: Structural Explorer ]]
-- Domain: Inter-File Navigation
--
-- PHILOSOPHY: JIT Explorer Bootstrapping
-- A file explorer is useless until invoked. We use a proxy loader to
-- defer the setup of `mini.files` until the exact moment a keymap is pressed.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_minifiles()
	if loaded then return true end

	local ok, err = pcall(function()
		require('mini.deps').add('echasnovski/mini.nvim')
		require('mini.files').setup({
			-- We enforce an explicit split behavior to prevent layout corruption
			windows = { preview = true, width_focus = 30 },
		})
	end)

	if not ok then
		utils.soft_notify('Mini.files failed to initialize: ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded = true
	return true
end

-- [[ PROXY KEYMAPS ]]
local map = vim.keymap.set

map('n', '<leader>fe', function()
	if bootstrap_minifiles() then
		require('mini.files').open(vim.fn.getcwd())
	end
end, { desc = 'Open [F]ile [E]xplorer (Root)' })

map('n', '-', function()
	if bootstrap_minifiles() then
		-- Opens the explorer precisely at the current buffer's directory
		require('mini.files').open(vim.api.nvim_buf_get_name(0))
	end
end, { desc = 'Open Explorer (Current Dir)' })

return M
