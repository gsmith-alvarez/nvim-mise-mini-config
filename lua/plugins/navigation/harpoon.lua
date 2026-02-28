-- [[ HARPOON: Stateful File Navigation ]]
-- Domain: Inter-File Movement & Hooking
--
-- PHILOSOPHY: Asymmetric Loading via Centralized Proxy
-- Harpoon is essential, but you don't need it loaded the exact millisecond
-- Neovim boots. We use a "Stub and Hotswap" pattern: the first time you press
-- ANY Harpoon key, it resolves the dependency, executes the action, and
-- instantly rewrites ALL Harpoon keymaps to native calls for zero-latency
-- future use.

local M = {}
local utils = require('core.utils')

-- Internal state to prevent double-loading
local loaded = false

-- [[ The Hotswap Engine ]]
-- This function initializes the plugin and immediately rewrites all keymaps.
local function bootstrap_harpoon()
  if loaded then return true end

  -- 1. Safely resolve dependency via mini.deps
  local ok, _ = pcall(function()
    require('mini.deps').add('ThePrimeagen/harpoon')
  end)

  if not ok then
    utils.soft_notify('Failed to fetch Harpoon via mini.deps', vim.log.levels.ERROR)
    return false
  end

  -- 2. Safely setup the plugin
  local setup_ok, harpoon = pcall(require, 'harpoon')
  if not setup_ok then
    utils.soft_notify('Harpoon failed to load.', vim.log.levels.ERROR)
    return false
  end

  pcall(harpoon.setup)
  loaded = true

  -- 3. HOTSWAP: Overwrite all stubs with direct, high-performance calls.
  local mark = require('harpoon.mark')
  local ui = require('harpoon.ui')

  vim.keymap.set('n', '<M-a>', function()
    mark.add_file()
    vim.notify('Harpoon: Marked', vim.log.levels.INFO)
  end, { desc = 'Harpoon: Mark file' })

  vim.keymap.set('n', '<M-e>', ui.toggle_quick_menu, { desc = 'Harpoon: Toggle UI' })

  vim.keymap.set('n', '<leader>H', function()
    mark.clear_all()
    vim.notify('Harpoon: Cleared', vim.log.levels.INFO)
  end, { desc = 'Harpoon: Clear marks' })

  for i = 1, 4 do
    vim.keymap.set('n', '<M-' .. i .. '>', function()
      ui.nav_file(i)
    end, { desc = 'Harpoon: Go to mark ' .. i })
  end

  return true
end

-- [[ Initial Stubs (The Proxies) ]]
-- These are the lightweight keymaps active on editor boot.
-- They trigger the bootstrap, perform the requested action,
-- and are immediately erased and replaced by the Hotswap Engine above.

vim.keymap.set('n', '<M-a>', function()
  if bootstrap_harpoon() then
    require('harpoon.mark').add_file()
    vim.notify('Harpoon: Marked file', vim.log.levels.INFO)
  end
end, { desc = 'Harpoon: Mark file (JIT)' })

vim.keymap.set('n', '<M-e>', function()
  if bootstrap_harpoon() then
    require('harpoon.ui').toggle_quick_menu()
  end
end, { desc = 'Harpoon: Toggle UI (JIT)' })

vim.keymap.set('n', '<leader>H', function()
  if bootstrap_harpoon() then
    require('harpoon.mark').clear_all()
    vim.notify('Harpoon: All marks cleared.', vim.log.levels.INFO)
  end
end, { desc = 'Harpoon: Clear marks (JIT)' })

for i = 1, 4 do
  vim.keymap.set('n', '<M-' .. i .. '>', function()
    if bootstrap_harpoon() then
      require('harpoon.ui').nav_file(i)
    end
  end, { desc = 'Harpoon: Go to mark ' .. i .. ' (JIT)' })
end

return M
