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

-- [[ Big File Management: Defensive Interceptor ]]
-- Detects files over 2MB and disables heavy features to preserve performance.
-- For JSON files, it specifically suggests using Jless.
local big_file_group = vim.api.nvim_create_augroup('BigFileMode', { clear = true })

vim.api.nvim_create_autocmd('BufReadPre', {
  group = big_file_group,
  pattern = '*',
  callback = function(ev)
    local max_filesize = 2 * 1024 * 1024 -- 2MB Threshold
    local ok, stats = pcall(vim.loop.fs_stat, ev.match)

    if ok and stats and stats.size > max_filesize then
      -- 1. Disable performance-heavy features
      vim.b.bigfile = true
      vim.cmd('syntax off')
      vim.cmd('LspStop') -- Stop the LSP from choking on this file
      vim.opt_local.undoreload = 0
      vim.opt_local.swapfile = false

      -- 2. Contextual Notification for JSON
      local extension = vim.fn.fnamemodify(ev.match, ':e')
      if extension == 'json' then
        vim.notify(
          "⚠️ Big JSON Detected (" .. math.floor(stats.size / 1024 / 1024) .. "MB). \nUse :Jless for better performance.",
          vim.log.levels.WARN,
          { title = "Big File Mode" }
        )
      else
        vim.notify("🚀 Big File Mode: Syntax and LSP disabled for speed.", vim.log.levels.INFO)
      end
    end
  end,
})

-- [[ Auto-Resize Splits on Terminal Resize ]]
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('ResizeSplits', { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- [[ Auto-Create Missing Directories on Save ]]
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('AutoCreateDir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+://') then return end -- Ignore URIs
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- [[ Restore Cursor Position ]]
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('RestoreCursor', { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      -- Jump to the mark and center the screen (zz)
      vim.cmd('normal! g`"zz')
    end
  end,
})

-- [[ Quick Close Ephemeral Buffers ]]
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('CloseWithQ', { clear = true }),
  pattern = { 'help', 'lspinfo', 'qf', 'checkhealth', 'man', 'gitsigns-blame' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
  end,
})

-- [[ Auto-Reload Externally Modified Files ]]
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('CheckOutsideTime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- ============================================================================
-- MODULE: JIT Entry Points (Obsidian & LuaSnip)
-- CONTEXT: Global stubs and autocmds that bootstrap heavy modules on demand.
-- ============================================================================

local map = vim.keymap.set

-- 1. THE AUTOCOMMAND ENTRY POINTS (Buffer Context)
local jit_group = vim.api.nvim_create_augroup("JIT_Notetaking", { clear = true })

-- Obsidian JIT
vim.api.nvim_create_autocmd("FileType", {
  group = jit_group,
  pattern = "markdown",
  callback = function()
    if not vim.g.obsidian_loaded then
      require("plugins.notetaking.obsidian").setup()
      vim.g.obsidian_loaded = true
    end
  end,
})

-- LuaSnip JIT
vim.api.nvim_create_autocmd("FileType", {
  group = jit_group,
  pattern = { "markdown", "tex" },
  callback = function()
    if not vim.g.luasnip_loaded then
      require("plugins.notetaking.luasnips").setup()
      vim.g.luasnip_loaded = true
    end
  end,
})

-- 2. THE GLOBAL STUB ENTRY POINTS (Cross-Workspace Context)
-- These allow you to search your vault while working in a Python or Rust file.
-- They intercept the keystroke, load the plugin, and then execute the native command.

local function bootstrap_obsidian(cmd)
  return function()
    if not vim.g.obsidian_loaded then
      require("plugins.notetaking.obsidian").setup()
      vim.g.obsidian_loaded = true
    end
    -- Execute the requested Obsidian command after the plugin is verified loaded
    vim.cmd(cmd)
  end
end

-- Map the stubs
map("n", "<leader>oq", bootstrap_obsidian("ObsidianQuickSwitch"), { desc = "[O]bsidian [Q]uick Switch" })
map("n", "<leader>os", bootstrap_obsidian("ObsidianSearch"), { desc = "[O]bsidian [S]earch (Ripgrep)" })
map("n", "<leader>on", bootstrap_obsidian("ObsidianNew"), { desc = "[O]bsidian [N]ew Note" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
