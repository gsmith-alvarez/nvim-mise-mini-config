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
local modules = {
  -- 1. THE FOUNDATION (Synchronous Blocking)
  -- Must load first to prevent the "Flash of Unstyled Content" (FOUC).
  'ui.mini-colors',

  -- 2. THE GLYPH ENGINE (Synchronous Polyfill)
  -- Injects 'mini.icons' and polyfills 'nvim-web-devicons' so subsequent
  -- plugins don't crash looking for the legacy provider.
  'ui.mini-icons',

  -- 3. THE INTERCEPTION LAYER (Synchronous Overlay)
  -- Hijacks native vim.notify and cmdline engines before Neovim 
  -- renders the default, legacy UI.
  'ui.noice',

  -- 4. TELEMETRY (Passive Redraws)
  -- Safe to load now that colors and icons are fully active in memory.
  'ui.mini-statusline',
  'ui.mini-tabline',

  -- 5. DEFERRED ENGINES & DASHBOARDS (Event-Based)
  -- These manage their own lazy-loading via 'BufReadPre', 'VimEnter', or 
  -- JIT proxies. Their order here only registers their triggers.
  'ui.treesitter',
  'ui.mini-starter',
  'ui.which-key',
  'ui.trouble',
  'ui.render-markdown',
}

for _, mod in ipairs(modules) do
  -- Resolve the full Lua namespace path relative to 'lua/' folder
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    -- Route fatal rendering failures to the diagnostic audit trail
    utils.soft_notify(string.format("UI DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

-- THE CONTRACT: Return the module to satisfy the Master Boot Sequence
return M
