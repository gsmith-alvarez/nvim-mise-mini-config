--- [[ Yazi File Explorer Integration ]]
--- Implements a command stub for just-in-time loading of the yazi file explorer.

--[[
EXECUTION STRATEGY: Deferred loading via command stub (corrected).
- A user command `:Yazi` is created on startup.
- The `yazi.nvim` plugin is NOT loaded into memory at boot.
- The first time `:Yazi` is run, the stub function executes:
  1. It adds `mikavilpas/yazi.nvim`.
  2. It adds `stevearc/dressing.nvim` (optional dependency for better UI).
  3. It *forces* these plugins to load into Neovim's runtime via `packadd`.
  4. It configures `yazi.nvim` and `dressing.nvim`.
  5. It calls the *newly available native* `:Yazi` command.
  6. It then *redefines* the `:Yazi` user command to be a direct alias
     to the native plugin command for all subsequent calls, removing the stub logic.
- Subsequent calls to `:Yazi` are instantaneous and use the plugin's native command.
--]]

local loaded = false

local function load_and_run_yazi_native()
  if loaded then return end
  
  local MiniDeps = require('mini.deps')
  MiniDeps.add('mikavilpas/yazi.nvim')
  MiniDeps.add('stevearc/dressing.nvim')

  -- ASYMMETRIC LEVERAGE: Ensure plugins are loaded into runtimepath for commands
  -- This makes the native commands from the plugins available immediately.
  vim.cmd('packadd yazi.nvim')
  vim.cmd('packadd dressing.nvim') -- Also ensures dressing is loaded if needed

  require('yazi').setup()
  require('dressing').setup() -- Assuming dressing needs setup
  
  loaded = true
end

-- Define the initial stub command.
vim.api.nvim_create_user_command('Yazi', function(opts)
  -- Load and configure the plugin only once.
  load_and_run_yazi_native()

  -- After loading, the plugin's native `:Yazi` command should be available.
  -- We now call it directly.
  -- IMPORTANT: We pass opts.fargs and opts.bang to the native command if it supports them.
  local cmd_suffix = (opts.fargs and #opts.fargs > 0 and ' ' .. table.concat(opts.fargs, ' ')) or ''
  local bang_suffix = (opts.bang and '!') or ''
  vim.cmd('Yazi' .. bang_suffix .. cmd_suffix)

  -- HOTSWAP: Redefine the user command to directly call the native plugin command
  -- for all subsequent invocations. This removes the stub's overhead.
  vim.api.nvim_create_user_command('Yazi', function(new_opts)
    local new_cmd_suffix = (new_opts.fargs and #new_opts.fargs > 0 and ' ' .. table.concat(new_opts.fargs, ' ')) or ''
    local new_bang_suffix = (new_opts.bang and '!') or ''
    vim.cmd('Yazi' .. new_bang_suffix .. new_cmd_suffix)
  end, { desc = 'Open Yazi file manager', nargs = '*' , bang = true})

end, { desc = 'Open Yazi file manager (loads on first use)', nargs = '*' , bang = true})

-- Keymap to trigger the Yazi file manager.
vim.keymap.set('n', '<leader>y', '<cmd>Yazi<CR>', { desc = '🖼️ Yazi File Manager' })
