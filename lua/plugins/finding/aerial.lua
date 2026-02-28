-- [[ AERIAL: Structural Code Navigation ]]
-- Domain: Search, Discovery, and Navigation
--
-- PHILOSOPHY: Spatial Awareness
-- Provides a persistent, hierarchical view of code symbols (functions, classes).
-- It allows you to maintain context in massive files without opening 
-- modal search windows.

local M = {}
local utils = require('core.utils')

-- [[ THE JIT PROXY ]]
local loaded = false

local function bootstrap_aerial()
  if loaded then return true end

  local ok, err = pcall(function()
    require('mini.deps').add('stevearc/aerial.nvim')

    require('aerial').setup({
      -- We prioritize Treesitter for speed, but fallback to LSP 
      -- for languages without robust TS parsers.
      backends = { "treesitter", "lsp", "markdown", "man" },

      -- UI Layout
      layout = {
        max_width = { 40, 0.2 },
        min_width = 30,
        default_direction = "right", -- Keep it on the right to balance the screen
        placement = "window",
      },

      -- Visual Feedback
      show_guides = true,
      highlight_on_hover = true,
      
      -- Integrated Icons: Links directly to our mini.icons engine
      icons = require('mini.icons').get('lsp'),

      -- Automatic jumping: when you move the cursor in the main window, 
      -- Aerial highlights the corresponding symbol in the sidebar.
      manage_folds = false,
      link_tree_to_values = true,
      link_cursor_to_symbol = true,
    })
  end)

  if not ok then
    utils.soft_notify('Aerial failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE KEYMAP ]]
-- We map this to <leader>va (View Aerial) to stay consistent with our UI 
-- discovery patterns.
vim.keymap.set('n', '<leader>va', function()
  if bootstrap_aerial() then
    vim.cmd('AerialToggle!')
  end
end, { desc = 'View: Toggle [A]erial Structure' })

return M