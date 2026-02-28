-- [[ VIM-BE-GOOD: Motion Training Engine ]]
-- Domain: Workflow & Skill Acquisition
--
-- PHILOSOPHY: Zero-Overhead Skill Development
-- This plugin is purely for training and has no place in a production 
-- buffer's memory footprint. We use a "Ghost Command" proxy that only 
-- exists as a thin Lua wrapper until the user explicitly asks to practice.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_vbg()
  if loaded then return true end

  local ok, err = pcall(function()
    -- Asymmetric Leverage: We use MiniDeps to fetch the source, 
    -- but we don't call a setup function because VBG is a legacy-style 
    -- plugin that initializes upon its command call.
    require('mini.deps').add('ThePrimeagen/vim-be-good')
    
    -- Ensure the plugin is added to the runtimepath so the global 
    -- plugin/ folder is sourced, exposing the native command.
    vim.cmd('packadd vim-be-good')
  end)

  if not ok then
    utils.soft_notify('Vim-Be-Good failed to materialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE GHOST COMMAND ]]
-- We define the command once. On the first run, it bootstraps the plugin 
-- and then delegates the call to the newly loaded native command.
vim.api.nvim_create_user_command('VimBeGood', function()
  if bootstrap_vbg() then
    -- We use pcall here because VBG sometimes fails if the window 
    -- dimensions are too small or if it's called from a special buffer.
    local success, cmd_err = pcall(vim.cmd, 'VimBeGood')
    if not success then
      utils.soft_notify('Vim-Be-Good native command failed: ' .. tostring(cmd_err), vim.log.levels.WARN)
    end
  end
end, { desc = 'Practice Vim motions (JIT Boot)' })

-- THE CONTRACT: Return the module to satisfy the Workflow Orchestrator
return M