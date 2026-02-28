-- [[ DAP: Debug Adapter Protocol + PlatformIO ]]
-- Domain: Hardware Debugging & Execution Control
--
-- PHILOSOPHY: Action-Triggered Instrumentation
-- The debugger is a heavy subsystem. We keep it completely dormant 
-- until the moment you set a breakpoint or initiate a session. 

local M = {}
local utils = require('core.utils')

-- [[ THE SHARED BOOTSTRAP ]]
-- This is a PUBLIC function. Other DAP-dependent plugins (Virtual Text,
-- Persistent Breakpoints) call this to ensure the core DAP library is 
-- downloaded and added to the runtime path before they try to use it.
M.bootstrap = function()
  local ok, _ = pcall(require, 'dap')
  if ok then return true end

  -- If require failed, the plugin is either not installed or not in RTP.
  -- We add it via mini.deps and force-load it into the runtime.
  local MiniDeps = require('mini.deps')
  MiniDeps.add('mfussenegger/nvim-dap')
  vim.cmd('packadd nvim-dap')
  
  -- Return the result of the second attempt
  return pcall(require, 'dap')
end

local loaded = false

-- [[ THE JIT ENGINE ]]
-- Handles the full setup of the DAP suite, including UI and Adapters.
local function bootstrap_full_dap()
  if loaded then return true end

  -- Step 1: Ensure the core library is available
  if not M.bootstrap() then
    utils.soft_notify('Failed to bootstrap core DAP library.', vim.log.levels.ERROR)
    return false
  end

  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')
    
    -- 1. Infrastructure: UI and Async Support
    MiniDeps.add('rcarriga/nvim-dap-ui')
    MiniDeps.add('nvim-neotest/nvim-nio') 

    local dap = require('dap')
    local dapui = require('dapui')

    -- 2. UI Automation
    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

    -- 3. Hardware Adapter Configuration (LLDB)
    dap.adapters.lldb = {
      type = 'executable',
      command = utils.mise_shim('lldb-dap') or 'lldb-dap',
      name = 'lldb',
    }

    -- 4. PlatformIO Specific Targets
    dap.configurations.cpp = {
      {
        name = "PlatformIO: Hardware Debug (LLDB/OpenOCD)",
        type = "lldb",
        request = "launch",
        program = function()
          local pio_path = vim.fn.getcwd() .. '/.pio/build/'
          local executable = vim.fn.glob(pio_path .. '*/firmware.elf')
          return executable ~= "" and executable or vim.fn.input('Path to .elf: ', pio_path, 'file')
        end,
        initCommands = { "gdb-remote localhost:3333" },
        postRunCommands = { 
          "process plugin packet monitor reset halt", 
          "target modules load --all" 
        },
      },
    }
    dap.configurations.c = dap.configurations.cpp
  end)

  if not ok then
    utils.soft_notify('DAP Infrastructure failure: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAPS ]]
local dap_actions = {
  { '<leader>db', 'toggle_breakpoint', 'Toggle Breakpoint' },
  { '<leader>dc', 'continue',          'Start/Continue Debugging' },
  { '<leader>do', 'step_over',         'Step Over' },
  { '<leader>di', 'step_into',         'Step Into' },
  { '<leader>dr', 'repl.toggle',       'Toggle REPL' },
}

for _, action in ipairs(dap_actions) do
  vim.keymap.set('n', action[1], function()
    if bootstrap_full_dap() then
      local parts = vim.split(action[2], "%.")
      local target = require('dap')
      for i=1, #parts do target = target[parts[i]] end
      target()
    end
  end, { desc = 'Debug: ' .. action[3] })
end

-- FIX: Changed bootstrap_vbg() to bootstrap_full_dap()
vim.keymap.set('n', '<leader>du', function()
  if bootstrap_full_dap() then 
    require('dapui').toggle() 
  end
end, { desc = 'Debug: Toggle UI Layout' })

return M