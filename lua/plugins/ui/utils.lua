--- [[ UI Utilities: Custom View Handlers ]]
--- This module provides custom functions for a cheatsheet, loaded on-demand via keymap stubs.
---
--- Zenith and CodeGPT have been purged as per architectural directive.

--[[
EXECUTION STRATEGY: Deferred loading via keymap stubs.
- The `<leader>z` keymap is created at startup.
- The underlying plugin (`cheatsheet`) is not loaded.
- The first time the keymap is pressed, the associated stub function
  loads the plugin and overwrites the keymap to be a direct call,
  ensuring zero overhead on subsequent uses.
--]]

-- Zenith and CodeGPT related code has been removed.

local loaded_cheatsheet = false
local function load_cheatsheet()
  if loaded_cheatsheet then return end
  local MiniDeps = require('mini.deps')

  MiniDeps.add('sudormrfbin/cheatsheet.nvim')
  -- Force load cheatsheet into runtimepath.
  vim.cmd('packadd cheatsheet.nvim')

  -- NOTE: Telescope needs to be set up before cheatsheet if cheatsheet uses Telescope pickers.
  -- We will not call `require('telescope').setup()` here as Telescope's own stub handles it.
  -- We only need to ensure its modules are in `package.path`.

  require('cheatsheet').setup()
  loaded_cheatsheet = true
end

vim.keymap.set('n', '<leader>z', function()
  load_cheatsheet()
  vim.cmd('Cheatsheet')
  -- Hotswap the keymap
  vim.keymap.set('n', '<leader>z', '<cmd>Cheatsheet<CR>', { desc = 'Cheatsheet' })
end, { desc = 'Cheatsheet (loads on first use)' })
