-- [[ YAZI: High-Performance Terminal Explorer ]]
-- Domain: External Workflow & Visual File Management
--
-- PHILOSOPHY: API-Driven JIT Execution
-- We abandon fragile Vim command hotswapping in favor of Lua API proxying.
-- Yazi and its UI dependency (Dressing) are completely sandboxed and only
-- injected into the runtime when explicitly summoned.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_yazi()
  if loaded then return true end

  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')

    -- 1. Fetch dependencies
    -- Dressing intercepts Neovim inputs (like vim.ui.select) for a better UX
    MiniDeps.add('stevearc/dressing.nvim')
    MiniDeps.add('mikavilpas/yazi.nvim')

    -- 2. Setup plugins
    require('dressing').setup()
    require('yazi').setup({
      -- We let mini.files handle standard directory opening,
      -- reserving Yazi for explicit invocations.
      open_for_directories = false,
    })
  end)

  if not ok then
    utils.soft_notify('Yazi pipeline failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY INTERCEPTORS ]]

-- 1. The Keymap Proxy
-- Uses the native Lua API instead of fragile string commands.
vim.keymap.set('n', '<leader>y', function()
  if bootstrap_yazi() then
    -- Directly call the plugin's Lua API
    require('yazi').yazi()
  end
end, { desc = '🖼️ Open Yazi (JIT)' })

-- 2. The Command Proxy
-- If you still prefer typing :Yazi in the command line, we create a safe
-- wrapper that delegates to the Lua API instead of overwriting itself.
vim.api.nvim_create_user_command('Yazi', function()
  if bootstrap_yazi() then
    require('yazi').yazi()
  end
end, { desc = 'Open Yazi File Manager (JIT)' })

-- THE CONTRACT: Return the module to satisfy the Workflow Orchestrator.
return M
