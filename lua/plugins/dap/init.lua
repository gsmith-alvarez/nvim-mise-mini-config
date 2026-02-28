-- [[ LSP/DAP DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/dap/init.lua
-- Domain: Intelligence, Diagnostics, & Execution
--
-- PHILOSOPHY: The "Second Brain" Principle
-- The editor should not just show text; it should understand 
-- intent and state. These modules provide the deep-tissue 
-- inspection required for professional hardware/systems engineering.

local M = {}
local utils = require('core.utils')

-- [[ THE DOMAIN MODULES ]]
-- We list only the siblings in this specific directory.
-- Logic: We use the dot-notation path relative to the 'plugins' root.
local modules = {
  'dap.debug',                   -- Core DAP + PlatformIO Logic
  'dap.nvim-dap-virtual-text',   -- Inline Variable State
  'dap.persistent-breakpoint',   -- Session Persistence for Traps
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  
  -- [[ THE CIRCUIT BREAKER ]]
  -- Wrapping each module in a pcall ensures that a failure in 
  -- the Debugger doesn't crash your Text Editor.
  local ok, err = pcall(require, module_path)

  if not ok then
    -- ERROR CORRECTION: Log the specific failure to our diagnostic audit trail
    -- while notifying the UI so the user isn't left in the dark.
    utils.soft_notify(string.format("DAP DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

-- THE CONTRACT: Return the module to satisfy the Global Plugins Orchestrator
return M
