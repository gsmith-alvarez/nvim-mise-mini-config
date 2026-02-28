-- [[ TABOUT: Tab-Driven Escape Hatch ]]
-- Domain: Intra-Line Navigation
--
-- PHILOSOPHY: Seamless Typing Flow
-- By restoring <Tab> as the primary key, we rely on the plugin's internal
-- "completion = true" logic to yield to blink.cmp. This creates a
-- multi-layered Tab key: Completion -> Snippets -> Tabout -> Indent.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  require('mini.deps').add('abecodes/tabout.nvim')
  vim.cmd('packadd tabout.nvim')

  require('tabout').setup({
    -- RESTORED: Standard Tab behavior
    tabkey = '<Tab>',
    backwards_tabkey = '<S-Tab>',

    act_as_tab = true,
    act_as_shift_tab = false,
    enable_backwards = true,

    -- CRITICAL: Does not yield to blink.cmp if the menu is visible
    completion = false,

    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = '`', close = '`' },
      { open = '(', close = ')' },
      { open = '[', close = ']' },
      { open = '{', close = '}' },
    },

    ignore_beginning = true,
    exclude = {},
  })
end)

if not ok then
  utils.soft_notify('Tabout failed to load: ' .. err, vim.log.levels.ERROR)
end

return M
