-- [[ MINI.MOVE: Visual Block Shifting ]]
-- Domain: Text Manipulation & Editing
--
-- PHILOSOPHY: Ergonomic Refactoring & Mode Isolation
-- Allows you to drag visual blocks of text around the buffer using
-- the Meta (Alt) key, dynamically adjusting layout and indentation.
-- 
-- STRICT ISOLATION: This tool operates exclusively in Visual Mode (v/V).
-- Normal Mode mappings are explicitly disabled to preserve global window 
-- resizing keybinds mapped to the Meta row.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- Ensure the core suite is available
  require('mini.deps').add('echasnovski/mini.nvim')
  
  require('mini.move').setup({
    mappings = {
      -- VISUAL MODE: Dragging highlighted blocks
      left  = '<M-h>',
      right = '<M-l>',
      down  = '<M-j>',
      up    = '<M-k>',

      -- NORMAL MODE: Explicitly disabled by mapping to empty strings
      line_left  = '',
      line_right = '',
      line_down  = '',
      line_up    = '',
    },
    options = {
      -- Automatically recalculate and apply correct indentation 
      -- as the block shifts through different logical scopes (e.g., into loops).
      reindent_linewise = true,
    }
  })
end)

if not ok then
  -- Route any loading failures to the UI once it attaches
  utils.soft_notify('Mini.move failed to load: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator
return M