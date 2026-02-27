--- [[ Incremental Rename ]]
--- Live preview of LSP rename operations.

--[[
EXECUTION STRATEGY: Deferred loading via `CmdLineEnter` autocmd.
- This plugin is only needed when a command is being run.
- Loading is deferred until the user enters the command line.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_IncRename', { clear = true })
vim.api.nvim_create_autocmd('CmdLineEnter', {
  group = group,
  pattern = '*',
  callback = function()
    local MiniDeps = require('mini.deps')
    MiniDeps.add('smjonas/inc-rename.nvim')
    vim.cmd('packadd inc-rename.nvim')

    -- Configure the plugin
    require('inc_rename').setup()

    -- Self-destruct the autocommand.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_IncRename' })
  end,
})
