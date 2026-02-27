--- [[ Harpoon: Stateful File Navigation ]]
--- Provides a structured way to mark and jump between important files.

--[[
EXECUTION STRATEGY: Deferred loading via keymap stubs.
- `harpoon`'s functionality is only needed when explicitly triggered.
- We create keymap stubs for its core functions.
- The plugin is only downloaded and configured the first time one of
  its keymaps is pressed. The stub then "hotswaps" itself to be a
  direct call for all subsequent uses.
--]]

local loaded = false
local function load_harpoon()
  if loaded then return true end
  require('mini.deps').add('ThePrimeagen/harpoon')
  -- Force load so modules are available
  vim.cmd('packadd harpoon')

  require('harpoon').setup()
  loaded = true
  return true
end

-- Stub for adding a file
vim.keymap.set('n', '<M-a>', function()
  load_harpoon()
  require('harpoon.mark').add_file()
  vim.notify('Harpoon: Marked file', vim.log.levels.INFO)
  -- Hotswap
  vim.keymap.set('n', '<M-a>',
    function()
      require('harpoon.mark').add_file()
      vim.notify('Harpoon: Marked file', vim.log.levels.INFO)
    end, { desc = 'Harpoon: Mark file' })
end, { desc = 'Harpoon: Mark file (loads on first use)' })

-- Stub for the UI toggle (now using Alt-e)
vim.keymap.set('n', '<M-e>', function()
  load_harpoon()
  require('harpoon.ui').toggle_quick_menu()
  -- Hotswap
  vim.keymap.set('n', '<M-e>', function() require('harpoon.ui').toggle_quick_menu() end,
    { desc = 'Harpoon: Toggle UI' })
end, { desc = 'Harpoon: Toggle UI (loads on first use)' })

-- [[ Harpoon: Hotswapped Ctrl-Number Navigation ]]
-- We use Alt (Meta) for instant jumping.

for i = 1, 4 do
  local map_key = '<M-' .. i .. '>'
  vim.keymap.set('n', map_key, function()
    load_harpoon()
    require('harpoon.ui').nav_file(i)

    -- HOTSWAP: Overwrite all stubs with direct calls
    for j = 1, 4 do
      vim.keymap.set('n', '<M-' .. j .. '>', function()
        require('harpoon.ui').nav_file(j)
      end, { desc = 'Harpoon: Go to mark ' .. j })
    end
  end, { desc = 'Harpoon: Go to mark ' .. i .. ' (loads on first use)' })
end

-- Force Multiplier: Clear all marks
vim.keymap.set('n', '<leader>H', function()
  load_harpoon()
  require('harpoon.mark').clear_all()
  vim.notify('Harpoon: All marks cleared.', vim.log.levels.INFO)
  -- Hotswap
  vim.keymap.set('n', '<leader>H',
    function()
      require('harpoon.mark').clear_all()
      vim.notify('Harpoon: All marks cleared.', vim.log.levels.INFO)
    end, { desc = 'Harpoon: Clear all marks' })
end, { desc = 'Harpoon: Clear all marks (loads on first use)' })
