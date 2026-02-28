-- [[ EDITING ORCHESTRATOR ]]
-- Location: lua/plugins/editing/init.lua
-- Domain: Text Manipulation, Formatting, & Refactoring
--
-- STRATEGY: Domain-Isolated Loading
-- This file acts as a local dispatcher. It requires every sibling file 
-- in this directory, wrapping them in pcalls to prevent a single 
-- configuration error from crashing the category.

local M = {}
local utils = require('core.utils')

-- Define the specific scripts in THIS directory.
-- Logic: We only list the sub-path; the loop handles the 'plugins.editing.' prefix.
-- Note: 'init' is excluded to avoid circular dependency.
local modules = {
  'editing.mini-ai',           -- Advanced text objects (mini.ai) 
  'editing.mini-hipatterns',   -- Highlighting patterns (mini.hipatterns) 
  'editing.inc-rename',   -- Real-time incremental renaming 
  'editing.indent',       -- Global indentation settings 
  'editing.indentscope',  -- Visual indent guides (mini.indentscope)
  'editing.mini-move',    -- Visual block movement (M-hjkl) 
  'editing.pairs',        -- Auto-closing pairs (mini.pairs) 
  'editing.refactoring',  -- Codebase refactoring stubs 
  'editing.surround',     -- Surround manipulation (mini.surround) 
}

for _, mod in ipairs(modules) do
  -- Resolve the full Lua namespace path relative to 'lua/' folder
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    -- Route failures to the persistent diagnostic log
    utils.soft_notify(string.format("EDITING DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

return M
  