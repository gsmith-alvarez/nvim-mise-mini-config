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
require 'core.options'
require 'core.keymaps'
require 'core.autocmds'
require 'core.commands'
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

-- Migrated plugins
require 'plugins.toggleterm'
require 'plugins.which-key'
require 'plugins.yazi'
require 'plugins.noice'
require 'plugins.tabout'

-- All plugins are now migrated to mini.deps imperative format
require 'plugins.colors'
require 'plugins.completion'
require 'plugins.debug'
require 'plugins.harpoon'
require 'plugins.indent'
require 'plugins.lazygit'
require 'plugins.mini'
require 'plugins.smart-splits'
require 'plugins.lsp'
require 'plugins.refactoring'
require 'plugins.telescope'
require 'plugins.treesitter'
require 'plugins.ui'
require 'plugins.ui_utils'
require 'plugins.vim-be-good'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
