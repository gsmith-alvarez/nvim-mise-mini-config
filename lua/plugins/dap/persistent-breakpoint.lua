-- [[ PERSISTENT-BREAKPOINTS: Debug State Serialization ]]
-- Domain: Debugging & Project Continuity
--
-- PHILOSOPHY: The "Trap" Persistence Principle
-- In complex hardware debugging (PlatformIO), re-setting 10 breakpoints 
-- every morning is a high-friction task. This module ensures your 
-- debug traps are saved to disk and restored automatically upon reload.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- 1. Infrastructure Bridge
  -- We call the bootstrap from our core DAP module. This ensures the 
  -- mfussenegger/nvim-dap library is in the runtime path BEFORE this 
  -- plugin tries to hook into its breakpoint internal table.
  require('plugins.dap.debug').bootstrap()

  -- 2. Dependency Management
  -- We use MiniDeps to track the source. 
  require('mini.deps').add('Weissle/persistent-breakpoints.nvim')
  
  -- 3. Configuration
  require('persistent-breakpoints').setup({
    -- Automatically load breakpoints as soon as a source file is opened.
    load_breakpoints_event = { "BufReadPost" },
    
    -- XDG Compliance: We store the session data in Neovim's state dir 
    -- (~/.local/state/nvim/breakpoints) to keep the config folder clean.
    save_dir = vim.fn.stdpath("state") .. "/breakpoints/",
  })

  -- [[ THE PERSISTENT INTERFACE ]]
  -- We obtain a handle to the API to bind our persistent toggle commands.
  local pb = require('persistent-breakpoints.api')

  -- PRIMARY TOGGLE: Replaces the standard DAP toggle with the persistent one.
  vim.keymap.set('n', '<leader>db', pb.toggle_breakpoint, 
    { desc = "Debug: Toggle Persistent Breakpoint" })
    
  -- BULK CLEANUP: Useful for clearing the slate after a major bug squash.
  vim.keymap.set('n', '<leader>dB', pb.clear_all_breakpoints, 
    { desc = "Debug: Clear ALL Project Breakpoints" })

  -- [[ THE AUTO-SAVE BRIDGE ]]
  -- Standard DAP breakpoints are volatile. We use an Autocmd to flush 
  -- the current breakpoint state to the JSON file on every buffer write.
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      pb.store_breakpoints()
    end,
  })
end)

if not ok then
  -- Route errors to the Audit Trail without crashing the rest of the editor.
  utils.soft_notify('Persistent Breakpoints failed: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the LSP/DAP Orchestrator
return M