--- [[ Noice UI Enhancement ]]
--- Replaces the default Neovim command and message UI with a modern, clean interface.

--[[
EXECUTION STRATEGY: Deferred loading via `VimEnter` autocmd.
- `noice.nvim` and its dependencies are NOT loaded during initial startup.
- An autocommand is registered to fire ONCE when Neovim is fully loaded and idle.
- This autocmd then loads and configures the entire UI suite.
- This keeps the critical boot path clean and pushes UI setup to the last possible moment.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_Noice', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  pattern = '*',
  once = true, -- Ensure this runs only once per session
  callback = function()
    local MiniDeps = require('mini.deps')
    MiniDeps.add('folke/noice.nvim')
    MiniDeps.add('MunifTanjim/nui.nvim') -- Dependency for noice
    MiniDeps.add('rcarriga/nvim-notify') -- Dependency for noice (handles vim.notify)

    -- ASYMMETRIC LEVERAGE: Ensure plugins are loaded into runtimepath.
    vim.cmd('packadd noice.nvim')
    vim.cmd('packadd nui.nvim')
    vim.cmd('packadd nvim-notify')

    require('noice').setup({
      lsp = {
        -- override markdown body so that telescope can render it
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      -- you can enable a preset theme here, or leave it as `false` to load the default settings
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to lsp doc highlights
      },
    })

    -- Once loaded, we clear the autocmd to prevent it from ever running again.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_Noice' })
  end,
})
