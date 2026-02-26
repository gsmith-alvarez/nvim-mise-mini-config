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
    require('plugins.mini.icons')
    require('plugins.mini.statusline')
    require('plugins.mini.tabline')
    require('plugins.mini.notify')
    require('plugins.mini.diff')
    require('plugins.mini.hipatterns')
    require('plugins.mini.pairs')
    require('plugins.mini.bracketed')
    require('plugins.mini.indentscope')
    require('plugins.mini.move')
    require('plugins.mini.ai')
    require('plugins.mini.surround')
    require('plugins.mini.files')

    -- Self-destruct the autocommand.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_MiniNvim' })
  end,
})
