--- [[ Tabout Navigation Enhancement ]]
--- Allows using the <Tab> key to navigate out of brackets and quotes in insert mode.

--[[
EXECUTION STRATEGY: Immediate loading.
- This plugin is extremely lightweight and its functionality is core to the
  editing experience. Deferring it via stubs would add unnecessary complexity
  for a negligible performance gain.
- It is added and configured as soon as this file is executed, ensuring `<Tab>`
  behavior is consistent from the moment Neovim starts.
--]]

-- ASYMMETRIC LEVERAGE: MiniDeps.add is idempotent.
require('mini.deps').add('abecodes/tabout.nvim')
-- Force load: Ensure tabout's modules are in Neovim's runtimepath immediately.
vim.cmd('packadd tabout.nvim')

require('tabout').setup({
  tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
  backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout
  act_as_tab = true, -- shift content if tabout is not possible
  act_as_shift_tab = false, -- reverse shift content if tabout is not possible
  enable_backwards = true,
  -- CRITICAL: If the completion menu is open, tabout will gracefully fallback to completion.
  completion = true, 
  tabouts = {
    { open = "'", close = "'" },
    { open = '"', close = '"' },
    { open = '`', close = '`' },
    { open = '(', close = ')' },
    { open = '[', close = ']' },
    { open = '{', close = '}' },
  },
  -- ASYMMETRIC LEVERAGE: If cursor is at the beginning of a filled element, tab out rather than shift.
  ignore_beginning = true, 
  exclude = {}, -- tabout will ignore these filetypes
})
