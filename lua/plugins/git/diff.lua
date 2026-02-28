-- [[ MINI.DIFF: Ambient Git Awareness ]]
-- Domain: Version Control & Visual Feedback
--
-- PHILOSOPHY: Immediate Context
-- This module tracks the 'heartbeat' of your repository. It provides
-- high-speed, non-blocking visual cues in the sign column to indicate
-- which lines have diverged from the Git index.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- 1. Dependency Resolution
  -- We ensure the mini suite is available. mini.diff is standalone
  -- but lives within the mini.nvim ecosystem.
  require('mini.deps').add('echasnovski/mini.nvim')

  local diff = require('mini.diff')

  -- 2. Configuration
  diff.setup({
    view = {
      -- 'sign' style places indicators in the gutter to preserve
      -- horizontal screen real estate.
      style = 'sign',
      signs = { add = '+', change = '~', delete = '_' },
    },
    -- Source: Use the 'git' backend (default) for standard repos.
    -- It is optimized to run as an external process to avoid freezing the UI.
  })

  -- [[ NAVIGATION & INTERACTION ]]
  -- We treat diff hunks as physical objects you can jump between.

  -- Jump to Next/Previous Hunk
  vim.keymap.set('n', ']c', function() diff.goto_hunk('next') end, { desc = 'Next Git [C]hange' })
  vim.keymap.set('n', '[c', function() diff.goto_hunk('prev') end, { desc = 'Prev Git [C]hange' })

  -- [[ ACTION WRAPPERS ]]

  -- Toggle Overlay: Shows the deleted/changed text in-line (The "Ghost" view)
  vim.keymap.set('n', '<leader>gD', function() diff.toggle_overlay(0) end,
    { desc = 'Git: Toggle [D]iff Overlay' })

  -- Export to Quickfix: Instantly audit every change in the current file
  vim.keymap.set('n', '<leader>gq', function() diff.export_to_qf('current') end,
    { desc = 'Git: Export changes to [Q]uickfix' })

end)

if not ok then
  -- Route failures to the persistent diagnostic log
  utils.soft_notify('Mini.diff failed to initialize: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the Git Orchestrator
return M
