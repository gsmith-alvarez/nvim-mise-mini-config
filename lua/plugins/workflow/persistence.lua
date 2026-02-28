-- [[ PERSISTENCE: Session Management ]]
-- Domain: Workflow & Context Switching
--
-- PHILOSOPHY: Automatic State Recovery
-- Manually reopening files after a crash, restart, or branch switch 
-- is a low-multiplier task. Persistence automates the "where was I?" 
-- phase of development.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  require('mini.deps').add('folke/persistence.nvim')
  
  require('persistence').setup({
    -- Directory where session files are stored.
    dir = vim.fn.stdpath("state") .. "/sessions/", 
    options = { "buffers", "curdir", "tabpages", "winsize" },
  })

  -- [[ SESSION COMMANDS ]]
  local p = require('persistence')

  -- Restore the session for the current directory
  vim.keymap.set("n", "<leader>qs", function() p.load() end, 
    { desc = "Restore Session (Current Dir)" })

  -- Restore the last session (regardless of directory)
  vim.keymap.set("n", "<leader>ql", function() p.load({ last = true }) end, 
    { desc = "Restore Last Session" })

  -- Stop persistence (useful when you want to close Neovim without saving)
  vim.keymap.set("n", "<leader>qd", function() p.stop() end, 
    { desc = "Don't Save Current Session" })
end)

if not ok then
  utils.soft_notify('Persistence failed to load: ' .. err, vim.log.levels.ERROR)
end

return M