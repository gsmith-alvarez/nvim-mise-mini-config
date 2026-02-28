-- [[ COMMANDS ORCHESTRATOR ]]
-- Architecture: Fault-Tolerant Module Loading
-- This file serves as the central dispatcher for all custom user commands.
--
-- STRATEGY: Sandboxed Requirements
-- Neovim's default 'require' is blocking and fragile. If 'building.lua' has
-- a syntax error, a standard require would halt the entire 'init.lua' execution,
-- leaving you with a broken editor. We wrap each module in a protected call (pcall)
-- to ensure that one failure does not cascade into a total system crash.

local M = {}

local utils = require('core.utils')

-- Define the domain-specific modules to be loaded.
-- This keeps the 'init.lua' clean and the configuration modular.
local modules = {
  'commands.auditing',    -- ToolCheck, Redir, Typos
  'commands.building',    -- Zellij & Watchexec processing, single-run compiling
  'commands.diagnostics', -- Hover events, toggle maps, quickfix routing
  'commands.mux',         -- Zellij pane split commands
  'commands.utilities',   -- Jq, Sd, Xh, paths, buffers, and general tools
}

for _, module in ipairs(modules) do
  -- EXECUTION STRATEGY: The Protected Call (pcall)
  -- pcall executes a function in a "protected" mode.
  -- 1. 'ok': Boolean. True if the module loaded without errors.
  -- 2. 'err': String. Contains the stack trace or syntax error message if 'ok' is false.
  local ok, err = pcall(require, module)

  if not ok then
    -- ERROR CORRECTION:
    -- If a module fails (e.g., you're halfway through editing 'building.lua'
    -- and leave a syntax error), we route the failure to our persistent
    -- audit log (~/.local/state/nvim/config_diagnostics.log) and notify the UI.
    -- This allows you to fix the bug without losing your entire workflow.
    utils.soft_notify(string.format("CRITICAL: Failed to load %s\nError: %s", module, err), vim.log.levels.ERROR)
  end
end

return M
