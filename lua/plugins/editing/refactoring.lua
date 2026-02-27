--- [[ Refactoring Engine ]]
--- Provides language-aware refactoring tools powered by Treesitter.

--[[
EXECUTION STRATEGY: Deferred loading via keymap stubs.
- Refactoring is an explicit action, making it perfect for on-demand loading.
- We create keymap stubs for all refactoring actions.
- The first time a key is pressed, the plugin is loaded, and all stubs
  are hotswapped to direct calls.
--]]

local loaded = false
local function load_refactoring()
  if loaded then return true end
  
  -- UNCONVENTIONAL LEVERAGE: Dependency guard.
  if not vim.g.treesitter_loaded then
    vim.notify('Treesitter not loaded yet, please wait a moment.', vim.log.levels.WARN)
    return false
  end
  
  require('mini.deps').add('nvim-lua/plenary.nvim')
  require('mini.deps').add('ThePrimeagen/refactoring.nvim')
  require('refactoring').setup()
  loaded = true
  return true
end

local refactor_keys = {
  { '<leader>rr', function() require('refactoring').select_refactor() end, 'Select Refactor' },
  { '<leader>re', function() require('refactoring').extract_var() end, 'Extract Variable' },
  { '<leader>rf', function() require('refactoring').extract_function() end, 'Extract Function' },
  { '<leader>rv', function() require('refactoring').extract_var_to_file() end, 'Extract Variable to File' },
  { '<leader>ri', function() require('refactoring').inline_var() end, 'Inline Variable' },
}

for _, key in ipairs(refactor_keys) do
  vim.keymap.set('v', key[1], function()
    if load_refactoring() then
      key[2]()
      -- Hotswap all keys at once
      for _, k in ipairs(refactor_keys) do
        vim.keymap.set('v', k[1], k[2], { desc = k[3] })
      end
    end
  end, { desc = key[3] .. ' (loads on first use)' })
end
