-- [[ LAZYGIT: High-Performance Git TUI ]]
-- Domain: Version Control & Workflow
--
-- PHILOSOPHY: The Seamless Context-Switch
-- Lazygit is the industry standard for rapid staging, committing, and 
-- branch management. We integrate it via Toggleterm to ensure it 
-- floats above the editor without breaking the visual flow of code.

local M = {}
local utils = require('core.utils')

-- We maintain a local reference to the terminal instance to prevent 
-- 'Zombie Buffers' and ensure the toggle remains stateful.
local lazygit_instance = nil

-- [[ THE JIT BOOTSTRAPPER ]]
-- This function ensures Toggleterm is ready and the binary exists 
-- before we attempt to render the TUI.
local function get_lazygit()
  -- If we already have an active instance, return it immediately.
  if lazygit_instance then return lazygit_instance end

  -- 1. Infrastructure Check: Ensure Toggleterm is loaded.
  -- Note: We assume toggleterm.lua in the workflow domain handled its own setup.
  local status_ok, toggleterm = pcall(require, 'toggleterm.terminal')
  if not status_ok then
    utils.soft_notify("Lazygit requires Toggleterm, which failed to load.", vim.log.levels.ERROR)
    return nil
  end

  -- 2. Dependency Check: Validate Lazygit binary via mise shims.
  local lazygit_bin = utils.mise_shim('lazygit')
  if not lazygit_bin then
    utils.soft_notify('Lazygit binary not found. Please run: mise install lazygit', vim.log.levels.WARN)
    return nil
  end

  -- 3. Instance Creation: Define the terminal behavior.
  lazygit_instance = toggleterm.Terminal:new({
    cmd = lazygit_bin,
    direction = 'float',
    hidden = true,
    -- Aesthetics: Match our global curved border theme.
    float_opts = { border = 'curved' },
    -- Workflow: Auto-focus the TUI and provide an emergency exit.
    on_open = function(term)
      vim.cmd('startinsert!')
      -- Maps 'q' to close the window without killing the process.
      vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  })

  return lazygit_instance
end

-- [[ THE GLOBAL INTERFACE ]]
-- We provide a clean, proxy-based keymap. This avoids 'Hotswap' fragility 
-- while maintaining a sub-millisecond execution path.
vim.keymap.set('n', '<leader>gg', function()
  local lg = get_lazygit()
  if lg then
    lg:toggle()
  end
end, { desc = 'Git: [G]it [G]ui (Lazygit)' })

-- THE CONTRACT: Return the module to satisfy the Git Orchestrator
return M
