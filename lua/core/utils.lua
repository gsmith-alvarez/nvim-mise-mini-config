--- [[ Core Utility Functions ]]
--- This file contains shared utility functions used across the Neovim configuration.
--- It prioritizes performance, reliability, and integration with external tools like mise.

local M = {}

-- 1. DEFINE THE AUDIT TRAIL
-- We use Neovim's 'state' directory (~/.local/state/nvim/ on Unix).
-- This complies with the XDG Base Directory specification, keeping your logs
-- out of your clean config folder and away from your cache.
local log_path = vim.fn.stdpath('state') .. '/config_diagnostics.log'

--- Resolves Neovim log levels to human-readable strings for the log file.
local log_level_to_string = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO]  = "INFO",
  [vim.log.levels.WARN]  = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
  [vim.log.levels.OFF]   = "OFF",
}

--- Appends a message to the dedicated configuration log file.
--- @param msg string The message to log.
--- @param level integer The log level.
local function log_to_file(msg, level)
  -- Open the file in "a" (append) mode.
  -- This creates the file if it doesn't exist and preserves existing history.
  local file = io.open(log_path, "a")
  if file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local level_str = log_level_to_string[level] or "UNKNOWN"

    -- Format: [2026-02-28 03:27:53] [WARN] LSP missing: clangd
    file:write(string.format("[%s] [%s] %s\n", timestamp, level_str, msg))
    file:close()
  end
end

--- Checks if a binary is executable, prioritizing mise shims.
--- This is the core of our "Anti-Fragility" pillar.
--- @param binary string The name of the binary to find (e.g., 'rg', 'stylua').
--- @return string|nil path The absolute path to the binary if found, or nil if missing.
M.mise_shim = function(binary)
  -- 1. Check for the mise-specific shim path first.
  local path = vim.fn.expand('~/.local/share/mise/shims/' .. binary)
  if vim.fn.executable(path) == 1 then
    return path
  end

  -- 2. Fall back to the standard system PATH.
  if vim.fn.executable(binary) == 1 then
    return binary
  end

  -- 3. If neither exist, return nil.
  return nil
end

--- A wrapper for vim.notify that defaults to DEBUG level if not specified.
--- It immediately routes the message to both the UI and the persistent log file.
--- @param msg string The message to display.
--- @param level integer|nil The log level (e.g., vim.log.levels.WARN).
M.soft_notify = function(msg, level)
  local safe_level = level or vim.log.levels.DEBUG

  -- Route to the persistent audit trail
  log_to_file(msg, safe_level)

  -- Route to the UI (can be intercepted by plugins like Noice or Fidget later)
  vim.notify(msg, safe_level)
end

return M
