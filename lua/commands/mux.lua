-- [[ MUX INTEROP: Zellij Pane Management ]]
-- Domain: Terminal Multiplexer Orchestration
--
-- ARCHITECTURE: RPC-based Layout Control
-- Instead of using a built-in terminal (which shares Neovim's single-threaded
-- event loop), we use Zellij's 'action' CLI to delegate pane management to
-- the OS. This ensures that heavy terminal output never lags the editor UI.
--
-- DEPENDENCY: Requires 'zellij' to be in the system PATH (managed via mise).

local M = {}

-- [[ Pane Orchestration ]]
-- These mappings allow you to "project" new terminal environments directly
-- from Neovim's normal mode.

-- [Z]ellij Split [V]ertical
-- Creates a new pane to the right of the current one.
vim.keymap.set('n', '<leader>zv', function()
  -- STRATEGY: External Execution
  -- vim.fn.system() fires a shell command without capturing the output,
  -- providing a "fire-and-forget" mechanism for UI orchestration.
  vim.fn.system('zellij action new-pane -d right')
end, { desc = '[Z]ellij Split [V]ertical' })

-- [Z]ellij [S]plit (Horizontal)
-- Creates a new pane below the current one.
vim.keymap.set('n', '<leader>zs', function()
  vim.fn.system('zellij action new-pane -d down')
end, { desc = '[Z]ellij [S]plit (Horizontal)' })

-- [Z]ellij [F]loating Pane
-- Spawns a centered, floating "scratchpad" pane.
-- Ideal for quick git commands or temporary CLI lookups.
vim.keymap.set('n', '<leader>zf', function()
  vim.fn.system('zellij action new-pane -f')
end, { desc = '[Z]ellij [F]loating Pane' })

-- [Z]ellij [Q]uit Current Pane
-- Sends a signal to Zellij to terminate the active pane.
vim.keymap.set('n', '<leader>zq', function()
  -- ANTI-FRAGILITY WARNING:
  -- If Neovim is the sole process in the current Zellij pane,
  -- calling this will immediately terminate the editor session.
  -- Use with caution when working in a single-pane layout.
  vim.fn.system('zellij action close-pane')
end, { desc = '[Z]ellij [Q]uit Current Pane' })

-- [[ DESIGN NOTE: Seamless Navigation ]]
-- For these commands to be truly effective, ensure your Zellij config
-- includes 'smart-splits' logic (e.g., using the zellij-nav.nvim plugin).
-- This allows <C-h/j/k/l> to move between Neovim windows and these
-- new Zellij panes without changing your muscle memory.

return M
