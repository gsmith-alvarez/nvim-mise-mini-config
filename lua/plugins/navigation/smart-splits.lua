-- [[ SMART-SPLITS: Multiplexer Integration ]]
-- Domain: Inter-Pane Movement (Neovim <-> Zellij)
--
-- PHILOSOPHY: Anti-Fragile Proxy Execution
-- Bridges Neovim splits and Zellij panes. We defer loading until a
-- directional movement or resize is explicitly requested.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The Hotswap Engine ]]
local function bootstrap_smart_splits()
  if loaded then return true end

  -- 1. Safely resolve dependencies
  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')
    MiniDeps.add("mrjones2014/smart-splits.nvim")
    vim.cmd("packadd smart-splits.nvim")

    -- Check for mise-managed Zellij
    local zellij_path = utils.mise_shim('zellij')

    if not zellij_path then
      utils.soft_notify('Zellij binary not found. Smart-splits falling back to native.', vim.log.levels.WARN)
    end

    require("smart-splits").setup({
      multiplexer_integration = zellij_path and "zellij" or nil,
      at_edge = 'wrap',
    })
  end)

  if not ok then
    utils.soft_notify('Smart-splits failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  -- 2. HOTSWAP: Overwrite all proxies with native calls
  local ss = require("smart-splits")

  vim.keymap.set({ "n", "t" }, "<C-h>", ss.move_cursor_left, { desc = "Move Left" })
  vim.keymap.set({ "n", "t" }, "<C-j>", ss.move_cursor_down, { desc = "Move Down" })
  vim.keymap.set({ "n", "t" }, "<C-k>", ss.move_cursor_up, { desc = "Move Up" })
  vim.keymap.set({ "n", "t" }, "<C-l>", ss.move_cursor_right, { desc = "Move Right" })

  -- Resizing is scoped to Normal/Terminal to avoid collision with mini.move (Visual)
  vim.keymap.set({ "n", "t" }, "<M-h>", ss.resize_left, { desc = "Resize Left" })
  vim.keymap.set({ "n", "t" }, "<M-j>", ss.resize_down, { desc = "Resize Down" })
  vim.keymap.set({ "n", "t" }, "<M-k>", ss.resize_up, { desc = "Resize Up" })
  vim.keymap.set({ "n", "t" }, "<M-l>", ss.resize_right, { desc = "Resize Right" })

  loaded = true
  return true
end

-- [[ THE PROXY STUBS ]]
-- Maps the requested direction to the specific function that must execute
-- after the boot sequence completes.

local directions = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right'
}

for key, dir in pairs(directions) do
  -- Movement Stubs
  vim.keymap.set({ "n", "t" }, "<C-" .. key .. ">", function()
    if bootstrap_smart_splits() then
      require('smart-splits')['move_cursor_' .. dir]()
    end
  end, { desc = "Smart Move " .. dir .. " (JIT)" })

  -- Resizing Stubs
  vim.keymap.set({ "n", "t" }, "<M-" .. key .. ">", function()
    if bootstrap_smart_splits() then
      require('smart-splits')['resize_' .. dir]()
    end
  end, { desc = "Smart Resize " .. dir .. " (JIT)" })
end

return M
