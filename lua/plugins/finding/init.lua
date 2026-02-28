-- [[ FINDING DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/finding/init.lua
-- Domain: Search, Discovery, and Fuzzy Finding
--
-- PHILOSOPHY: Centralized Discovery
-- This orchestrator manages all tools related to finding files, text, 
-- and symbols. By using a domain-level init, we can easily toggle 
-- different search engines without touching the master config.

local M = {}
local utils = require('core.utils')

-- [[ THE SEARCH STACK ]]
local modules = {
  'finding.telescope',
  'finding.aerial',
  -- Future Growth: from 'telescope' to 'fzf-lua' 
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    utils.soft_notify(string.format("FINDING DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

return M