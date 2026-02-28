-- [[ MINI.PAIRS: Auto-Closing Pairs ]]
-- Domain: Text Manipulation & Typing Flow
--
-- PHILOSOPHY: Context-Aware Typing Automation
-- We rely on the native intelligence of the plugin rather than
-- hardcoding destructive overrides for core keys like <CR>.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  require('mini.deps').add('echasnovski/mini.nvim')
  local pairs = require('mini.pairs')

  -- 2. Configuration
  pairs.setup({
    -- [[ MODE CONTROL ]]
    -- command = false: Ensures that pressing Enter in the (:)
    -- command-line executes the command normally.
    modes = { insert = true, command = false, terminal = false },

    -- [[ MAPPINGS ]]
    -- We leave this empty to inherit the flawless defaults.
    -- mini.pairs already knows exactly how to handle <CR> to expand
    -- brackets, and how to handle standard brackets/quotes.
    mappings = {
      -- If you ever need to disable a specific pair (like single quotes
      -- in Rust for lifetimes), you would do it here, e.g.:
      -- ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
    },
  })
end)

if not ok then
  utils.soft_notify('Mini.pairs failed to initialize: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator
return M
