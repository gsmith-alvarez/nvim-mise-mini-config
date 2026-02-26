--- [[ Debug Adapter Protocol (DAP) + PlatformIO ]]
--- Provides a standard interface for debugging code, including PlatformIO hardware debug setup.

--[[
EXECUTION STRATEGY: Deferred loading via keymap stubs.
- The debugger is only needed during active debugging sessions.
- Keymap stubs for setting breakpoints and starting DAP are created at boot.
- The entire DAP suite is loaded on-demand the first time a stub is triggered.
--]]

local loaded = false

local function load_dap()
  if loaded then return end
  local MiniDeps = require('mini.deps')
  MiniDeps.add('mfussenegger/nvim-dap')
  MiniDeps.add('rcarriga/nvim-dap-ui')
  MiniDeps.add('nvim-neotest/nvim-nio') -- A dependency for nvim-dap-ui

  -- Force load so modules are available
  vim.cmd('packadd nvim-dap')
  vim.cmd('packadd nvim-dap-ui')
  
  local dap = require('dap')
  local dapui = require('dapui')
  dapui.setup()

  -- Restoring your LLDB / PlatformIO Adapter
  dap.adapters.lldb = {
    type = 'executable',
    command = require('core.utils').mise_shim('lldb-dap') or 'lldb-dap',
    name = 'lldb',
  }

  dap.configurations.cpp = {
    {
      name = "PlatformIO: Hardware Debug (LLDB/OpenOCD)",
      type = "lldb",
      request = "launch",
      program = function() return vim.fn.input('Path to .elf: ', vim.fn.getcwd() .. '/.pio/build/', 'file') end,
      initCommands = { "gdb-remote localhost:3333" },
      postRunCommands = { "process plugin packet monitor reset halt", "target modules load --all" },
    },
  }
  dap.configurations.c = dap.configurations.cpp

  loaded = true
end

-- Breakpoint stub is ALWAYS available
vim.keymap.set('n', '<leader>b', function()
  load_dap()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })

-- F5 Continue stub
vim.keymap.set('n', '<F5>', function()
  load_dap()
  require('dap').continue()
end, { desc = 'Debug: Start/Continue' })

-- Add keymaps for DAP UI (assuming these are desired)
vim.keymap.set('n', '<leader>du', function()
  load_dap()
  require('dapui').toggle()
end, { desc = 'Debug: Toggle UI' })

vim.keymap.set('n', '<leader>dr', function()
  load_dap()
  require('dap').repl.toggle()
end, { desc = 'Debug: Toggle REPL' })
