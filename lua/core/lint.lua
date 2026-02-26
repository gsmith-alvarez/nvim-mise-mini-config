--- [[ Native Diagnostic Bridge ]]
--- This module implements a Native-First diagnostic architecture using
--- vim.system (async) and vim.diagnostic.set.
---
--- It bypasses nvim-lint entirely by executing linters in the background
--- and parsing their output into standard Neovim diagnostics. No blocking,
--- no middleman.

local utils = require('core.utils')

local M = {}

--- Namespace for our native linter bridge.
local ns = vim.api.nvim_create_namespace('native-lint')

--- Map filetypes to their respective CLI linters and their parsing logic.
local linters = {
  sh = {
    bin = 'shellcheck',
    -- Note: We use -f json for easier, non-fragile parsing.
    args = { '-f', 'json', '$FILENAME' },
    parser = function(output)
      local diagnostics = {}
      local ok, data = pcall(vim.json.decode, output)
      if ok and data then
        for _, entry in ipairs(data) do
          table.insert(diagnostics, {
            lnum = entry.line - 1,
            col = entry.column - 1,
            end_lnum = entry.endLine - 1,
            end_col = entry.endColumn - 1,
            severity = entry.level == 'error' and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            message = entry.message,
            source = 'shellcheck',
          })
        end
      end
      return diagnostics
    end,
  },
  markdown = {
    bin = 'markdownlint-cli2',
    -- Note: markdownlint-cli2 doesn't always support JSON output natively without
    -- external tools. We'll use its default output format and parse it via regex.
    args = { '$FILENAME' },
    parser = function(output)
      local diagnostics = {}
      -- CORRECTION: Safely iterate over lines using Neovim's native split API
      -- instead of a brittle/broken gmatch string.
      for _, line in ipairs(vim.split(output, '\n', { trimempty = true })) do
        -- Format: filename:line:column MDXXX/message
        local lnum, col, msg = line:match(':(%d+):(%d+)%s+(.*)')
        if lnum and col then
          table.insert(diagnostics, {
            lnum = tonumber(lnum) - 1,
            col = tonumber(col) - 1,
            severity = vim.diagnostic.severity.WARN,
            message = msg,
            source = 'markdownlint',
          })
        end
      end
      return diagnostics
    end,
  },
}

--- Orchestrates an asynchronous linting run.
--- @param bufnr integer The buffer number to lint.
function M.lint(bufnr)
  local ft = vim.bo[bufnr].filetype
  local config = linters[ft]
  if not config then return end

  local bin_path = utils.mise_shim(config.bin)
  if not bin_path then return end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local args = {}
  for _, arg in ipairs(config.args) do
    table.insert(args, arg:gsub('$FILENAME', filename))
  end

  -- EXECUTION: Run the linter asynchronously.
  -- This ensures that the UI remains completely fluid while we wait for results.
  vim.system({ bin_path, unpack(args) }, { text = true }, function(obj)
    local stdout = obj.stdout or ''
    local stderr = obj.stderr or ''
    local output = stdout ~= '' and stdout or stderr

    -- Inject diagnostics back into the Neovim event loop.
    -- This is essential because vim.diagnostic.set must be called on the main thread.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      local diagnostics = config.parser(output)
      vim.diagnostic.set(ns, bufnr, diagnostics)
    end)
  end)
end

-- [[ Automated Orchestration ]]
-- Hook into the Neovim event loop directly on BufWritePost.
-- This ensures that linting only runs when the file is on disk and stable.
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('native-lint', { clear = true }),
  callback = function(args)
    M.lint(args.buf)
  end,
  desc = 'Asynchronously lint buffer on save using native APIs',
})

return M
