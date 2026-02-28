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
-- PHASE 1: SYNCHRONOUS BOOT (The 10ms Foundation)
-- =============================================================================
-- Only execute the absolute minimum required to draw the screen and take commands.
local immediate_domains = {
  'plugins.ui', -- Aesthetics & Interface
  'plugins.finding', -- Search & Discovery (Telescope/Fzf)
}

for _, domain in ipairs(immediate_domains) do
  safe_load(domain)
end

-- =============================================================================
-- PHASE 2: BACKGROUND DEFERRAL (The Idle Queue)
-- =============================================================================
-- Pushed to the background event loop. These evaluate immediately AFTER Neovim
-- finishes its startup sequence and draws the UI.
vim.schedule(function()
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

-- =============================================================================
-- PHASE 3: EVENT-DRIVEN DORMANCY (The Heavyweight JIT)
-- =============================================================================
-- Zero-overhead until a file is actually opened.
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  callback = function()
    safe_load 'plugins.lsp' -- Intelligence & Completion
    safe_load 'plugins.dap' -- Debugging
  end,
  desc = 'JIT Load Intelligence and Debugging Domains',
})

-- [[ INTELLIGENT HOT RELOAD ]]
-- ... keep your existing hot reload code below this line ...
