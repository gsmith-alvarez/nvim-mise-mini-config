-- [[ TROUBLE: Diagnostic & Quickfix Aggregation ]]
-- Domain: UI & Code Auditing
--
-- PHILOSOPHY: Action-Driven JIT Execution
-- Trouble is a heavy diagnostic aggregator. It should never load when a buffer 
-- opens. It should only consume memory the exact millisecond you ask to view 
-- your workspace errors.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_trouble()
  if loaded then return true end

  local ok, err = pcall(function()
    require('mini.deps').add('folke/trouble.nvim')
    
    require('trouble').setup({
      -- We enforce modern UI aesthetics that match our Catppuccin theme
      auto_close = true,       -- Auto close when an item is selected
      auto_preview = false,    -- Disable auto-preview to save CPU cycles
      focus = true,            -- Jump straight into the Trouble window
    })
  end)

  if not ok then
    utils.soft_notify('Trouble failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAPS ]]
-- We define a clean table of operations. The proxy evaluates a single 
-- boolean (loaded == true) on subsequent calls, which evaluates in microseconds.

local trouble_keys = {
  { keys = '<leader>xx', action = 'diagnostics toggle',             desc = 'Workspace Diagnostics' },
  { keys = '<leader>xd', action = 'diagnostics toggle filter.buf=0', desc = 'Document Diagnostics' },
  { keys = '<leader>xq', action = 'qflist toggle',                  desc = 'Quickfix List' },
  { keys = '<leader>xl', action = 'loclist toggle',                 desc = 'Location List' },
}

for _, key in ipairs(trouble_keys) do
  vim.keymap.set('n', key.keys, function()
    if bootstrap_trouble() then
      -- Pass the action string directly to the native Vim command interface
      vim.cmd('Trouble ' .. key.action)
    end
  end, { desc = 'Trouble: ' .. key.desc .. ' (JIT)' })
end

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M
