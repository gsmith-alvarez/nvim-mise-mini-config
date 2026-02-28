-- [[ MINI.AI: Advanced Text Objects ]]
-- Domain: Text Manipulation & Smart Selection
--
-- PHILOSOPHY: Structural Precision
-- Enhances the "What" in your editing workflow. This expands Neovim's native 
-- text objects (like 'iw' or 'i(') to dynamically understand code structures 
-- (arguments, functions, tags, etc.) with high precision.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- Ensure the core suite is available
  require('mini.deps').add('echasnovski/mini.nvim')
  
  require('mini.ai').setup({ 
    -- Optimization: Restricts the forward/backward search scope to 500 lines.
    -- This guarantees sub-millisecond execution times even when editing 
    -- massive, 10,000+ line files, preventing main-thread blocking.
    n_lines = 500 
  })
end)

if not ok then
  -- Route any loading failures to the UI once it attaches
  utils.soft_notify('Mini.ai failed to load: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator
return M