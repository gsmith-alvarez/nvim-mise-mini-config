--- [[ Which-key Discovery Layer ]]
--- Provides a popup menu of available keybindings after a prefix key.

--[[
EXECUTION STRATEGY: Deferred loading via `VimEnter` autocmd.
- `which-key.nvim` is a discovery tool, not a critical boot-path dependency.
- We defer its loading until Neovim is fully initialized and idle (`VimEnter`).
- This keeps the startup path extremely fast, as this plugin is only parsed
  and configured after you see the UI.
--]]

-- Create a one-shot autocommand group.
local group = vim.api.nvim_create_augroup('MiniDeps_WhichKey', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  pattern = '*',
  callback = function()
    -- The add() function is idempotent.
    require('mini.deps').add('folke/which-key.nvim')

    require('which-key').setup({
      preset = 'classic',
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      win = { border = 'single', padding = { 1, 2 } },
      spec = {
        -- [[ GROUP HEADERS ]]
        -- Strategic Use of Icons: These allow for "Asymmetric Visual Matching,"
        -- letting your brain find the tool before your eyes read the text.
        { '<leader>c', group = '💻 Code' },
        { '<leader>d', group = '🐞 Debug' },
        { '<leader>g', group = '📦 Git' },
        { '<leader>h', group = '⚓ Git Hunks', mode = { 'n', 'v' } }, -- Dedicated to Git Hunks
        { '<leader>p', group = '🚀 PlatformIO' },
        { '<leader>s', group = '🔍 Search' },
        { '<leader>x', group = '❌ Trouble' },
        { '<leader>u', group = '🎨 UI Utils' },

        -- [[ TOGGLES & DASHBOARD ]]
        { '<leader>tm', desc = '📝 Markdown Preview' },
        { '<leader>ts', desc = '🎧 Spotify Player' },
        { '<leader>tp', desc = '📊 Process Monitor' },
        { '<leader>ta', desc = '🤖 Aider AI Chat' },
        { '<leader>ti', desc = '📦 Infrastructure (Podman)' },
        { '<leader>th', desc = '💡 LSP: Inlay Hints' },

        -- [[ CODE & QUICKFIX ]]
        { '<leader>f', desc = '[F]ormat buffer' },
        { '<leader>q', desc = 'Open diagnostic [Q]uickfix list' },

        -- [[ DEBUGGING ]]
        { '<leader>b', desc = 'Toggle Breakpoint' },
        { '<leader>B', desc = 'Set Breakpoint (Conditional)' },
        { '<leader>du', desc = 'Toggle DAP UI' },
        { '<leader>dr', desc = 'Toggle DAP REPL' },

        -- [[ PLATFORMIO ACTIONS ]]
        { '<leader>pb', desc = '[B]uild Project' },
        { '<leader>pu', desc = '[U]pload Firmware' },
        { '<leader>pm', desc = 'Device [M]onitor' },
        { '<leader>pc', desc = 'Update [C]ompilation Database' },

        -- [[ REFACTORING ]]
        { '<leader>re', desc = '[E]xtract Function' },
        { '<leader>rf', desc = 'Extract [F]unction to File' },
        { '<leader>rv', desc = 'Extract [V]ariable' },
        { '<leader>ri', desc = '[I]nline Variable' },
        { '<leader>rr', desc = '[R]ing (Telescope)' },

        -- [[ SEARCH & NAVIGATION (TELESCOPE) ]]
        { '<leader>ff', desc = '[F]ind [F]iles' },
        { '<leader>sh', desc = '[S]earch [H]elp' },
        { '<leader>sk', desc = '[S]earch [K]eymaps' },
        { '<leader>ss', desc = '[S]earch [S]elect Telescope' },
        { '<leader>sw', desc = '[S]earch current [W]ord' },
        { '<leader>sg', desc = '[S]earch by [G]rep' },
        { '<leader>sd', desc = '[S]earch [D]iagnostics' },
        { '<leader>sr', desc = '[S]earch [R]esume' },
        { '<leader>s.', desc = '[S]earch Recent Files' },
        { '<leader>sn', desc = '[S]earch [N]eovim files' },
        { '<leader><leader>', desc = '[ ] Find existing buffers' },
        { '<leader>cd', desc = '[C]hange [D]irectory (Zoxide)' },
        
        -- [[ UI UTILITIES ]]
        { '<leader>y', desc = '🖼️ Yazi File Manager' }
      },
    })
    
    -- Self-destruct the autocommand.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_WhichKey' })
  end,
})
