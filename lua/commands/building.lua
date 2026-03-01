-- [[ BUILDING & EXECUTION DOMAIN ]]
-- Modularized logic for offloading heavy compilation and execution tasks to Zellij.
-- PRINCIPLE: Neovim handles the text; Zellij handles the process.

local M = {}

--- Helper: Find the project root based on common markers.
--- This allows the runner to determine if it should use 'go run main.go' or 'go run .'.
--- @return string|nil The absolute path to the project root or nil.
local function get_project_root()
  local markers = { 'go.mod', 'build.zig', 'Makefile', 'pyproject.toml', '.git' }
  local root = vim.fs.find(markers, { upward = true, stop = vim.env.HOME })[1]
  if root then
    return vim.fs.dirname(root)
  end
  return nil
end

-- [[ Watchexec Continuous Daemon ]]
-- Pipes commands to a side-pane in Zellij and re-runs them on file save.
vim.api.nvim_create_user_command('Watch', function(opts)
  local utils = require('core.utils')
  local watchexec = utils.mise_shim('watchexec')
  if not watchexec then
    utils.soft_notify("watchexec not found. Install via mise.", vim.log.levels.ERROR)
    return
  end

  if opts.args == '' then
    utils.soft_notify('Usage: :Watch <command>', vim.log.levels.WARN)
    return
  end

  -- SYMBOL EXPANSION: Convert '%' into the absolute path of the current file.
  local cmd_args = opts.args
  if cmd_args:match("%%") then
    local current_file = vim.fn.expand('%:p')
    if current_file == "" then
      utils.soft_notify('No file open to expand %', vim.log.levels.WARN)
      return
    end
    cmd_args = cmd_args:gsub("%%", vim.fn.shellescape(current_file))
  end

  -- ASYNCHRONOUS HANDOFF:
  -- We use Zellij's 'run' action to create a new pane.
  -- The '-c' flag in watchexec clears the terminal on every re-run for clarity.
  local zellij_cmd = string.format("zellij action new-pane -d right -- %s -c -- %s", watchexec, cmd_args)

  vim.fn.system(zellij_cmd)
  vim.notify("Watcher Active: " .. cmd_args, vim.log.levels.INFO)
end, { nargs = '+', desc = 'Run command continuously in Zellij via watchexec' })

-- [[ The Anti-Fragile Smart Runner ]]
-- A shared logic engine for both 'Watch' (continuous) and 'Run' (single execution).
-- @param is_continuous boolean Whether to wrap the command in watchexec.
local function execute_smart_build(is_continuous)
  local ft = vim.bo.filetype
  local file = vim.fn.expand('%:p')
  local root = get_project_root()
  local cmd = ""

  -- 1. PYTHON: Modern 'uv' integration.
  if ft == "python" then
    cmd = string.format("uv run %s", vim.fn.shellescape(file))

  -- 2. GO: Workspace awareness.
  elseif ft == "go" then
    -- If we found a go.mod, run the entire module; otherwise run the file.
    local has_mod = root and vim.fn.filereadable(root .. "/go.mod") == 1
    cmd = has_mod and "go run ." or string.format("go run %s", vim.fn.shellescape(file))

  -- 3. ZIG: Build-system awareness.
  elseif ft == "zig" then
    -- Prefer 'zig build run' if a build file exists.
    local has_build = root and vim.fn.filereadable(root .. "/build.zig") == 1
    cmd = has_build and "zig build run" or string.format("zig run %s", vim.fn.shellescape(file))

  -- 4. C / C++: Makefile fallback.
  elseif ft == "c" or ft == "cpp" then
    if root and vim.fn.filereadable(root .. "/Makefile") == 1 then
      cmd = "make"
    else
      local compiler = (ft == "cpp") and "g++" or "gcc"
      local output = vim.fn.expand('%:r')
      -- We wrap compound commands in a shell string so the muxer doesn't break.
      cmd = string.format([[bash -c "%s %s -o %s && ./%s"]], compiler, vim.fn.shellescape(file), output, output)
    end

  -- 5. LUA: Native Neovim runner.
  elseif ft == "lua" then
    cmd = string.format("nvim -l %s", vim.fn.shellescape(file))

  else
    vim.notify("No smart runner for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  -- FINAL DISPATCH
  if is_continuous then
    vim.cmd("Watch " .. cmd)
  else
    local zellij_cmd = string.format("zellij action new-pane -d right -- %s", cmd)
    vim.fn.system(zellij_cmd)
    vim.notify("Executing: " .. cmd, vim.log.levels.INFO)
  end
end

-- [[ Keymaps: The Entry Points ]]

-- Continuous "Dev Mode" (Leader-C-X for Execute)
vim.keymap.set('n', '<leader>cx', function() execute_smart_build(true) end, 
  { desc = "[C]ode e[X]ecute (Continuous Watch)" })

-- Single "Production Run" (Leader-C-R for Run)
vim.keymap.set('n', '<leader>cr', function() execute_smart_build(false) end, 
  { desc = "[C]ode [R]un (Single Interactive)" })

-- Manual Watch trigger
vim.keymap.set('n', '<leader>vw', '<cmd>Watch ', { desc = '[V]iew [W]atchexec (Manual)' })

vim.api.nvim_create_user_command('Watchexec', function(opts)
  local utils = require('core.utils')
  local we_bin = utils.mise_shim('watchexec')
  if not we_bin then
    utils.soft_notify('watchexec binary not found.', vim.log.levels.WARN)
    return
  end
  local cmd_to_run = vim.fn.input('Run with watchexec: ')
  if cmd_to_run ~= '' then
    require('commands.mux').zellij_run(we_bin .. ' -- ' .. cmd_to_run)
  end
end, { nargs = '?', complete = 'shellcmd' })

return M
