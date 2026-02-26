--- [[ Core UI Elements ]]
--- Manages secondary UI plugins like Markdown rendering and diagnostics.

--[[
EXECUTION STRATEGY: Deferred loading via `BufEnter` autocmd.
- These UI elements are important but not critical for the initial render.
- We wait until the first buffer is entered, and we explicitly check for the
  `vim.g.colors_loaded` guard flag set by `colors.lua`.
- This creates a non-blocking, ordered-by-default UI loading sequence.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_CoreUI', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  pattern = '*',
  callback = function()
    -- Wait until the colorscheme has loaded.
    if not vim.g.colors_loaded then return end

    local MiniDeps = require('mini.deps')
    MiniDeps.add('MeanderingProgrammer/render-markdown.nvim')
    MiniDeps.add('folke/trouble.nvim')

    -- Configure Markdown Rendering
    require('render-markdown').setup({})
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function() vim.treesitter.start() end,
    })
    if vim.bo.filetype == 'markdown' then vim.treesitter.start() end

    -- Configure Trouble (diagnostics viewer)
    require('trouble').setup({})
    
    -- Self-destruct the autocommand.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_CoreUI' })
  end,
})

-- Keymap stubs for Trouble
vim.keymap.set('n', '<leader>xx', function()
  if not require('trouble') then
    vim.notify('Trouble not loaded yet, please wait a moment and try again.', vim.log.levels.WARN)
    return
  end
  vim.cmd('Trouble diagnostics toggle')
  -- Hotswap
  vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
end, { desc = 'Diagnostics (Trouble) (loads on BufEnter)' })
