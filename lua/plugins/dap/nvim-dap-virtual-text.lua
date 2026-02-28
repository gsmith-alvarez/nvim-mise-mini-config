-- [[ DAP-VIRTUAL-TEXT: Inline State Inspection ]]
-- Domain: Debugging & UI
--
-- PHILOSOPHY: Zero-Latency State Mapping
-- Removes the need to look at a side-panel for variable values. 
-- State is rendered directly in the buffer's virtual space.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
-- 1. Infrastructure Bridge
  -- We call the bootstrap from our core DAP module. This ensures the 
  -- mfussenegger/nvim-dap library is downloaded and added to the path 
  -- BEFORE this plugin attempts to reference the 'dap' module.
  require('plugins.dap.debug').bootstrap()
  
  -- 2. Dependency Management
  require('mini.deps').add('theHamsta/nvim-dap-virtual-text')
  
  require('nvim-dap-virtual-text').setup({
    enabled = true,                        -- Enable this plugin
    enabled_commands = true,               -- Create commands like :DapVirtualTextEnable
    highlight_changed_variables = true,    -- Flash the text when a value changes
    highlight_new_as_changed = false,      -- Highlight new variables in the same way
    show_stop_reason = true,               -- Show why the debugger stopped
    commented = false,                     -- Prefix virtual text with comment string
    
    -- Filter out "noise" variables that aren't helpful in embedded
    filter = function(variable, buf)
      return true -- In hardware, we usually want to see everything
    end,
    
    -- Display Options
    virt_text_pos = 'eol',              -- Place text at the end of the line
    all_frames = false,                 -- Only show for the current stack frame
  })
end)

if not ok then
  -- Route errors to our diagnostic audit trail. 
  -- If this fails, the core debugger will still function.
  utils.soft_notify('DAP Virtual Text failed: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the LSP/DAP Orchestrator
return M