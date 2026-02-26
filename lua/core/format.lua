--- [[ Native Formatting Bridge ]]
--- This module implements a Native-First formatting architecture using Neovim's
--- built-in APIs: BufWritePre, vim.system, and vim.lsp.buf.format.
---
--- It ruthlessly bypasses "middleman" plugins (conform.nvim) for direct CLI
--- and LSP control, ensuring maximum performance and zero abstraction overhead.

local utils = require('core.utils')

local M = {}

--- Map filetypes to their respective CLI formatters and their arguments.
--- This provides a single source of truth for our toolchain.
local formatters = {
  lua = {
    bin = 'stylua',
    args = { '-', '--search-parent', '--stdin-filepath', '$FILENAME' },
  },
  javascript = {
    bin = 'oxfmt',
    args = { '-', '--stdin-filename', '$FILENAME' },
  },
  typescript = {
    bin = 'oxfmt',
    args = { '-', '--stdin-filename', '$FILENAME' },
  },
  markdown = {
    bin = 'markdownlint-cli2',
    -- Note: markdownlint-cli2 --fix is usually file-based, but we call it
    -- directly on the filepath. It's not a true filter, but it works natively.
    args = { '--fix', '$FILENAME' },
    is_filter = false,
  },
  fish = {
    bin = 'fish_indent',
    args = { }, -- fish_indent acts as a pure stdin/stdout filter by default
  },
}

--- Executes a CLI formatter as a synchronous filter on the current buffer.
--- Safely restores cursor position and view state after full-buffer replacement.
--- @param ft string The filetype of the current buffer.
local function format_with_cli(ft)
  local config = formatters[ft]
  if not config then return end

  local bin_path = utils.mise_shim(config.bin)
  if not bin_path then
    utils.soft_notify('Formatter missing (graceful degradation): ' .. config.bin)
    return
  end

  local filename = vim.api.nvim_buf_get_name(0)
  local args = {}
  for _, arg in ipairs(config.args) do
    table.insert(args, arg:gsub('$FILENAME', filename))
  end

  -- We pull the entire buffer content as a string for stdin
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, '\n')

  -- EXECUTION: Use vim.system synchronously for BufWritePre.
  local result = vim.system({ bin_path, unpack(args) }, { stdin = input, text = true }):wait()

  if result.code == 0 then
    -- If it's a filter, replace buffer text with stdout.
    if config.is_filter ~= false then
      local output_lines = vim.split(result.stdout, '\n')
      -- Remove the last trailing newline from split if it exists
      if output_lines[#output_lines] == '' then table.remove(output_lines) end

      -- [[ ASYMMETRIC LEVERAGE: The State-Preservation Hack ]]
      -- 1. Save the current view (cursor position, folds, etc.)
      local saved_view = vim.fn.winsaveview()
      
      -- 2. Replace the buffer text
      vim.api.nvim_buf_set_lines(0, 0, -1, false, output_lines)
      
      -- 3. Restore the view exactly as it was
      vim.fn.winrestview(saved_view)
    end
  else
    utils.soft_notify('Formatting error (' .. config.bin .. '): ' .. (result.stderr or 'Unknown error'), vim.log.levels.ERROR)
  end
end

--- The main orchestration function for auto-formatting on save.
function M.autoformat()
  local ft = vim.bo.filetype

  -- 1. LSP First: If the language server supports formatting, use it.
  local clients = vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/formatting' })
  if #clients > 0 then
    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
    -- We only return if the LSP actually exists. 
    -- If you want CLI to ALWAYS run even with LSP, remove the return.
    return 
  end

  -- 2. CLI Fallback: If no LSP handles formatting, use our mise-backed CLI bridge.
  format_with_cli(ft)
end

-- [[ Automated Orchestration ]]
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('native-format', { clear = true }),
  callback = function()
    M.autoformat()
  end,
  desc = 'Synchronously format buffer on save using native APIs',
})

return M
