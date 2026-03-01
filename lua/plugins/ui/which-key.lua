-- [[ WHICH-KEY: Discovery & Mnemonic Layer ]]
-- Domain: UI & Aesthetics
--
-- PHILOSOPHY: Asynchronous UI Attachment
-- Which-key provides a popup menu of available keybindings. Since it is purely 
-- visual, we completely remove it from the critical boot path. It is injected 
-- into the runtime only after Neovim triggers the 'VimEnter' event.

local M = {}
local utils = require('core.utils')

-- [[ DEFERRED BOOTSTRAPPER ]]
local group = vim.api.nvim_create_augroup('UI_WhichKey', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  pattern = '*',
  callback = function()
    -- 1. Safely resolve and configure the dependency
    local ok, err = pcall(function()
      require('mini.deps').add('folke/which-key.nvim')

      require('which-key').setup({
        preset = 'classic',
        
        -- UI Configuration
        win = { 
          border = 'single', 
          padding = { 1, 2 } 
        },
        
        icons = { 
          -- Respects global Nerd Font settings (defaults to true if undefined)
          mappings = vim.g.have_nerd_font ~= false,
        },

        -- [[ THE MNEMONIC REGISTRY ]]
        -- This maps prefixes to human-readable group names.
        -- Note: Individual key descriptions (like <leader>f for format) do NOT 
        -- need to be defined here if they are already defined in vim.keymap.set.
        -- Which-key automatically reads the 'desc' field from your native keymaps.
        spec = {
          -- Core Tool Groups
          { '<leader>c', group = '💻 Code' },
          { '<leader>d', group = '🐞 Debug' },
          { '<leader>D', group = '🔍 Diagnostics' },
          { '<leader>g', group = '📦 Git' },
          { '<leader>h', group = '⚓ Git Hunks', mode = { 'n', 'v' } },
          { '<leader>o', group = '📝 Notes' },
          { '<leader>O', group = '🏃 Overseer' },
          { '<leader>p', group = '🚀 PlatformIO' },
          { '<leader>q', group = '💾 Session' },
          { '<leader>r', group = '🛠️ Refactor' },
          { '<leader>s', group = '🔍 Search' },
          { '<leader>t', group = '⚙️ Toggles' },
          { '<leader>u', group = '🎨 UI Utils' },
          { '<leader>v', group = '👁️ View' },
          { '<leader>w', group = '🪟 Window' },
          { '<leader>z', group = '🧱 Zellij' },
          { '<leader>b', group = '󰓩 Buffers' },
          
          -- Diagnostics (under <leader>D)
          { '<leader>dL', desc = 'Toggle Virtual [L]ines' },
          { '<leader>dU', desc = 'Toggle [U]nderlines' },
          { '<leader>Dq', desc = '🗒️ [q]uickfix List' },

          -- Search (under <leader>s)
          { '<leader>sR', desc = 'Search & [R]eplace (SD)' },
          { '<leader>sr', desc = '[S]earch [R]esume' },

          -- Zellij (under <leader>z)
          { '<leader>zv', desc = 'Vertical Split' },
          { '<leader>zs', desc = 'Horizontal Split' },
          { '<leader>zf', desc = 'Floating Pane' },
          { '<leader>zq', desc = 'Close Pane' },

          -- View (under <leader>v)
          { '<leader>vq', desc = 'JQ: Live Scratchpad' },
          { '<leader>vx', desc = 'XH: HTTP Client' },
          { '<leader>vj', desc = 'JLess: JSON Viewer' },
          { '<leader>vw', desc = '[W]atchexec (Manual)' },

          -- Refactor (under <leader>r)
          { '<leader>rr', desc = 'Refactor: Select (UI)' }, -- Corrected from "Ring"

          -- Other standalone mappings (descriptions from vim.keymap.set are preferred)
          { '<leader>tm', desc = '📝 Markdown Preview' },
          { '<leader>ts', desc = '🎧 Spotify Player' },
          { '<leader>tp', desc = '📊 Process Monitor' },
          { '<leader>ta', desc = '🤖 Aider AI Chat' },
          { '<leader>ti', desc = '📦 Infrastructure (Podman)' },
          { '<leader>th', desc = '💡 LSP: Inlay Hints' },
          { '<leader>du', desc = 'Toggle DAP UI' },
          { '<leader>dr', desc = 'Toggle DAP REPL' },
          { '<leader>pb', desc = '[B]uild Project' },
          { '<leader>pu', desc = '[U]pload Firmware' },
          { '<leader>pm', desc = 'Device [M]onitor' },
          { '<leader>pc', desc = 'Update [C]ompilation Database' },
          { '<leader>re', desc = '[E]xtract Function' },
          { '<leader>rf', desc = 'Extract [F]unction to File' },
          { '<leader>rv', desc = 'Extract [V]ariable' },
          { '<leader>ri', desc = '[I]nline Variable' },
          { '<leader>ff', desc = '[F]ind [F]iles' },
          { '<leader>sh', desc = '[S]earch [H]elp' },
          { '<leader>sk', desc = '[S]earch [K]eymaps' },
          { '<leader>ss', desc = '[S]earch [S]elect Telescope' },
          { '<leader>sw', desc = '[S]earch current [W]ord' },
          { '<leader>sg', desc = '[S]earch by [G]rep' },
          { '<leader>sd', desc = '[S]earch [D]iagnostics' },
          { '<leader>sn', desc = '[S]earch [N]eovim files' },
          { '<leader><leader>', desc = '[ ] Find existing buffers' },
          { '<leader>cd', desc = '[C]hange [D]irectory (Zoxide)' },
          { '<leader>cx', desc = '󱓞 [C]ode [X]ecute (Watch Mode)' },
          { '<leader>cr', desc = '󰑮 [C]ode [R]un (Interactive)' },
          { '<leader>cf', desc = '✨ [C]ode [F]ormat Buffer' },
          { '<leader>y',  desc = '🖼️ Yazi File Manager' },
          { '<leader>ut', desc = 'Tools: Check Toolchain (Mise)' },
          { '<leader>xt', desc = 'Audit: Run Project [T]ypos' },
        },
      })
    end)

    if not ok then
      utils.soft_notify('Which-key failed to load: ' .. err, vim.log.levels.ERROR)
    end

    -- 2. Self-Destruct
    -- Clears the autocommand group so it never fires again during this session.
    vim.api.nvim_clear_autocmds({ group = 'UI_WhichKey' })
  end,
})

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M
