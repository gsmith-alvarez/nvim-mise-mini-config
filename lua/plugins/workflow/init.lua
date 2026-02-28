-- [[ WORKFLOW ORCHESTRATOR ]]
-- Domain: External Tools, Sessions, & Environment
--
-- PHILOSOPHY: The "Mise-en-Place" Principle
-- Everything required for the job must be present, validated, and 
-- ready for use without manual intervention.

local M = {}
local utils = require('core.utils')

local modules = {
  'workflow.toggleterm',   -- Terminal Command Center
  'workflow.vim-be-good',  -- Motion training (Practice mode)
  'workflow.persistence', -- Automatic Session Management
  'workflow.overseer',    -- Task Runner & Background Jobs
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    utils.soft_notify(string.format("WORKFLOW DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

return M