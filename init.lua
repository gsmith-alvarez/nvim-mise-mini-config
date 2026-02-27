--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||    (MODULARIZED)   ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is this configuration?

  This is a modularized version of Kickstart.nvim!

  Unlike the default Kickstart.nvim configuration which places almost
  everything into a single, massive `init.lua` file, this configuration
  has been broken down into smaller, manageable files. This makes it
  easier to navigate, maintain, and understand as your config grows!

  How is it structured?

  Your configuration is split into two main areas:

  1. `lua/core/`    - Contains your basic Neovim settings.
                      - `options.lua`: Editor behavior, tabs, UI, etc.
                      - `keymaps.lua`: Global keybindings.
                      - `autocmds.lua`: Automated tasks based on events.

  2. `lua/plugins/` - Contains all of your plugin configurations.
                      Each file here manages one plugin (or a group of
                      closely related plugins), keeping things tidy.

  The goal is STILL that you can read every line of code, understand
  what your configuration is doing, and modify it to suit your needs.

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example which will will only take 10-15 minutes:
    - https://learnxinyminutes.com/docs/lua/

  After understanding a bit more about Lua, you can use `:help lua-guide` as a
  reference for how Neovim integrates Lua.
  - :help lua-guide
  - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

  Next, run AND READ `:help`.
  MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation.

  I have left several `:help X` comments throughout the files.
  These are hints about where to find more information about the relevant settings.

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- [[ Modular Neovim Configuration Entry Point ]]
-- This is the very first file Neovim reads when it starts up.

-- Prepend mise shims to the PATH so Neovim finds them before system binaries
vim.env.PATH = vim.fn.expand '~/.local/share/mise/shims' .. ':' .. vim.env.PATH

-- Instead of putting everything here, we `require` (load) our modular files.

-- 1. Load Core Settings
require 'core.settings.options'
require 'core.settings.keymaps'
require 'core.settings.autocmds'
require 'core.settings.commands'
require 'core.format'
require 'core.lint'

-- [[ Bootstrap `mini.deps` ]]
-- We are not using a "plugin manager" in the traditional sense.
-- We are using a minimalist utility to fetch git repos.
local deps_path = vim.fn.stdpath 'data' .. '/mini.deps'
if not vim.loop.fs_stat(deps_path) then
  vim.fn.system { 'git', 'clone', 'https://github.com/echasnovski/mini.deps', deps_path }
end
vim.opt.rtp:prepend(deps_path)

-- [[ Imperative Plugin Loading ]]
-- Instead of a single declarative table, we now execute a series of Lua
-- modules that imperatively add and configure each plugin. The order of
-- execution is now explicit and under our direct control.
require('mini.deps').setup()

-- [[ GLOBAL FOUNDATION LAYER: Plenary.nvim ]]
-- CRITICAL: Plenary is a core utility library used by many plugins (Harpoon, Telescope, etc.).
-- It MUST be loaded globally and early to prevent cascading "module not found" errors.
require('mini.deps').add('nvim-lua/plenary.nvim')
vim.cmd('packadd plenary.nvim') -- Force load its modules into the runtimepath.

-- =============================================================================
-- PLUGIN CONFIGURATIONS
-- =============================================================================
-- For maintainability, plugin configurations are now organized into categories
-- based on their functionality, mirroring the structure in the README.

-- UI & Aesthetics
require 'plugins.ui' -- Main UI setup (Noice, Nui)
require 'plugins.ui.colors'
require 'plugins.ui.which-key'
require 'plugins.ui.treesitter'

-- Core LSP, Completion & Formatting
require 'plugins.lsp' -- Main LSP config
require 'plugins.lsp.completion'

-- Navigation & Core Editing
require 'plugins.editing.mini'
require 'plugins.editing.refactoring'
require 'plugins.editing.smart-splits'
require 'plugins.editing.tabout'
require 'plugins.editing.indent'

-- Telescope (Fuzzy Finding)
require 'plugins.finding.telescope'

-- Git Integration
require 'plugins.git.lazygit'

-- Pain-Driven Learning & Workflows
require 'plugins.workflow.vim-be-good'
require 'plugins.workflow.harpoon'
require 'plugins.workflow.toggleterm'
require 'plugins.workflow.yazi'

-- Debugging (DAP)
require 'plugins.dap.debug'

-- Notetaking
require 'plugins.notetaking.history'

-- ============================================================================
-- MODULE: JIT Entry Points (Obsidian & LuaSnip)
-- CONTEXT: Global stubs and autocmds that bootstrap heavy modules on demand.
-- ============================================================================

local map = vim.keymap.set

-- 1. THE AUTOCOMMAND ENTRY POINTS (Buffer Context)
local jit_group = vim.api.nvim_create_augroup("JIT_Notetaking", { clear = true })

-- Obsidian JIT
vim.api.nvim_create_autocmd("FileType", {
  group = jit_group,
  pattern = "markdown",
  callback = function()
    if not vim.g.obsidian_loaded then
      require("plugins.notetaking.obsidian").setup()
      vim.g.obsidian_loaded = true
    end
  end,
})

-- LuaSnip JIT
vim.api.nvim_create_autocmd("FileType", {
  group = jit_group,
  pattern = { "markdown", "tex" },
  callback = function()
    if not vim.g.luasnip_loaded then
      require("plugins.notetaking.luasnips").setup()
      vim.g.luasnip_loaded = true
    end
  end,
})

-- 2. THE GLOBAL STUB ENTRY POINTS (Cross-Workspace Context)
-- These allow you to search your vault while working in a Python or Rust file.
-- They intercept the keystroke, load the plugin, and then execute the native command.

local function bootstrap_obsidian(cmd)
  return function()
    if not vim.g.obsidian_loaded then
      require("plugins.notetaking.obsidian").setup()
      vim.g.obsidian_loaded = true
    end
    -- Execute the requested Obsidian command after the plugin is verified loaded
    vim.cmd(cmd)
  end
end

-- Map the stubs
map("n", "<leader>oq", bootstrap_obsidian("ObsidianQuickSwitch"), { desc = "[O]bsidian [Q]uick Switch" })
map("n", "<leader>os", bootstrap_obsidian("ObsidianSearch"), { desc = "[O]bsidian [S]earch (Ripgrep)" })
map("n", "<leader>on", bootstrap_obsidian("ObsidianNew"), { desc = "[O]bsidian [N]ew Note" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
