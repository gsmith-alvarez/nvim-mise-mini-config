-- lua/plugins/workflow/snacks.lua
-- Philosophy: Surgical Instrumentation
-- High-performance profiling with zero-overhead dormant state.

local M = {
  source = 'folke/snacks.nvim',
}

M.setup = function()
  require('mini.deps').add(M.source)

  -- KEYMAPS: Zero-Overhead Dormancy
  -- We only load the global 'snacks' configuration when explicitly requested.

  -- Open the interactive Profiler scratch buffer/picker
  vim.keymap.set('n', '<leader>zp', function()
    require('snacks').setup({
      profiler = { enabled = true },
      dashboard = { enabled = false },
      notifier = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
    })
    require('snacks').profiler.scratch()
  end, { desc = 'Speedrun: Open Profiler', nowait = true })

  -- Toggle the visual line highlights in your code
  vim.keymap.set('n', '<leader>zl', function()
    require('snacks').setup({
      profiler = { enabled = true },
      dashboard = { enabled = false },
      notifier = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
    })
    require('snacks').toggle.profiler_highlights():toggle()
  end, { desc = '[S]peedrun: Toggle Line Highlights', nowait = true })
end

M.setup()

return M
