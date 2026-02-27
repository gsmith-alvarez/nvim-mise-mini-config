--- [[ Telescope: Fuzzy Finder ]]
--- The primary interface for searching files, text, LSP symbols, and more.

--[[
EXECUTION STRATEGY: Deferred loading via JIT keymap stubs.
- Telescope is a complex plugin with many dependencies. Loading it at boot
  is a significant performance hit.
- We create stubs for every Telescope keymap.
- The first time ANY stub is pressed, a loader function is called which:
  1. Adds Telescope and all its dependencies (`plenary`, `fzf-native`, etc.).
  2. Configures Telescope and all its extensions.
  3. HOTSWAPS ALL STUBS to be direct calls to Telescope's functions.
- This ensures the first action is slightly delayed, but every subsequent
  action across the entire Telescope suite is instantaneous.
--]]

local loaded = false

-- The core loader and hotswapper function.
local function load_and_hotswap_telescope()
  if loaded then return true end
  
  local MiniDeps = require('mini.deps')
  MiniDeps.add('nvim-telescope/telescope.nvim')
  -- Conditional add for fzf-native, only if `make` is executable
  if vim.fn.executable('make') == 1 then
    MiniDeps.add({
      source = 'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    })
  end
  MiniDeps.add('nvim-telescope/telescope-ui-select.nvim')
  MiniDeps.add('jvgrootveld/telescope-zoxide')

  -- Force load so modules are available
  -- ASYMMETRIC LEVERAGE: This crucial step makes plugin commands/modules available
  -- without restarting Neovim, essential for JIT loading.
  vim.cmd('packadd telescope.nvim')
  
  local telescope = require('telescope')
  local builtin = require('telescope.builtin') -- Moved inside to prevent crash
  
  telescope.setup({
    pickers = {
      find_files = {
        -- This matches your shell script: fd --type f --hidden --exclude .git
        find_command = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' },
      },
    },
    extensions = {
      ['ui-select'] = {
        -- Use the dropdown theme for the ui-select extension
        require('telescope.themes').get_dropdown(),
      },
      zoxide = {
        prompt_title = '[ Zoxide Directories ]',
        -- Inject the custom previewer from original config
        previewer = require('telescope.previewers').new_termopen_previewer({
          get_command = function(entry)
            local path = entry.path or entry.value
            if vim.fn.isdirectory(path) == 1 then
              return { 'eza', '--tree', '--level=2', '--icons', '--git', '--color=always', path }
            end
            return { 'bat', '--style=numbers', '--color=always', path }
          end,
        }),
        mappings = {
          default = {
            action = function(selection)
              -- Crucial Requirement: Change global working directory immediately.
              vim.cmd.cd(selection.path)
            end,
            after_action = function(s) vim.notify('Global directory changed to: ' .. s.path) end,
          },
        },
      },
    },
  })
  
  pcall(telescope.load_extension, 'fzf')
  pcall(telescope.load_extension, 'ui-select')
  pcall(telescope.load_extension, 'zoxide')

  loaded = true
  return true
end

-- Keymap Stubs (registered at boot)
local telescope_keys = {
  { 'n', '<leader>cd', function() require('telescope').extensions.zoxide.list() end, '[C]hange [D]irectory (Zoxide)' },
  { 'n', '<leader>ff', 'find_files', '[F]ind [F]iles (Telescope)' },
  { 'n', '<leader>fr', 'oldfiles', '[F]ind [R]ecent Files (Telescope)' },
  { 'n', '<leader>fb', 'buffers', '[F]ind [B]uffers (Telescope)' },
  { 'n', '<leader>sg', 'live_grep', '[S]earch by [G]rep (Telescope)' },
  { 'n', '<leader>sw', 'grep_string', '[S]earch current [W]ord (Telescope)' },
  { 'n', '<leader>sd', 'diagnostics', '[S]earch [D]iagnostics (Telescope)' },
  { 'n', '<leader>sr', 'resume', '[S]earch [R]esume (Telescope)' },
  { 'n', '<leader>sl', function() require('telescope.builtin').current_buffer_fuzzy_find() end, '[S]earch Line in Files (Telescope)' },
  { 'n', '<leader>uh', 'help_tags', '[H]elp Tags (Telescope)' },
  { 'n', '<leader>uk', 'keymaps', '[K]eymaps (Telescope)' },
}

for _, k in ipairs(telescope_keys) do
  vim.keymap.set(k[1], k[2], function()
    load_and_hotswap_telescope()
    if type(k[3]) == 'string' then
      require('telescope.builtin')[k[3]]()
    else
      k[3]()
    end
    -- HOTSWAP: Overwrite the keymap for direct execution on subsequent calls.
    vim.keymap.set(k[1], k[2], k[3], { desc = k[4] })
  end, { desc = k[4] .. ' (loads on first use)' })
end
