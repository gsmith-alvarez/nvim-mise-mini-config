-- [[ UI DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/ui/init.lua
-- Domain: Aesthetics, Telemetry, and Visual Overlays
--
-- PHILOSOPHY: Strict Rendering Hierarchy
-- We abandon alphabetical loading in favor of a rigid, dependency-first
-- boot sequence. Foundational layers (colors and icons) must be locked in
-- memory before the telemetry engines (statusline/tabline) attempt to draw.

local M = {}
local utils = require('core.utils')

-- [[ THE RENDERING PIPELINE ]]
-- Order is absolute. Do not alphabetize this list.

-- 1. THE FOUNDATION (Synchronous Blocking)
-- Must load first to prevent the "Flash of Unstyled Content" (FOUC)
-- and to polyfill icons for other plugins.
local sync_modules = {
  'ui.mini-colors',
  'ui.mini-icons',
}
for _, mod in ipairs(sync_modules) do
  local ok, err = pcall(require, 'plugins.' .. mod)
  if not ok then
    utils.soft_notify(string.format("UI-SYNC DOMAIN FAILURE: [%s]\n%s", mod, err), vim.log.levels.ERROR)
  end
end

-- 2. DEFERRED UI (Scheduled for Next Tick)
-- These are heavy UI components that can be initialized *after* startup.
vim.schedule(function()
  local deferred_modules = {
    'ui.noice',           -- Interception Layer (heavy)
    'ui.mini-statusline', -- Telemetry
    'ui.mini-tabline',    -- Telemetry
  }
  for _, mod in ipairs(deferred_modules) do
    local ok, err = pcall(require, 'plugins.' .. mod)
    if not ok then
      utils.soft_notify(string.format("UI-DEFERRED DOMAIN FAILURE: [%s]\n%s", mod, err), vim.log.levels.ERROR)
    end
  end
end)

-- 3. EVENT-BASED PLUGINS (JIT / Autocmd Triggers)
-- Requiring these is cheap; it only sets up the trigger (e.g., VimEnter, FileType)
-- that will perform the heavy lifting later.
local event_modules = {
  'ui.treesitter',
  'ui.mini-starter',
  'ui.which-key',
  'ui.trouble',
  'ui.render-markdown',
}
for _, mod in ipairs(event_modules) do
  -- Resolve the full Lua namespace path relative to 'lua/' folder
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    -- Route fatal rendering failures to the diagnostic audit trail
    utils.soft_notify(string.format("UI-EVENT DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

-- THE CONTRACT: Return the module to satisfy the Master Boot Sequence
return M
