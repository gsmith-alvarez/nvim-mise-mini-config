-- [[ REFACTORING.NVIM: Codebase Transformation ]]
-- Domain: Text Manipulation & Refactoring
--
-- PHILOSOPHY: Action-Driven JIT Execution
-- Refactoring is a heavy, AST-dependent (Abstract Syntax Tree) operation. 
-- We sandbox this entirely. The engine only spins up the exact moment 
-- you attempt to extract, inline, or select a refactor block.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_refactoring()
  if loaded then return true end

  -- Treesitter Dependency Guard
  -- Treesitter must be active to parse the AST for safe refactoring.
  -- We fail gracefully if the buffer hasn't attached to a parser yet.
  local status_ok, _ = pcall(require, 'nvim-treesitter')
  if not status_ok then
    utils.soft_notify('Treesitter is not loaded. Refactoring requires AST mapping.', vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(function()
    -- Plenary is intentionally omitted here because it is globally injected 
    -- during Phase 1 by `lua/core/libs.lua`.
    require('mini.deps').add({
      source = 'ThePrimeagen/refactoring.nvim',
      depends = { 'nvim-treesitter/nvim-treesitter' }
    })
    
    require('refactoring').setup({})
  end)

  if not ok then
    utils.soft_notify('Refactoring engine failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAPS ]]
-- We define a clean table of operations. The proxy evaluates a single 
-- boolean (loaded == true) on subsequent calls, which evaluates in microseconds.

local refactors = {
  { keys = '<leader>rr', action = 'select_refactor',      modes = { 'n', 'x' }, desc = 'Select Refactor (UI)' },
  { keys = '<leader>re', action = 'extract_var',          modes = { 'x' },      desc = 'Extract Variable' },
  { keys = '<leader>rf', action = 'extract_function',     modes = { 'x' },      desc = 'Extract Function' },
  { keys = '<leader>rv', action = 'extract_var_to_file',  modes = { 'x' },      desc = 'Extract Variable to File' },
  { keys = '<leader>ri', action = 'inline_var',           modes = { 'n', 'x' }, desc = 'Inline Variable' },
}

for _, ref in ipairs(refactors) do
  vim.keymap.set(ref.modes, ref.keys, function()
    if bootstrap_refactoring() then
      require('refactoring')[ref.action]()
    end
  end, { desc = 'AST: ' .. ref.desc .. ' (JIT)' })
end

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator
return M
