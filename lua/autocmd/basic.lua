-- [[ SYSTEM AUTOCOMMANDS ]]
-- Domain: Event-Driven Logic & UI Management
--
-- ARCHITECTURE: Protected Event Loops
-- This module registers "hooks" into Neovim's lifecycle. We prioritize
-- non-blocking callbacks to ensure the editor remains responsive during
-- heavy I/O or buffer transitions.

local M = {}

-- [[ Group Definition ]]
-- We use a single group to allow for clean reloading.
local basic_group = vim.api.nvim_create_augroup('BasicAutocmds', { clear = true })

-- [[ 1. UX: Visual Feedback on Yank/Delete ]]
-- Provides immediate confirmation of a successful operation.
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      -- HIGHLIGHT OPTIONS:
      -- 'IncSearch' is a high-contrast choice (usually yellow/orange)
      -- 'Visual' is more subtle (matches your selection color)
      higroup = 'IncSearch',
      timeout = 150, -- Duration of the flash in milliseconds
    })
  end,
})

-- [[ 2. UI: Auto-Resize Layout ]]
-- Ensures your window splits maintain proportional balance when the
-- terminal emulator window is resized.
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Keep splits balanced on resize',
  group = basic_group,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    -- We use 'noautocmd' to prevent this loop from triggering other events.
    vim.cmd('noautocmd tabdo wincmd =')
    vim.cmd('noautocmd tabnext ' .. current_tab)
  end,
})

-- [[ 3. I/O: Auto-Create Directories ]]
-- RADICAL INNOVATION: Before writing a file, we check if the directory
-- exists. If not, we create the full path recursively.
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Create missing parent directories on save',
  group = basic_group,
  callback = function(event)
    -- Ignore URIs (git://, sftp://, etc.)
    if event.match:match('^%w%w+://') then return end

    local file = vim.uv.fs_realpath(event.match) or event.match
    local dir = vim.fn.fnamemodify(file, ':p:h')

    -- PERFORMANCE: Use native Lua filesystem check instead of shell call.
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- [[ 4. NAVIGATION: Cursor Persistence ]]
-- Returns the cursor to the exact line and column where you last left the file.
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor position on file entry',
  group = basic_group,
  callback = function(args)
    -- Ignore ephemeral buffers like commit messages or rebase logs
    if vim.bo[args.buf].filetype == 'gitcommit' then return end

    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      -- 'zz' centers the screen on the restored position.
      pcall(vim.cmd, 'normal! g`"zz')
    end
  end,
})

-- [[ 5. UI: Ephemeral Buffer Management ]]
-- Sets 'q' to close read-only or diagnostic windows instantly.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Quick-close specific tool windows',
  group = basic_group,
  pattern = { 'help', 'lspinfo', 'qf', 'checkhealth', 'man', 'gitsigns-blame', 'notify' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true, nowait = true })
  end,
})

-- [[ 6. SYNC: External Modification Check ]]
-- Triggers Neovim to check if the file on disk has changed (e.g., via a git pull
-- in another terminal) whenever the window regains focus.
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Sync buffer with disk changes',
  group = basic_group,
  callback = function()
    -- Only check standard files; ignore scratchpads or terminals.
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- THE CONTRACT: Return an empty table to satisfy the Sandboxed Orchestrator.
return M
