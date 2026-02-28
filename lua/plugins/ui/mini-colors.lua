-- [[ CATPPUCCIN: Core Aesthetic Engine ]]
-- Domain: UI & Aesthetics
--
-- PHILOSOPHY: Synchronous, Safe Rendering
-- The colorscheme must load synchronously before any other UI component to 
-- guarantee visual stability. We execute this immediately but wrap it in a 
-- robust fallback mechanism to ensure the editor remains usable even offline.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- 1. Ensure the core ecosystem is available
  -- We explicitly name the plugin to ensure the package manager resolves it correctly.
  require('mini.deps').add({
    source = 'catppuccin/nvim',
    name = 'catppuccin'
  })

  -- 2. Configure the Aesthetic Engine
  -- We explicitly tell Catppuccin which plugins we are using so it can 
  -- generate optimized highlight groups for them, creating a unified UI.
  require('catppuccin').setup({
    flavour = "mocha", -- Deep, high-contrast dark mode
    transparent_background = false,
    
    -- Explicitly disable features we don't use to save generation time
    integrations = {
      cmp = false, -- We use blink.cmp
      blink_cmp = true,
      gitsigns = true,
      mini = {
        enabled = true,
      },
      noice = true,
      notify = true,
      telescope = {
        enabled = true,
      },
      treesitter = true,
      which_key = true,
    }
  })

  -- 3. Apply the theme natively
  vim.cmd.colorscheme('catppuccin-mocha')
end)

if not ok then
  -- GRACEFUL DEGRADATION: 
  -- If Catppuccin fails to download or compile, we instantly fall back to 
  -- 'habamax' (a built-in Neovim 0.9+ theme) so your text remains readable.
  vim.cmd.colorscheme('habamax')
  utils.soft_notify('Catppuccin failed to load. Falling back to native theme. Error: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M