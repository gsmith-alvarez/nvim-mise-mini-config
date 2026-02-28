-- [[ GUESS-INDENT: Automatic Indentation Detection ]]
-- Domain: Text Manipulation & Formatting
--
-- PHILOSOPHY: Defer to Buffer Read
-- Indentation detection is critical for editing but useless during the 
-- initial 30ms boot phase. We defer its execution until the exact moment 
-- a file is read into a buffer, keeping the main thread clear during boot.

local M = {}
local utils = require('core.utils')

-- [[ DEFERRED BOOTSTRAPPER ]]
-- We use a one-shot autocommand to load the plugin just before a file is read.
local group = vim.api.nvim_create_augroup('Editing_GuessIndent', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = group,
  pattern = '*',
  callback = function()
    -- 1. Safely resolve and configure the dependency
    local ok, err = pcall(function()
      require('mini.deps').add('NMAC427/guess-indent.nvim')
      require('guess-indent').setup({})
    end)

    if not ok then
      utils.soft_notify('Guess-Indent failed to initialize: ' .. err, vim.log.levels.ERROR)
    end

    -- 2. Self-Destruct
    -- We clear the autocommand group so this logic never runs again 
    -- for the duration of the Neovim session, completely removing its overhead.
    vim.api.nvim_clear_autocmds({ group = 'Editing_GuessIndent' })
  end,
})

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator.
return M