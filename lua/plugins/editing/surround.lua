-- [[ MINI.SURROUND: Structural Pair Manipulation ]]
-- Domain: Text Manipulation & Formatting
--
-- PHILOSOPHY: Surroundings as Objects
-- Allows you to add, delete, and replace surrounding pairs (quotes, 
-- brackets, HTML tags) using a consistent prefix. We use 'gz' to keep
-- the native 's' key free for future high-speed navigation plugins.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- Ensure the core suite is available via our standard installer
  require('mini.deps').add('echasnovski/mini.nvim')
  
  require('mini.surround').setup({
    -- [[ MAPPINGS ]]
    -- We override the defaults to use the 'gz' prefix.
    -- Tip: 'gza' (add), 'gzd' (delete), 'gzr' (replace).
    mappings = {
      add            = 'gza', -- Add surrounding
      delete         = 'gzd', -- Delete surrounding
      find           = 'gzf', -- Find surrounding (to the right)
      find_left      = 'gzF', -- Find surrounding (to the left)
      highlight      = 'gzh', -- Highlight surrounding
      replace        = 'gzr', -- Replace surrounding
      update_n_lines = 'gzn', -- Update `n_lines`
      
      -- We explicitly disable the default 's' prefix to avoid conflicts
      suffix_last    = '',
      suffix_next    = '',
    },

    -- [[ OPTIONS ]]
    -- How many lines to look for surroundings. 20 is a sane default
    -- that balances performance with file context.
    n_lines = 50,
    
    -- Search method: 'cover', 'cover_or_next', 'cover_or_prev', 'cover_or_nearest'
    -- 'cover_or_next' is the industry standard for intuitive behavior.
    search_method = 'cover_or_next',
  })
end)

if not ok then
  -- Route any loading failures to the UI once it attaches
  utils.soft_notify('Mini.surround failed to load: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator
return M