--- [[ vim-be-good: Vim Motion Training ]]
--- A plugin for practicing Vim motions and improving editing speed.

--[[
EXECUTION STRATEGY: Deferred loading via command stub.
- A user command `:VimBeGood` is created at startup.
- The plugin is not loaded into memory at boot.
- The first time `:VimBeGood` is run, the stub function executes:
  1. It adds `ThePrimeagen/vim-be-good` via MiniDeps.
  2. It *forces* the plugin to load into Neovim's runtime via `packadd`.
  3. It deletes the stub command.
  4. It re-runs `:VimBeGood`, which now triggers the plugin's native command.
- Subsequent calls to `:VimBeGood` are instantaneous.
--]]

local loaded = false

local function load_vbg_native()
  if loaded then return end
  require('mini.deps').add('ThePrimeagen/vim-be-good')
  -- Force load: Ensure plugin modules are in Neovim's runtimepath immediately.
  vim.cmd('packadd vim-be-good')
  loaded = true
end

-- Define the initial stub command.
vim.api.nvim_create_user_command('VimBeGood', function()
  load_vbg_native()
  -- After loading, the plugin's native `:VimBeGood` command should be available.
  vim.cmd('VimBeGood')
  -- HOTSWAP: Redefine the user command to directly call the native plugin command.
  vim.api.nvim_create_user_command('VimBeGood', '<cmd>VimBeGood<CR>', { desc = 'Practice Vim motions' })
end, { desc = 'Practice Vim motions (loads on first use)' })
