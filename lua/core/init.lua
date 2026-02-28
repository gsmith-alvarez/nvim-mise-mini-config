-- [[ CORE SYSTEM ORCHESTRATOR ]]
-- Architecture: Fault-Tolerant System Boot
-- This file serves as the central dispatcher for Neovim's foundational settings.
--
-- STRATEGY: Sandboxed Requirements
-- We treat each core module (options, keymaps, etc.) as an isolated unit.
-- If you are mid-refactor in 'keymaps.lua' and leave a syntax error,
-- Neovim will still load your 'options.lua', ensuring your theme and
-- basic editor behavior remain intact while you debug.

local M = {}

local utils = require('core.utils')

-- Define the foundational modules to be loaded.
-- These represent the "Vital Organs" of your configuration.
local modules = {
    -- 1. The Installer (Infrastructure)
    -- Must be first so _G.MiniDeps exists for everyone else.
    'core.deps', 

    -- 2. The Libraries (Shared Dependencies)
    -- Injects Plenary.nvim so your logic layers can use async/path functions.
    'core.libs', 

    -- 3. The Rules (Standard Editor Behavior)
    -- Global settings that don't depend on plugins.
    'core.options', 

    -- 4. The Interaction (Non-Plugin Mappings)
    -- Basic leader and movement keys.
    'core.keymaps', 

    -- 5. The Logic (Automation Layers)
    -- These often use autocmds that might trigger plugin logic.
    'core.format', 
    'core.lint', 
}

for _, module in ipairs(modules) do
	-- EXECUTION STRATEGY: The Protected Call (pcall)
	-- 1. 'ok': Boolean indicating success.
	-- 2. 'err': The specific Lua error if the module failed to load.
	local ok, err = pcall(require, module)

	if not ok then
		-- ERROR ROUTING:
		-- We use our custom soft_notify to pipe the error to our persistent
		-- log (~/.local/state/nvim/config_diagnostics.log) and the UI.
		utils.soft_notify(string.format("CORE FAILURE: Failed to load %s\nError: %s", module, err),
			vim.log.levels.ERROR)
	end
end

-- [[ SELF-CORRECTING HOT RELOAD ]]
-- This autocmd ensures that saving any core file re-triggers its logic
-- immediately without requiring a full Neovim restart.
vim.api.nvim_create_autocmd('BufWritePost', {
	pattern = '*/lua/core/*.lua',
	callback = function(event)
		-- Exclude this init.lua from self-reloading to avoid recursion loops
		if event.file:match('init%.lua$') then return end

		local module_name = event.file:match('lua/(core/.*)%.lua$'):gsub('/', '.')

		if module_name then
			package.loaded[module_name] = nil -- Clear the Lua module cache
			local ok, err = pcall(require, module_name)
			if ok then
				vim.notify('Core Reloaded: ' .. module_name, vim.log.levels.INFO)
			else
				utils.soft_notify('Core Reload Failed: ' .. err, vim.log.levels.ERROR)
			end
		end
	end,
	desc = 'Auto-reload core system modules on save',
})

return M
