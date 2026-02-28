-- [[ AUTOCOMMANDS ORCHESTRATOR ]]
-- Architecture: Fault-Tolerant Module Loading
-- This file serves as the central dispatcher for all custom autocommands.

local utils = require('core.utils')

-- Define the domain-specific modules to be loaded.
local modules = {
  'autocmd.basic',    -- Core editor behaviors (yank, resize, etc)
  'autocmd.external', -- External tool integrations (mise, ouch, bigfile)
  'autocmd.jit',      -- Bootstrapping for heavy modules (Obsidian, LuaSnip)
}

for _, module in ipairs(modules) do
  -- EXECUTION STRATEGY: The Protected Call (pcall)
  local ok, err = pcall(require, module)

  if not ok then
    -- ERROR CORRECTION: Log failure to state and notify UI.
    utils.soft_notify(string.format("CRITICAL: Failed to load %s\nError: %s", module, err), vim.log.levels.ERROR)
  end
end

-- [[ SELF-CORRECTING HOT RELOAD ]]
-- Detects when you save any file within the autocmd directory
-- and re-sources it instantly.
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*/lua/autocmd/*.lua',
  callback = function(event)
    local module_name = event.file:match('lua/(autocmd/.*)%.lua$'):gsub('/', '.')
    
    -- Clear the Lua cache for this module so the next require pulls fresh code.
    package.loaded[module_name] = nil
    
    local ok, err = pcall(require, module_name)
    if ok then
      vim.notify('Reloaded: ' .. module_name, vim.log.levels.INFO)
    else
      utils.soft_notify('Reload Failed: ' .. err, vim.log.levels.ERROR)
    end
  end,
  desc = 'Auto-reload autocmd modules on save',
}) 

-- vim: ts=2 sts=2 sw=2 et
