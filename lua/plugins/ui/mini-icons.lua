-- [[ MINI.ICONS: Visual Semantics & Polyfill ]]
-- Domain: UI & Aesthetics
--
-- PHILOSOPHY: Ubiquitous Visual Anchors
-- Provides file, folder, and system icons across the entire editor environment.
-- We configure this as a foundational UI component and use it to explicitly 
-- polyfill legacy plugins that expect the older 'nvim-web-devicons' standard.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- 1. Ensure the core ecosystem is available
  require('mini.deps').add('echasnovski/mini.icons')
  
  local icons = require('mini.icons')

  -- 2. Initialize the core rendering engine
  icons.setup({
    -- We rely on the default Nerd Font mappings. 
    -- If a specific filetype requires a custom icon in the future, 
    -- it can be defined explicitly in the `extension` or `file` tables here.
  })

  -- 3. THE POLYFILL INJECTION
  -- Intercepts any `require('nvim-web-devicons')` calls made by third-party 
  -- plugins (like Telescope or Nvim-Tree) and redirects them to mini.icons.
  icons.mock_nvim_web_devicons()
end)

if not ok then
  -- Route any loading failures to the persistent diagnostic log.
  -- The editor will gracefully degrade to text-only mode without crashing.
  utils.soft_notify('Mini.icons failed to initialize: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M