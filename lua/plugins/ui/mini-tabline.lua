-- [[ MINI.TABLINE: Workspace Visibility ]]
-- Domain: UI & Aesthetics
--
-- PHILOSOPHY: Peripheral Pattern Recognition
-- The tabline acts as a constant heads-up display of your active working set.
-- We enforce a minimalist approach, relying on file icons for rapid pattern 
-- recognition rather than reading full file paths, reducing cognitive load.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- Ensure the core ecosystem is available
  require('mini.deps').add('echasnovski/mini.nvim')
  
  -- The tabline relies heavily on visual markers. We ensure mini.icons 
  -- is present in the dependency graph to provide these markers.
  require('mini.deps').add('echasnovski/mini.icons')

  require('mini.tabline').setup({
    -- Enable file icons for rapid visual parsing.
    show_icons = true,

    -- ARCHITECTURAL EXPLICITNESS:
    -- By default, mini.tabline forcefully overrides 'vim.opt.showtabline' 
    -- and 'vim.opt.guioptions'. We explicitly define this behavior here so 
    -- you aren't left wondering why your core/options.lua is being ignored.
    set_vim_settings = true,

    -- Defines how buffer/tab names are formatted. 
    -- The native formatter intelligently handles duplicate filenames 
    -- (e.g., two index.lua files) by appending parent directory names.
    format = nil,
  })
end)

if not ok then
  -- Route any loading failures to the persistent diagnostic log
  utils.soft_notify('Mini.tabline failed to initialize: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M