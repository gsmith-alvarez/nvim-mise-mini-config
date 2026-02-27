-- Plug-in: Smart Splits (mrjones2014/smart-splits.nvim)
--
-- Orchestrates seamless navigation between Neovim splits and external terminal
-- multiplexer panes (e.g., Zellij, Tmux). This integration is crucial for
-- maintaining a fluid development workflow across multiple terminal windows
-- without breaking mental flow.
--
-- ARCHITECTURAL PILLAR: "Mise-First Environment" & "Anti-Fragility"
--   - Integrates with mise-managed Zellij binaries.
--   - Employs `vim.fn.executable()` checks to ensure graceful degradation.
-- ARCHITECTURAL PILLAR: "Mini.nvim Consolidation"
--   - Utilizes `MiniDeps` for declarative plugin management, replacing heavier
--     alternatives and ensuring a minimal footprint.
--
-- REFERENCES:
--   - smart-splits.nvim GitHub: https://github.com/mrjones2014/smart-splits.nvim
--   - Zellij: https://zellij.dev/
--
-- IMPERATIVE ARCHITECTURE:
--   This file follows the imperative plugin loading strategy defined in `init.lua`.
--   The plugin is added via `MiniDeps.add` and then immediately made available
--   using `vim.cmd('packadd')`.

local M = {}

-- Ensure `MiniDeps` is available before attempting to add the plugin.
-- This check prevents errors if the `plugins.mini` module (which sets up MiniDeps)
-- hasn't been loaded yet, ensuring a stable startup.

--- [[ Smart-Splits: Seamless Neovim/Zellij Navigation & Resizing ]]
--- Bridges the gap between Neovim splits and Zellij panes for both movement and size.

if not package.loaded["plugins.editing.mini"] then
  require("plugins.editing.mini")
end

local loaded = false

local function smart_splits_loader()
  if loaded then return end

  local MiniDeps = require('mini.deps')
  MiniDeps.add("mrjones2014/smart-splits.nvim")
  vim.cmd("packadd smart-splits.nvim")

  local utils = require('core.utils')
  local zellij_path = utils.mise_shim('zellij')

  require("smart-splits").setup {
    multiplexer_integration = zellij_path and "zellij" or nil,
    at_edge = 'wrap', -- Optional: wrap around edges or leave as default
  }

  if not zellij_path then
    utils.soft_notify('Zellij binary not found. Smart-splits falling back to native.', vim.log.levels.WARN)
  end

  -- [[ THE HOTSWAP ]]
  local ss = require("smart-splits")

  -- 1. Movement Hotswap
  vim.keymap.set({ "n", "t" }, "<C-h>", ss.move_cursor_left, { desc = "Move Left" })
  vim.keymap.set({ "n", "t" }, "<C-j>", ss.move_cursor_down, { desc = "Move Down" })
  vim.keymap.set({ "n", "t" }, "<C-k>", ss.move_cursor_up, { desc = "Move Up" })
  vim.keymap.set({ "n", "t" }, "<C-l>", ss.move_cursor_right, { desc = "Move Right" })

  -- 2. Resize Hotswap (The part you were missing)
  vim.keymap.set({ "n", "t" }, "<M-h>", ss.resize_left, { desc = "Resize Left" })
  vim.keymap.set({ "n", "t" }, "<M-j>", ss.resize_down, { desc = "Resize Down" })
  vim.keymap.set({ "n", "t" }, "<M-k>", ss.resize_up, { desc = "Resize Up" })
  vim.keymap.set({ "n", "t" }, "<M-l>", ss.resize_right, { desc = "Resize Right" })

  loaded = true

  -- Force immediate execution of the key that triggered the load
  -- Note: feedkeys is safer here than trying to guess the specific function
  local key = vim.api.nvim_replace_termcodes(vim.v.char or "", true, false, true)
  vim.api.nvim_feedkeys(key, 'm', true)
end

-- [[ THE INITIAL STUBS ]]
-- Movement
for _, k in ipairs({ 'h', 'j', 'k', 'l' }) do
  vim.keymap.set({ "n", "t" }, "<C-" .. k .. ">", smart_splits_loader, { desc = "Smart Move " .. k })
end

-- Resizing (Alt/Meta row)
for _, k in ipairs({ 'h', 'j', 'k', 'l' }) do
  vim.keymap.set({ "n", "t" }, "<M-" .. k .. ">", smart_splits_loader, { desc = "Smart Resize " .. k })
end
