--- [[ Noice UI Enhancement ]]
--- Replaces the default Neovim command and message UI with a modern, clean interface.

--[[
EXECUTION STRATEGY: Scheduled Immediate Load.
- Register and load dependencies immediately.
- Use vim.schedule to ensure setup runs as soon as the core editor finishes its current task.
- This ensures Noice is active as early as possible without blocking the main boot thread.
--]]

local MiniDeps = require('mini.deps')
MiniDeps.add('folke/noice.nvim')
MiniDeps.add('MunifTanjim/nui.nvim')
MiniDeps.add('rcarriga/nvim-notify')

-- Ensure plugins are loaded into runtimepath
vim.cmd('packadd noice.nvim')
vim.cmd('packadd nui.nvim')
vim.cmd('packadd nvim-notify')

vim.schedule(function()
  local ok, noice = pcall(require, 'noice')
  if not ok then return end

  noice.setup({
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    presets = {
      bottom_search = false, -- use noice cmdline for search
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = false,
    },
  })
end)
