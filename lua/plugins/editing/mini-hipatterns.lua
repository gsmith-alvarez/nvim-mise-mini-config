-- [[ MINI.HIPATTERNS: Semantic Highlighting ]]
-- Domain: Visual Feedback & Code Auditing
--
-- PHILOSOPHY: Non-Blocking Visual Cues
-- We want actionable patterns (TODO, FIXME) to stand out immediately,
-- but the syntax engine must never block the main thread. This module
-- parses buffers asynchronously to provide immediate visual hierarchy.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- 1. Ensure the core suite is available via our standard installer
  require('mini.deps').add('echasnovski/mini.nvim')
  
  local hipatterns = require('mini.hipatterns')

  -- 3. Execute the setup using the validated local variable
  hipatterns.setup({
    highlighters = {
      -- We use Lua's frontier pattern `%f[%w]` to ensure we only highlight 
      -- whole words, preventing 'FIXME' from matching inside 'DO_NOT_FIXME'.
      fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack' },
      todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo' },
      note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote' },

      -- Dynamically generates highlighting for valid CSS hex colors (e.g., #FF0000)
      hex_color = hipatterns.gen_highlighter.hex_color()
    }
  })
end)

if not ok then
  -- Route any loading failures to the UI once it attaches
  utils.soft_notify('Mini.hipatterns failed to initialize: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator
return M