--- [[ Lazygit TUI Integration ]]
--- Provides a powerful Git TUI inside a floating terminal window.

--[[
EXECUTION STRATEGY: Deferred loading via keymap stub.
- `lazygit` is a heavy TUI application and should never be loaded at boot.
- We create a keymap stub for `<leader>gg`.
- The first time it's pressed, the stub function loads `toggleterm.nvim`
  (if not already loaded by another stub) and then launches lazygit.
- The stub then "hotswaps" itself to a direct call for zero overhead on
  all subsequent uses.
--]]

local utils = require('core.utils')

-- A flag to ensure toggleterm is only configured once.
-- This can be shared with other toggleterm stubs if they were in the same file.
local toggleterm_loaded = false
local function load_toggleterm()
  if toggleterm_loaded then return end
  require('mini.deps').add('akinsho/toggleterm.nvim')
  require('toggleterm').setup({
    direction = 'float',
    float_opts = { border = 'curved' },
  })
  toggleterm_loaded = true
end

vim.keymap.set('n', '<leader>gg', function()
  load_toggleterm()
  
  local lazygit_bin = utils.mise_shim('lazygit')
  if not lazygit_bin then
    utils.soft_notify('Lazygit missing. Run: mise install lazygit', vim.log.levels.WARN)
    return
  end

  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = lazygit_bin,
    direction = 'float',
    hidden = true,
    on_open = function(term)
      vim.cmd('startinsert!')
      vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  })
  lazygit:toggle()

  -- Hotswap the keymap to a new function that reuses the lazygit Terminal object.
  vim.keymap.set('n', '<leader>gg', function() lazygit:toggle() end, { desc = 'Toggle [G]it [G]ui (lazygit)' })
end, { desc = 'Toggle [G]it [G]ui (lazygit) (loads on first use)' })
