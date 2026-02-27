--- [[ Mini.nvim: Core Utility Suite ]]
--- The foundational plugin for various modules.

--[[
EXECUTION STRATEGY: Deferred loading via `VeryLazy` (`VimEnter` autocmd).
- The `mini.nvim` suite contains many modules that are not needed at boot.
- We defer its loading until Neovim is fully initialized and idle.
- This ensures that less critical UI elements do not interfere with the
  critical startup path.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_MiniNvim', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  pattern = '*',
  callback = function()
    require('mini.deps').add('echasnovski/mini.nvim')

    -- Load individual mini.nvim modules
    require('plugins.editing.mini.icons')
    require('plugins.editing.mini.statusline')
    require('plugins.editing.mini.tabline')
    require('plugins.editing.mini.diff')
    require('plugins.editing.mini.hipatterns')
    require('plugins.editing.mini.pairs')
    require('plugins.editing.mini.bracketed')
    require('plugins.editing.mini.indentscope')
    require('plugins.editing.mini.move')
    require('plugins.editing.mini.ai')
    require('plugins.editing.mini.surround')
    require('plugins.editing.mini.files')
    require('plugins.editing.inc-rename')


    -- Self-destruct the autocommand.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_MiniNvim' })
  end,
})
