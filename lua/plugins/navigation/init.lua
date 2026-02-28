-- [[ NAVIGATION ORCHESTRATOR ]]
-- Location: lua/plugins/navigation/init.lua
-- Domain: Physical Movement & Workspace Flow
--
-- PHILOSOPHY: Isolated Locomotion
-- This file is a "Gate." It only manages the loading of movement-based 
-- tools. It assumes Phase 1 (Core) is already alive.

local M = {}
-- We require utils here locally so we can report if a specific sub-plugin fails.
local utils = require('core.utils')

-- Define ONLY the scripts in THIS directory.
-- Logic: The root init.lua calls 'plugins.navigation', which triggers this loop.
local modules = {
  'navigation.harpoon',        -- File hooking
  'navigation.mini-files',     -- Inter-File Navigation
  'navigation.mini-bracketed', -- Intra-Workspace Navigation
  'navigation.smart-splits',   -- Zellij movement
  'navigation.tabout',         -- Bracket escape hatch
  'navigation.yazi',        -- Move this to workflow/ if preferred, or keep here.
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    -- Capture the failure specifically for this sub-domain.
    utils.soft_notify(string.format("NAVIGATION DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

return M