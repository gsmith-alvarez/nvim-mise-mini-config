-- [[ Core Autocommands ]]
--  See `:help lua-guide-autocommands`
--
-- This file defines global autocommands to automate tasks based on Neovim events.
-- Events are things like opening a file, saving a file, yanking text, etc.
--
-- Unlike standard Kickstart which places everything in `init.lua`,
-- this modular configuration isolates core Neovim autocommands into this
-- dedicated file (`lua/core/autocmds.lua`), keeping things organized.

-- Highlight when yanking (copying) text
-- When you yank text, this momentarily highlights the text you just copied.
-- It gives you visual feedback so you know exactly what you copied!
--  Try it with `yap` (yank around paragraph) in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    -- This calls Neovim's builtin yank highlight function
    vim.hl.on_yank()
  end,
})

-- Dynamic mise environment refresh
-- This checks if a local mise config exists and ensures the PATH is current
-- for this buffer's project when you enter a buffer.
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('mise-refresh', { clear = true }),
  callback = function()
    if vim.bo.buftype == "terminal" or vim.bo.filetype == "minifiles" then
      return 
    end
    if vim.fn.executable 'mise' == 1 then
      -- You could add logic here to run 'mise env' and update vim.env if needed
      -- for more complex environments, but the PATH shim usually covers most cases.
    end
  end,
})

-- [[ Transparent Archive Explorer ]]
-- This interceptor uses 'ouch' to list archive contents when you open one.
-- It eliminates the need to jump to the shell just to see what is inside a zip/tar.
vim.api.nvim_create_autocmd('BufReadCmd', {
  -- Intercept opening of common archive formats
  pattern = { '*.zip', '*.tar.gz', '*.tgz', '*.tar.bz2', '*.rar', '*.7z' },
  callback = function(args)
    local utils = require('core.utils')
    local ouch = utils.mise_shim('ouch')
    
    if not ouch then
      utils.soft_notify('ouch is missing! Install via mise to view archives.', vim.log.levels.WARN)
      return
    end

    local file = args.file
    -- Run 'ouch l <file>' to list the archive contents
    local obj = vim.system({ ouch, 'l', file }, { text = true }):wait()
    
    if obj.code == 0 then
      local lines = vim.split(obj.stdout, '\n')
      -- Write the output directly into the buffer we just intercepted
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
      vim.bo[args.buf].modifiable = false
      vim.bo[args.buf].filetype = 'nofile'
      vim.bo[args.buf].buftype = 'nofile'
      vim.notify('Viewing archive: ' .. vim.fn.fnamemodify(file, ':t'), vim.log.levels.INFO)
    else
      utils.soft_notify('Failed to read archive with ouch.', vim.log.levels.ERROR)
    end
  end,
  desc = 'Use ouch to transparently view archive contents',
})
