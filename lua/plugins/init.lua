-- [[ PLUGIN DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/init.lua
-- Architecture: Hierarchical Fault-Tolerant Loader
--
-- STRATEGY: Domain-Isolated Execution
-- Your plugins are organized by functional domains. This loader iterates 
-- through these folders, ensuring that a failure in a 'workflow' or 'git' 
-- plugin never prevents 'lsp' or 'ui' from initializing.

local M = {}
local utils = require('core.utils')

-- [[ THE DOMAIN INVENTORY ]]
-- These strings correspond to the init.lua files within lua/plugins/<domain>/
-- We load them in a specific order to ensure foundational UI exists before 
-- advanced logic (LSP/DAP) attempts to attach to it.
local plugin_domains = {
  'plugins.ui',         -- 1. Aesthetics & Interface (Critical Foundation)
  'plugins.lsp',        -- 2. Intelligence & Completion
  'plugins.navigation', -- 3. Physical Movement & Flow
  'plugins.editing',    -- 4. Text Manipulation
  'plugins.finding',    -- 5. Search & Discovery
  'plugins.workflow',   -- 6. External TUI
  'plugins.git',        -- 7. Version Control
  'plugins.dap',        -- 8. Debugging
}

-- [[ EXECUTION LOOP ]]
for _, domain in ipairs(plugin_domains) do
  -- Protected Call (pcall) sandboxes each domain's entry point.
  local ok, err = pcall(require, domain)

  if not ok then
    -- ERROR ROUTING:
    -- Failures are logged to ~/.local/state/nvim/config_diagnostics.log
    -- and reported via the UI if available.
    utils.soft_notify(string.format("DOMAIN LOAD FAILURE: [%s]\n%s", domain, err), vim.log.levels.ERROR)
  end
end

-- [[ INTELLIGENT HOT RELOAD ]]
-- Automatically re-sources plugin configurations when you save them.
-- This allows for live-tweaking of UI colors, keymaps, or LSP settings.
local group = vim.api.nvim_create_augroup('PluginHotReload', { clear = true })

vim.api.nvim_create_autocmd('BufWritePost', {
  group = group,
  pattern = '*/lua/plugins/**/*.lua',
  callback = function(event)
    -- Guard 1: Don't reload any 'init.lua' files.
    -- Re-loading an orchestrator can cause infinite loops or duplicate setup calls.
    if event.file:match('init%.lua$') then return end

    -- Guard 2: Extract and validate the Lua module path.
    local module_name = event.file:match('lua/(plugins/.-)%.lua$')
    if not module_name then return end
    
    -- Convert path to Lua dot-notation: 'plugins/ui/colors' -> 'plugins.ui.colors'
    module_name = module_name:gsub('/', '.')

    -- Guard 3: Safe Cache Purge & Re-require
    -- We use a protected call to ensure a syntax error in the file being 
    -- saved doesn't crash the active Neovim session.
    package.loaded[module_name] = nil 
    
    local ok, err = pcall(require, module_name)
    if ok then
      vim.notify('󰚰 Plugin Config Reloaded: ' .. module_name, vim.log.levels.INFO)
    else
      utils.soft_notify('Plugin Reload Failed: ' .. err, vim.log.levels.ERROR)
    end
  end,
  desc = 'Live-reload plugin configurations on save without breaking state.',
})

return M