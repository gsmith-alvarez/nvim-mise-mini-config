-- [[ INC-RENAME: Incremental LSP Renaming ]]
-- Domain: Text Manipulation & Refactoring
--
-- PHILOSOPHY: Precision JIT Loading
-- We abandon the broad 'CmdLineEnter' autocmd, which pollutes standard 
-- editor operations. Instead, we tie the plugin's initialization directly 
-- to your LSP rename keybind (e.g., <leader>rn). It loads exactly when 
-- requested and seamlessly opens the command prompt.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ The JIT Engine ]]
local function bootstrap_increname()
  if loaded then return true end

  local ok, err = pcall(function()
    require('mini.deps').add('smjonas/inc-rename.nvim')
    
    -- We do not need vim.cmd('packadd') here because mini.deps automatically 
    -- handles the runtimepath injection during the .add() call for standard plugins.
    require('inc_rename').setup()
  end)

  if not ok then
    utils.soft_notify('Inc-Rename failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAP ]]
-- Intercepts the rename command, bootstraps the plugin, and then populates 
-- the command line with the current word under the cursor.

vim.keymap.set('n', '<leader>rn', function()
  if bootstrap_increname() then
    -- Grab the word under the cursor to pre-fill the rename prompt
    local cword = vim.fn.expand('<cword>')
    
    -- Programmatically feed the keys to open the command line in the correct state
    local keys = vim.api.nvim_replace_termcodes(':IncRename ' .. cword, true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
  end
end, { desc = 'LSP: [R]e[n]ame Symbol (JIT)' })

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator.
return M