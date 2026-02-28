-- [[ TELESCOPE: Unified Search & Discovery Engine ]]
-- Domain: Search & Navigation
--
-- PHILOSOPHY: Action-Driven JIT Loading
-- Telescope is a heavy, multi-dependency system. We register all keymaps
-- at boot as lightweight Lua proxies. The heavy binaries and Lua modules
-- only enter memory the exact millisecond you initiate a search.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ THE JIT ENGINE ]]
M.bootstrap = function()  if loaded then return true end

  local ok, err = pcall(function()
    local MiniDeps = require('mini.deps')

    -- 1. Infrastructure Registration
    -- CRITICAL FIX: We must explicitly declare plenary, or a fresh boot will crash.
    MiniDeps.add('nvim-lua/plenary.nvim')
    MiniDeps.add('nvim-telescope/telescope.nvim')

    -- FZF Native: Provides O(n) C-based fuzzy matching performance.
    if vim.fn.executable('make') == 1 then
      MiniDeps.add({
        source = 'nvim-telescope/telescope-fzf-native.nvim',
        -- ARCHITECT'S FIX: Translated lazy.nvim 'build' syntax to mini.deps hooks.
        hooks = {
          post_checkout = function()
            vim.fn.system('make')
          end
        }
      })
    end

    MiniDeps.add('nvim-telescope/telescope-ui-select.nvim')
    MiniDeps.add('jvgrootveld/telescope-zoxide')

    -- 2. Engine Configuration
    local telescope = require('telescope')

    telescope.setup({
      defaults = {
        file_icons = true,
        -- Optimize for large projects: ignore non-source binaries and git history
        file_ignore_patterns = { "node_modules", "%.git/", "%.o", "%.a" },
        mappings = {
          i = {
            ["<C-j>"] = require('telescope.actions').move_selection_next,
            ["<C-k>"] = require('telescope.actions').move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          -- We prioritize 'fd' via our mise_shim for maximum performance
          find_command = { utils.mise_shim('fd') or 'fd', '--type', 'f', '--strip-cwd-prefix' },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        zoxide = {
          prompt_title = '[ Zoxide Workspace ]',
          -- Unified UI: Use eza and bat for directory/file previews
          previewer = require('telescope.previewers').new_termopen_previewer({
            get_command = function(entry)
              local path = entry.path or entry.value
              if vim.fn.isdirectory(path) == 1 then
                return { 'eza', '--tree', '--level=2', '--icons', '--color=always', path }
              end
              return { 'bat', '--style=numbers', '--color=always', path }
            end,
          }),
        },
      },
    })

    -- 3. Extension Injection
    -- Protected calls ensure that if an extension's build step failed,
    -- core Telescope still operates perfectly.
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
    pcall(telescope.load_extension, 'zoxide')
  end)

  if not ok then
    utils.soft_notify('Telescope failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAPS ]]
-- The closure ensures 'bootstrap_telescope' only performs heavy lifting on the first call.
local search_keys = {
  { '<leader>cd', function() require('telescope').extensions.zoxide.list() end, 'Zoxide Directory' },
  { '<leader>ff', function() require('telescope.builtin').find_files() end,     'Find Files' },
  { '<leader>fr', function() require('telescope.builtin').oldfiles() end,       'Recent Files' },
  { '<leader>fb', function() require('telescope.builtin').buffers() end,         'Active Buffers' },
  { '<leader>sg', function() require('telescope.builtin').live_grep() end,       'Grep Project' },
  { '<leader>sw', function() require('telescope.builtin').grep_string() end,     'Grep Word Under Cursor' },
  { '<leader>sd', function() require('telescope.builtin').diagnostics() end,    'Search Diagnostics' },
  { '<leader>sr', function() require('telescope.builtin').resume() end,         'Resume Last Search' },
  { '<leader>sh', function() require('telescope.builtin').help_tags() end,      'Search Help' },
  { '<leader>sk', function() require('telescope.builtin').keymaps() end,        'Search Keymaps' },
}

for _, k in ipairs(search_keys) do
  vim.keymap.set('n', k[1], function()
    if M.bootstrap() then
      k[2]()
    end
  end, { desc = 'Search: ' .. k[3] .. ' (JIT)' })
end

-- THE CONTRACT: Return the module to satisfy the Finding Orchestrator
return M
