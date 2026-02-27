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

-- All cheatsheet logic moved to lua/core/settings/keymaps.lua for <leader>?

