-- [[ EXTERNAL TOOLS & PERFORMANCE AUTOCOMMANDS ]]
-- Domain: System Interop & Resource Protection
--
-- PHILOSOPHY: Anti-Fragile Resource Management
-- Neovim should not crash when encountering massive files or binary archives.
-- We use "Defensive Interceptors" to detect these conditions early and
-- pivot to lightweight viewing modes or external high-performance tools.

local M = {}

local external_group = vim.api.nvim_create_augroup('ExternalAutocmds', { clear = true })

-- [[ 1. Environment: Mise Dynamic Awareness ]]
-- Ensures that the editor stays synchronized with the version manager.
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Synchronize environment context on buffer entry',
  group = external_group,
  callback = function()
    -- PERFORMANCE: Skip checks for non-file buffers.
    if vim.bo.buftype == "terminal" or vim.bo.filetype == "minifiles" then
      return
    end

    -- Future Expansion: Add logic here to re-evaluate local project shims
    -- if you find your LSP pathing gets desynced in monorepos.
  end,
})

-- [[ 2. I/O: Transparent Archive Explorer ]]
-- Uses the 'ouch' CLI (a high-performance Rust tool) to list archive contents
-- directly in a Neovim buffer without extracting them to disk.
vim.api.nvim_create_autocmd('BufReadCmd', {
  desc = 'Use ouch to transparently view archive contents',
  group = external_group,
  pattern = { '*.zip', '*.tar.gz', '*.tgz', '*.tar.bz2', '*.rar', '*.7z' },
  callback = function(args)
    local utils = require('core.utils')
    local ouch = utils.mise_shim('ouch')

    if not ouch then
      utils.soft_notify('ouch-cli missing! Install via mise to preview archives.', vim.log.levels.WARN)
      return
    end

    local file = args.file
    -- ASYMMETRIC LEVERAGE: List archive contents via external binary.
    -- 'l' = list command in ouch.
    local obj = vim.system({ ouch, 'l', file }, { text = true }):wait()

    if obj.code == 0 then
      local lines = vim.split(obj.stdout, '\n')
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)

      -- Set buffer to read-only/scratch mode to prevent accidental editing
      vim.bo[args.buf].modifiable = false
      vim.bo[args.buf].filetype = 'archive'
      vim.bo[args.buf].buftype = 'nofile'

      vim.notify('📦 Viewing Archive: ' .. vim.fn.fnamemodify(file, ':t'), vim.log.levels.INFO)
    else
      utils.soft_notify('ouch failed to decode archive: ' .. (obj.stderr or "Unknown error"), vim.log.levels.ERROR)
    end
  end,
})

-- [[ 3. PERFORMANCE: Big File Defensive Interceptor ]]
-- Detects files over a specific threshold (2MB) and strips away intensive
-- features like Treesitter and LSP to keep the editor responsive.
vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Disable expensive features for large files',
  group = external_group,
  pattern = '*',
  callback = function(ev)
    local max_filesize = 2 * 1024 * 1024 -- 2MB Threshold
    -- PERFORMANCE: Use native Libuv fs_stat (asynchronous-capable)
    local ok, stats = pcall(vim.uv.fs_stat, ev.match)

    if ok and stats and stats.size > max_filesize then
      -- Set a buffer-local flag for other plugins (like indent-blankline) to respect
      vim.b.bigfile = true

      -- SURGICAL DEGRADATION:
      -- 1. Kill Syntax Highlighting (Regex and Treesitter)
      -- 2. Stop the LSP (Prevents indexing 2MB+ of raw text)
      -- 3. Disable swap and undo-reload to save disk I/O and memory
      vim.cmd('syntax off')
      vim.cmd('LspStop')
      vim.opt_local.undoreload = 0
      vim.opt_local.swapfile = false

      local size_mb = math.floor(stats.size / 1024 / 1024)
      local extension = vim.fn.fnamemodify(ev.match, ':e')

      if extension == 'json' then
        vim.notify(
          string.format("⚠️ Big JSON Detected (%sMB).\nPerformance will degrade. Use :Jless for large datasets.", size_mb),
          vim.log.levels.WARN,
          { title = "Resource Guard" }
        )
      else
        vim.notify(
          string.format("🚀 Big File Mode: Optimized for %sMB file (Syntax/LSP OFF).", size_mb),
          vim.log.levels.INFO
        )
      end
    end
  end,
})

-- THE CONTRACT: Return the module to satisfy the Orchestrator's pcall.
return M
