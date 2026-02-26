--- [[ Indentation Detection ]]
--- Automatically guesses and sets indentation settings per-file.

--[[
EXECUTION STRATEGY: Deferred loading via `BufReadPre`/`BufNewFile`.
- This is a lightweight utility that should run before you start editing.
- A one-shot autocommand loads the plugin the first time you open any file.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_Indent', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = group,
  pattern = '*',
  callback = function()
    require('mini.deps').add('NMAC427/guess-indent.nvim')
    require('guess-indent').setup {}
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_Indent' })
  end,
})
