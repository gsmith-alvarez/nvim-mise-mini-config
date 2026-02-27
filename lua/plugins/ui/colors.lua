--- [[ Color Scheme Engine: Catppuccin ]]
--- Establishes the core editor aesthetic.

--[[
EXECUTION STRATEGY: Immediate, blocking load.
- The color scheme is the most foundational part of the UI. It MUST be
  loaded before any other UI elements to prevent a "flash of unstyled content".
- We add the plugin and immediately load the colorscheme.
- A global guard flag is set to signal other UI plugins that it is safe to load.
--]]

-- The add() function is idempotent.
require('mini.deps').add('catppuccin/nvim')

-- Load the colorscheme immediately.
vim.cmd.colorscheme 'catppuccin-mocha'

-- Set a global guard flag for other modules to check.
vim.g.colors_loaded = true
