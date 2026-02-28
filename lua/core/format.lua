-- [[ NATIVE FORMATTING BRIDGE ]]
-- Domain: Buffer Transformation & Standardization
--
-- PHILOSOPHY: Direct-to-Metal Execution
-- This module implements a zero-dependency formatting architecture. By
-- bypassing intermediate abstraction layers (conform, null-ls), we reduce
-- latency and eliminate "plugin-creep." It leverages the Neovim 0.10+
-- vim.system API for high-performance, synchronous CLI filtering.

local utils = require 'core.utils'

local M = {}

--- Toolchain Registry: Maps filetypes to mise-managed CLI binaries.
--- is_filter: Set to false if the tool modifies the file on disk instead of stdout.
local formatters = {
  lua = {
    bin = 'stylua',
    args = { '-', '--search-parent-directories', '--stdin-filepath', '$FILENAME' },
    is_filter = true,
  },
  javascript = {
    bin = 'oxfmt',
    args = { '-', '--stdin-filename', '$FILENAME' },
    is_filter = true,
  },
  typescript = {
    bin = 'oxfmt',
    args = { '-', '--stdin-filename', '$FILENAME' },
    is_filter = true,
  },
  markdown = {
    bin = 'markdownlint-cli2',
    args = { '--fix', '$FILENAME' },
    is_filter = false,
  },
  fish = {
    bin = 'fish_indent',
    args = {},
    is_filter = true,
  },
  python = {
    bin = 'ruff',
    args = { 'format', '-', '--stdin-filename', '$FILENAME' },
    is_filter = true,
  },
}

--- Captures the current window state (cursor, scroll, folds).
--- This is used to maintain visual continuity across destructive buffer edits.
local function get_view_state()
  return vim.fn.winsaveview()
end

--- Restores the window state with type-safety checks.
--- @param view table|nil The view dictionary returned by winsaveview.
local function restore_view_state(view)
  if view and type(view) == 'table' then
    vim.fn.winrestview(view)
  end
end

--- Internal execution engine for CLI-based formatting.
--- @param ft string The filetype for configuration lookup.
local function format_with_cli(ft)
  local config = formatters[ft]
  if not config then
    return
  end

  local bin_path = utils.mise_shim(config.bin)
  if not bin_path then
    -- Graceful degradation: Log but don't disrupt the save loop.
    return
  end

  local filename = vim.api.nvim_buf_get_name(0)
  local args = {}
  for _, arg in ipairs(config.args) do
    table.insert(args, (arg:gsub('$FILENAME', filename)))
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, '\n')

  -- Execute synchronously to ensure the write happens AFTER the format.
  local result = vim.system({ bin_path, unpack(args) }, { stdin = input, text = true }):wait()

  if result.code == 0 then
    if config.is_filter then
      local output_lines = vim.split(result.stdout, '\n', { trimempty = true })

      local view = get_view_state()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, output_lines)
      restore_view_state(view)
    end
  else
    utils.soft_notify('Format Failure (' .. config.bin .. '): ' .. (result.stderr or 'Error'), vim.log.levels.WARN)
  end
end

--- Main entry point for formatting orchestration.
--- Prioritizes LSP capabilities with a CLI fallback mechanism.
function M.autoformat()
  local ft = vim.bo.filetype
  local view = get_view_state()

  -- 1. LSP Formatting (Highest Priority)
  local lsp_clients = vim.lsp.get_clients { bufnr = 0, method = 'textDocument/formatting' }
  if #lsp_clients > 0 then
    vim.lsp.buf.format { async = false, timeout_ms = 1000 }
  else
    -- 2. CLI Formatting (Mise Fallback)
    format_with_cli(ft)
  end

  -- 3. Global Hygiene: Trim trailing whitespace (Excluded for formatting-sensitive types)
  local excluded_hygiene = { 'markdown', 'markdown.mdx', 'diff', 'mail' }
  if not vim.tbl_contains(excluded_hygiene, ft) then
    local cursor_view = get_view_state()
    vim.cmd [[keepjumps keeppatterns silent! %s/\s\+$//e]]
    restore_view_state(cursor_view)
  end

  -- Final visual anchor restoration
  restore_view_state(view)
end

-- [[ AUTOMATED ORCHESTRATION ]]

local group = vim.api.nvim_create_augroup('NativeFormatGroup', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  pattern = '*',
  callback = function()
    M.autoformat()
  end,
  desc = 'Synchronous buffer transformation prior to disk write',
})

vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  M.autoformat()
end, { desc = 'Code: [F]ormat Buffer (Native)' })

return M
