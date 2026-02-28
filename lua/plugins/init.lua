-- [[ PLUGIN DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/init.lua
-- Architecture: Asymmetric Event-Driven Loader
--
-- STRATEGY: Domain-Isolated Execution with Non-Blocking Deferral

local M = {}
local utils = require 'core.utils'

-- Helper to safely load and route errors
local function safe_load(domain)
  local ok, err = pcall(require, domain)
  if not ok then
    utils.soft_notify(string.format('DOMAIN LOAD FAILURE: [%s]\n%s', domain, err), vim.log.levels.ERROR)
  end
end

-- =============================================================================
-- PHASE 1: CONTEXT-AWARE BOOT
-- =============================================================================
local MiniDeps = require('mini.deps')

if vim.fn.argc() > 0 then
  MiniDeps.now(function()
    -- Direct file: load everything immediately for Context-Aware Boot
    safe_load('plugins.ui')
    safe_load('plugins.finding')
    safe_load('plugins.lsp')
    safe_load('plugins.dap')
  end)
elseif #vim.api.nvim_list_uis() > 0 then
  -- Dashboard: load UI immediately, defer LSP
  MiniDeps.now(function()
    safe_load('plugins.ui')
    safe_load('plugins.finding')
  end)
  MiniDeps.later(function()
    safe_load('plugins.lsp')
    safe_load('plugins.dap')
    -- Re-trigger FileType to ensure LSP and Treesitter attach retroactively
    vim.api.nvim_exec_autocmds('FileType', { buffer = 0, modeline = false })
  end)
else
  -- Headless (e.g., nvim --headless +q)
  MiniDeps.now(function()
    MiniDeps.add('neovim/nvim-lspconfig')
  end)
end

-- =============================================================================
-- PHASE 2: BACKGROUND DEFERRAL (The Idle Queue)
-- =============================================================================
-- Pushed to the background event loop. These evaluate immediately AFTER Neovim
-- finishes its startup sequence and draws the UI.
if #vim.api.nvim_list_uis() > 0 then
  MiniDeps.later(function()
    local scheduled_domains = {
      'plugins.navigation', -- Physical Movement & Flow
      'plugins.editing', -- Text Manipulation (Surround, pairs, etc.)
      'plugins.workflow', -- External TUI / Snacks
      'plugins.git', -- Version Control
    }
    for _, domain in ipairs(scheduled_domains) do
      safe_load(domain)
    end
  end)
end

-- [[ INTELLIGENT HOT RELOAD ]]
-- ... keep your existing hot reload code below this line ...
