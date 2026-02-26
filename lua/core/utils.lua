--- [[ Core Utility Functions ]]
--- This file contains shared utility functions used across the Neovim configuration.
--- It prioritizes performance, reliability, and integration with external tools like mise.

local M = {}

--- Checks if a binary is executable, prioritizing mise shims.
--- This is the core of our "Anti-Fragility" pillar.
--- @param binary string The name of the binary to find (e.g., 'rg', 'stylua').
--- @return string|nil path The absolute path to the binary if found, or nil if missing.
M.mise_shim = function(binary)
  -- 1. Check for the mise-specific shim path first.
  -- Mise stores its managed tool shims in this specific directory.
  local path = vim.fn.expand('~/.local/share/mise/shims/' .. binary)
  if vim.fn.executable(path) == 1 then
    return path
  end

  -- 2. Fall back to the standard system PATH.
  -- This ensures that if a tool isn't managed by mise (like a system-level 'make'),
  -- Neovim can still find and use it.
  if vim.fn.executable(binary) == 1 then
    return binary
  end

  -- 3. If neither exist, return nil.
  -- This allows calling code to fail gracefully without throwing Lua errors.
  return nil
end

--- A wrapper for vim.notify that defaults to DEBUG level if not specified.
--- Useful for "soft" warnings about missing tools.
--- @param msg string The message to display.
--- @param level integer|nil The log level (e.g., vim.log.levels.WARN).
M.soft_notify = function(msg, level)
  vim.notify(msg, level or vim.log.levels.DEBUG)
end

return M
