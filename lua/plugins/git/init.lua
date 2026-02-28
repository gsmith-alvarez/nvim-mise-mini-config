-- [[ GIT ORCHESTRATOR ]]
-- Domain: Version Control & Collaboration
--
-- PHILOSOPHY: Ambient Versioning
-- Git status should be a passive signal, not an active search. 
-- These modules provide real-time feedback and high-speed resolution 
-- without requiring a context switch to a terminal.

local M = {}
local utils = require('core.utils')

local modules = {
  'git.lazygit',   -- The Heavy TUI (Active Manipulation)
  'git.diff',      -- The Gutter (Ambient Awareness)
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    utils.soft_notify(string.format("GIT DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

return M
