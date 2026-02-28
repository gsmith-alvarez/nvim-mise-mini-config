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

-- =============================================================================
-- [[ NEOVIM BOOTSTRAP OS ]]
-- Architecture: Iterative Fault-Tolerant Loader
-- =============================================================================

-- [[ THE ANTI-FRAGILE ENGINE ]]
-- Captures stack traces and schedules notifications for the UI-attach phase.
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.schedule(function()
      vim.notify(
        string.format("[BOOT SEQUENCE FAILURE]\nModule: %s\nError: %s", module, err),
        vim.log.levels.ERROR,
        { title = "Init.lua Fault Tolerance" }
      )
    end)
  end
  return ok
end

-- =============================================================================
-- PHASE 1: CORE FOUNDATION
-- =============================================================================
-- We load the reporter, installer, and core logic in a strict dependency order.

-- 1. Reporter: Must load first to log errors from subsequent modules.
require('core.utils')

-- 2. Core Orchestrator: Loads deps.lua, libs.lua, options, and keymaps
safe_require('core')

-- 3. Automation Layers: Custom user commands and autocommands
safe_require('autocmd')
safe_require('commands')

safe_require('plugins')
